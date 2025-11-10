import Foundation

public struct EventClient {
    public let endpoint: URL

    public init(endpoint: URL) {
        self.endpoint = endpoint
    }

    /// Posts a JSON file to `endpoint`, saves the response to a file, and returns the output file URL.
    @discardableResult
    public func postJSON(fromFile inPath: String,
                         saveTo outPath: String? = nil,
                         prettyPrintToStdout: Bool = true) async throws -> URL {
        let reqURL = URL(fileURLWithPath: inPath)
        let body = try Data(contentsOf: reqURL)
        return try await postJSON(body: body, saveTo: outPath, prettyPrintToStdout: prettyPrintToStdout)
    }

    /// Posts raw JSON data to `endpoint`, saves the response to a file, and returns the output file URL.
    @discardableResult
    public func postJSON(body: Data,
                         saveTo outPath: String? = nil,
                         prettyPrintToStdout: Bool = true) async throws -> URL {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            // Include server body text if present for easier debugging
            let serverText = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
            throw HTTPError(status: http.statusCode, body: serverText)
        }

        let outputURL: URL
        if let outPath, !outPath.isEmpty {
            outputURL = URL(fileURLWithPath: outPath)
        } else {
            outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("response_\(UUID().uuidString).json")
        }

        try data.write(to: outputURL, options: .atomic)

        if prettyPrintToStdout {
            if let obj = try? JSONSerialization.jsonObject(with: data),
               let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
               let text = String(data: pretty, encoding: .utf8) {
                print("== Response JSON ==")
                print(text)
            } else if let text = String(data: data, encoding: .utf8) {
                print("== Raw Response ==")
                print(text)
            }
            print("\nSaved to: \(outputURL.path)")
        }

        return outputURL
    }

    public struct HTTPError: Error, CustomStringConvertible {
        public let status: Int
        public let body: String
        public var description: String { "HTTP \(status). Body: \(body)" }
    }
}
