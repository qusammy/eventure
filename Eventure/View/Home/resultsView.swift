import CoreMotion
import SwiftUI

struct resultsView: View {
    @StateObject private var surveyVM = SurveyViewModel()
    @StateObject private var motion = MotionManager()
    @EnvironmentObject var eventsVM: EventsViewModel
    @State var isFavorited: Bool
    

    var body: some View {
        ZStack {
            // MARK: Background
            Image("kayakPicture")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .frame(width: 1000, height: 1000)
                .ignoresSafeArea()
                .offset(x: motion.roll * 50, y: motion.pitch * 50)
                .animation(.easeOut(duration: 0.1), value: motion.roll)
                .blur(radius: 4)

            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.white)
                .opacity(0.50)

            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    // Header
                    VStack(spacing: 10) {
                        Image("eventureLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 150)
                            .padding(.top, 40)

                        Text("events in your area based on survey responses")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // MARK: Event cards from backend events
                    VStack(spacing: 16) {
                        if eventsVM.events.isEmpty {
                            Text("Finding events near you...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 24)
                        } else {
                            ForEach(eventsVM.events) { event in
                                EventCard(
                                    isFavorited: false,
                                    eventName: event.title,
                                    eventImage: event.image,
                                    fallbackImageName: imageName(for: event),
                                    eventDate: formattedDate(from: event.startTime),
                                    snippet: snippet(for: event),
                                    urlString: event.url
                                )
                            }
                        }
                    }
                    .padding(.top, 24)
                }
                .padding(.top, 125)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            // 1) Load survey data from Firestore
            surveyVM.fetchSurveyData {
                // 2) After survey data is loaded, build the EventRequest and hit your backend
                Task {
                    // Location: question1 (or fallback)
                    let location = surveyVM.question1.isEmpty
                        ? "Dallas, TX"
                        : surveyVM.question1

                    // Interests: question2,3,4 (filter out blanks)
                    let rawInterests = [surveyVM.question2,
                                        surveyVM.question3,
                                        surveyVM.question4]
                    let interests = rawInterests
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }

                    let finalInterests = interests.isEmpty ? ["music"] : interests

                    // Date: you don't have a date question yet, so send ""
                    let date = ""

                    print("📡 Sending survey request:", location, finalInterests, date)

                    await eventsVM.loadFromSurvey(
                        location: location,
                        interests: finalInterests,
                        date: date
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    /// Convert ISO 8601 ("2025-11-29T19:30:00") -> "11/29/25 7:30 PM" (no comma, no "T").
    private func formattedDate(from isoString: String?) -> String {
        guard let isoString else { return "TBD" }

        // 1. Try strict ISO8601 with fractional seconds
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: isoString) {
            let out = DateFormatter()
            out.dateFormat = "MM/dd/yy h:mm a"
            return out.string(from: date)
        }

        // 2. Try manual format without timezone
        let manual = DateFormatter()
        manual.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        manual.locale = Locale(identifier: "en_US_POSIX")
        manual.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = manual.date(from: isoString) {
            let out = DateFormatter()
            out.dateFormat = "MM/dd/yy h:mm a"
            return out.string(from: date)
        }

        // 3. Fallback: just replace "T" with a space
        return isoString.replacingOccurrences(of: "T", with: " ")
    }

    /// Decide what snippet to show for an event.
    private func snippet(for event: EventSummary) -> String {
        if let s = event.snippet,
           !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return s
        } else {
            return "For your consideration."
        }
    }

    /// Pick an image name based on the event title so cards don't all look the same.
    private func imageName(for event: EventSummary) -> String {
        let lower = event.title.lowercased()

        if lower.contains("kayak") || lower.contains("lake") {
            return "kayakPicture"
        } else if lower.contains("art") || lower.contains("paint") {
            return "artClass"
        } else if lower.contains("symphony")
                    || lower.contains("orchestra")
                    || lower.contains("concert") {
            return "concert"
        } else if lower.contains("light") {
            return "concert"
        } else {
            return "concert"
        }
    }
}

#Preview {
    resultsView(isFavorited: false)
        .environmentObject(
            EventsViewModel(
                client: EventClient(endpoint: API.events)
            )
        )
}

// MARK: - EventCard

struct EventCard: View {
    @State var isFavorited: Bool
    let eventName: String
    let eventImage: String?
    let fallbackImageName: String
    let eventDate: String
    let snippet: String
    let urlString: String?

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 20) {
            Group {
                if let urlString,
                   let url = URL(string: urlString) {
                    // Whole bubble is clickable
                    Button {
                        openURL(url)
                    } label: {
                        cardContent
                    }
                    .buttonStyle(.plain)
                } else {
                    // No URL: just show the card without navigation
                    cardContent
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // The visual content of the card (image + overlays)
    private var cardContent: some View {
        ZStack(alignment: .bottom) {
            // 1) If backend provided an image string that parses to an http(s) URL -> load remote image with AsyncImage.
            if let imageString = eventImage,
               let url = URL(string: imageString),
               let scheme = url.scheme, (scheme == "http" || scheme == "https") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Image(fallbackImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    @unknown default:
                        Image(fallbackImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .clipped()
                .frame(width: 400, height: 300)
            }
            // 2) Otherwise try to use backend string as local asset name
            else if let imageString = eventImage {
                Image(imageString)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .frame(width: 400, height: 300)
            }
            // 3) Fallback to our local asset decision
            else {
                Image(fallbackImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .frame(width: 400, height: 300)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(eventName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(eventDate)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.title3)
                }

                // Snippet text
                Text(snippet)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.7), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 180)
            )
        }
        .frame(width: 400, height: 300)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
