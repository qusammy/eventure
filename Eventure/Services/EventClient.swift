import Foundation

// MARK: - Models

public struct EventSummary: Codable, Identifiable {
    public let id = UUID()        // Local ID for SwiftUI List
    public let title: String
    public let startTime: String?
    public let venue: String?
    public let url: String?
}

public struct EventsResponse: Codable {
    public let items: [EventSummary]
}

// MARK: - Client

public struct EventClient {
    public let endpoint: URL

    public init(endpoint: URL) {
        self.endpoint = endpoint
    }

    // MARK: - Public API (File → Save response to disk)

    /// Posts a JSON file (by path String) to `endpoint`,
    /// saves the response to a file, and returns the output file URL.
    @discardableResult
    public func postJSON(fromFile inPath: String,
                         saveTo outPath: String? = nil,
                         prettyPrintToStdout: Bool = true) async throws -> URL {
        let reqURL = URL(fileURLWithPath: inPath)
        let body = try Data(contentsOf: reqURL)
        return try await postJSON(body: body,
                                  saveTo: outPath,
                                  prettyPrintToStdout: prettyPrintToStdout)
    }

    /// Posts a JSON file (by file URL, ideal for bundle resources),
    /// saves the response to a file, and returns the output file URL.
    @discardableResult
    public func postJSON(fromFile fileURL: URL,
                         saveTo outPath: String? = nil,
                         prettyPrintToStdout: Bool = true) async throws -> URL {
        let body = try Data(contentsOf: fileURL)
        return try await postJSON(body: body,
                                  saveTo: outPath,
                                  prettyPrintToStdout: prettyPrintToStdout)
    }

    /// Posts raw JSON data to `endpoint`, saves the response to a file, and returns the output file URL.
    @discardableResult
    public func postJSON(body: Data,
                         saveTo outPath: String? = nil,
                         prettyPrintToStdout: Bool = true) async throws -> URL {
        print("🌐 [EventClient] Sending request to \(endpoint.absoluteString)")
        print("📦 [EventClient] Request body size: \(body.count) bytes")

        let data = try await performRequest(body: body)

        // Decide where to save the response
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

    // MARK: - Public API (File → Decode events)

    /// Reads JSON body from a file URL, posts it, and decodes the response into `[EventSummary]`.
    public func fetchEvents(fromFile fileURL: URL) async throws -> [EventSummary] {
        let body = try Data(contentsOf: fileURL)
        let data = try await performRequest(body: body)

        let decoder = JSONDecoder()
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.items
    }

    /// Convenience: reads JSON body from a path String, posts it, and decodes the response into `[EventSummary]`.
    public func fetchEvents(fromFilePath path: String) async throws -> [EventSummary] {
        let fileURL = URL(fileURLWithPath: path)
        return try await fetchEvents(fromFile: fileURL)
    }

    // MARK: - Core request

    /// Sends the request and returns raw response data, or throws on HTTP / URL errors.
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
