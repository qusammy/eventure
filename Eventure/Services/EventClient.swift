import Foundation

// MARK: - Models

public struct EventSummary: Identifiable {
    public let id = UUID()
    public let title: String
    public let startTime: String?
    public let venue: String?
    public let url: String?
    public let snippet: String?
}

private struct RawEvent: Codable {
    let title: String
    let startTime: String?
    let venue: String?
    let url: String?
}

private struct EventsResponse: Codable {
    let items: [RawEvent]
    let descriptions: [String]?   // optional snippets from backend
}

// MARK: - Request Model

public struct EventRequest: Codable {
    public let location: String
    public let interests: [String]
    public let date: String
}

// MARK: - Client

public struct EventClient {
    public let endpoint: URL

    public init(endpoint: URL) {
        self.endpoint = endpoint
    }

    // MARK: - High-level APIs

    /// New: send a request built in Swift (no file needed).
    public func fetchEvents(request: EventRequest) async throws -> [EventSummary] {
        let body = try JSONEncoder().encode(request)
        let data = try await performRequest(body: body)
        return try decodeEvents(from: data)
    }

    /// Old path: send a JSON file and decode events.
    public func fetchEvents(fromFile fileURL: URL) async throws -> [EventSummary] {
        let body = try Data(contentsOf: fileURL)
        let data = try await performRequest(body: body)
        return try decodeEvents(from: data)
    }

    /// Old path: save response to disk (for debugging).
    @discardableResult
    public func postJSON(body: Data,
                         saveTo outPath: String? = nil,
                         prettyPrintToStdout: Bool = true) async throws -> URL {
        print("🌐 [EventClient] Sending request to \(endpoint.absoluteString)")
        print("📦 [EventClient] Request body size: \(body.count) bytes")

        let data = try await performRequest(body: body)

        let outputURL: URL
        if let outPath, !outPath.isEmpty {
            outputURL = URL(fileURLWithPath: outPath)
        } else {
            outputURL = FileManager.default
                .temporaryDirectory
                .appendingPathComponent("response_\(UUID().uuidString).json")
        }

        try data.write(to: outputURL, options: .atomic)

        if prettyPrintToStdout {
            printPrettyOrRawJSON(from: data)
            print("\n💾 [EventClient] Saved response to: \(outputURL.path)")
        }

        return outputURL
    }

    // MARK: - Core request

    private func performRequest(body: Data) async throws -> Data {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("✅ [EventClient] Received response (\(data.count) bytes)")

            guard let http = response as? HTTPURLResponse else {
                print("❌ [EventClient] Non-HTTP response")
                throw URLError(.badServerResponse)
            }

            print("🔢 [EventClient] Status code: \(http.statusCode)")

            guard (200..<300).contains(http.statusCode) else {
                let serverText = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
                print("❌ [EventClient] HTTP error \(http.statusCode). Body: \(serverText)")
                throw HTTPError(status: http.statusCode, body: serverText)
            }

            return data
        } catch {
            print("❌ [EventClient] URLSession error: \(error)")
            throw error
        }
    }

    // MARK: - Decode helper

    private func decodeEvents(from data: Data) throws -> [EventSummary] {
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(EventsResponse.self, from: data)
        let snippets = decoded.descriptions ?? []

        return decoded.items.enumerated().map { index, raw in
            let snippet = index < snippets.count ? snippets[index] : nil
            return EventSummary(
                title: raw.title,
                startTime: raw.startTime,
                venue: raw.venue,
                url: raw.url,
                snippet: snippet
            )
        }
    }

    // MARK: - Helpers

    private func printPrettyOrRawJSON(from data: Data) {
        if let obj = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: obj,
                                                    options: [.prettyPrinted]),
           let text = String(data: pretty, encoding: .utf8) {
            print("== Response JSON (pretty) ==")
            print(text)
        } else if let text = String(data: data, encoding: .utf8) {
            print("== Response Body (raw) ==")
            print(text)
        } else {
            print("== Response Body (non-UTF8, \(data.count) bytes) ==")
        }
    }

    // MARK: - Error

    public struct HTTPError: Error, CustomStringConvertible {
        public let status: Int
        public let body: String
        public var description: String { "HTTP \(status). Body: \(body)" }
    }
}
