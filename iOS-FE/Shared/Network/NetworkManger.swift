import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        url: String,
        method: String = "GET",
        body: Any? = nil,
        withAuth: Bool = true   // 기본값 true: 자동으로 토큰 넣기
    ) async throws -> T {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        

        // (1) 로그인 시 저장된 Access Token 자동 추가
        if withAuth {
            if let token = TokenManager.shared.getAccessToken() {
//                print("[NetworkManager] 요청에 토큰 포함: \(token.prefix(50))...")
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                // 토큰이 필요한데 없으면 에러
                print("[NetworkManager] 토큰이 필요한 요청인데 토큰이 없습니다. 로그인 화면으로 이동해야 합니다.")
                await MainActor.run {
                    AuthViewModel.shared.logout()
                }
                throw URLError(.userAuthenticationRequired)
            }
        }

        // (2) Body 처리 (기존 동일)
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
        
        // (3) 요청 실행
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // 401 Unauthorized 에러 처리 (토큰이 없거나 만료된 경우)
        if httpResponse.statusCode == 401 {
            let errorBody = String(data: data, encoding: .utf8) ?? "응답 본문 없음"
            print("[NetworkManager] 401 Unauthorized - 토큰이 없거나 만료되었습니다.")
            print("[NetworkManager] 현재 토큰:", TokenManager.shared.getAccessToken() ?? "nil")
            print("[NetworkManager] 서버 응답:", errorBody)
            await MainActor.run {
                NotificationCenter.default.post(
                    name: NSNotification.Name("UnauthorizedError"),
                    object: nil,
                    userInfo: [
                        "statusCode": httpResponse.statusCode,
                        "responseBody": errorBody,
                        "url": url.absoluteString
                    ]
                )
            }
            throw URLError(.userAuthenticationRequired)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // 에러 응답 본문 로그
            if let errorBody = String(data: data, encoding: .utf8) {
                print("[NetworkManager] 에러 응답 (Status: \(httpResponse.statusCode)): \(errorBody)")
            }
            throw URLError(.badServerResponse)
        }
        
        // (4) 빈 응답 대응
        if T.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse(success: true, message: nil) as! T
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
