import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        url: String,
        method: String = "GET",
        body: Any? = nil
    ) async throws -> T {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let body = body {
            if let stringBody = body as? String {
                request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                request.httpBody = stringBody.data(using: .utf8)
            } else if let jsonBody = body as? [String: Any] {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
            } else if let dataBody = body as? Data {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = dataBody
            } else {
                throw NSError(
                    domain: "NetworkManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unsupported body type: \(type(of: body))"]
                )
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if T.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse(success: true, message: nil) as! T
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
