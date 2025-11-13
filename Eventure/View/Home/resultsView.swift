import CoreMotion
import SwiftUI

struct resultsView: View {
    @StateObject private var surveyVM = SurveyViewModel()
    @StateObject private var motion = MotionManager()
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
            ScrollView{
                VStack{
                    // Header
                    VStack(spacing: 10) {
                        Image("eventureLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 60)
                            .padding(.top, 40)

                        Text("events in your area based on survey responses")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        EventCard(isFavorited: false, eventName: "Kayaking", eventPicture: "kayakPicture", eventDate: "11/20/25")
                        EventCard(isFavorited: true, eventName: "Concert", eventPicture: "concert", eventDate: "11/25/25")
                        EventCard(isFavorited: true, eventName: "Art Class", eventPicture: "artClass", eventDate: "12/01/25")

                    }
                    // MARK: Main content stacked vertically
                }.padding(.top, 125)
            }
        }
        .onAppear {
            surveyVM.fetchSurveyData()
        }
    }
}

#Preview {
    resultsView(isFavorited: false)
}

struct EventCard: View {
    @State var isFavorited: Bool
    @State var eventName: String
    @State var eventPicture: String
    @State var eventDate: String
    var body: some View {
        VStack(spacing: 20) {

            // Event Card
            ZStack(alignment: .bottom) {
                Image(eventPicture)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .frame(width:400, height: 200)

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
                    Button {
                        isFavorited.toggle()
                    } label: {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title3)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 100)
                )
            }
            .frame(width:400, height: 200)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
    }
}
