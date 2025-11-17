import SwiftUI
import FirebaseCore

// MARK: - API Endpoint

enum API {
    static let events = URL(string: "https://event-backend-u3ze.onrender.com/events")!
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
                    // ⬅️ for now, load from req.json like before
                    await eventsViewModel.loadInitialEvents()
                }
        }
    }
}
