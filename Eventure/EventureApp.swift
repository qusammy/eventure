import SwiftUI
import Foundation
import FirebaseCore

// MARK: - API Endpoint

enum API {
    static let events = URL(string: "https://event-backend-u3ze.onrender.com/events")!
}

// MARK: - View Model

@MainActor
final class EventsViewModel: ObservableObject {
    @Published var events: [EventSummary] = []

    private let client: EventClient

    init(client: EventClient) {
        self.client = client
    }

    /// Called to load initial events.
    func loadInitialEvents() async {
        // Avoid reloading if we already have data
        guard events.isEmpty else { return }
        await reload()
    }

    /// Reload events from the bundled req.json and the backend.
    func reload() async {
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
}

// MARK: - App

@main
struct EventureApp: App {
    @StateObject private var eventsViewModel: EventsViewModel

    init() {
        FirebaseApp.configure()

        let client = EventClient(endpoint: API.events)
        _eventsViewModel = StateObject(wrappedValue: EventsViewModel(client: client))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventsViewModel)
                .task {
                    await eventsViewModel.loadInitialEvents()
                }
        }
    }
}
