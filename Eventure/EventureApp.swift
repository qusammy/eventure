import SwiftUI
import Foundation
import FirebaseCore

@main
struct EventureApp: App {
    init() {
        FirebaseApp.configure()

        Task {
            let endpoint = URL(string: "https://event-backend-u3ze.onrender.com/events")!
            let client = EventClient(endpoint: endpoint)

            // ✅ Find req.json inside bundle
            guard let reqURL = Bundle.main.url(forResource: "req", withExtension: "json") else {
                print("❌ req.json not found in bundle")
                return
            }

            do {
                _ = try await client.postJSON(fromFile: reqURL.path, saveTo: nil)
                print("✅ Request sent successfully")
            } catch {
                print("❌ \(error)")
            }
        }

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

