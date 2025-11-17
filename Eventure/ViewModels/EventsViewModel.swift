import Foundation
import Combine

@MainActor
final class EventsViewModel: ObservableObject {
    @Published var events: [EventSummary] = []

    private let client: EventClient

    init(client: EventClient) {
        self.client = client
    }

    /// TEMP: Called on app launch to load events from the bundled req.json.
    func loadInitialEvents() async {
        // Avoid reloading if we already have data
        guard events.isEmpty else { return }

        guard let reqURL = Bundle.main.url(forResource: "req", withExtension: "json") else {
            print("❌ req.json not found in bundle")
            return
        }

        do {
            let items = try await client.fetchEvents(fromFile: reqURL)
            print("✅ Loaded \(items.count) events")
            self.events = items
        } catch {
            print("❌ Failed to fetch events:", error)
        }
    }
    
    // MARK: - Load events based on survey answers
    func loadFromSurvey(location: String,
                        interests: [String],
                        date: String) async {
        let request = EventRequest(
            location: location,
            interests: interests,
            date: date
        )

        do {
            let items = try await client.fetchEvents(request: request)
            print("✅ Loaded \(items.count) events from survey")
            self.events = items
        } catch {
            print("❌ Failed to fetch survey events:", error)
        }
    }

}

