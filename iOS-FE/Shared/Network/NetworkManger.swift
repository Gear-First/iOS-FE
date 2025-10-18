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
                // text/plain 처리
                request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                request.httpBody = stringBody.data(using: .utf8)
            } else if let jsonBody = body as? [String: Any] {
                // JSON 처리
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
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
        // 응답 상태 체크
        guard (200...299).contains(httpResponse.statusCode) else {
            let responseText = String(data: data, encoding: .utf8) ?? "no response body"
            print("Network Error \(url)\nStatus: \(httpResponse.statusCode)\nResponse: \(responseText)")
            throw URLError(.badServerResponse)
        }
        // EmptyResponse 대응
        if T.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse(success: true, message: nil) as! T
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
