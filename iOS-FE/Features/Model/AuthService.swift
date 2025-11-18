import Foundation
import CryptoKit

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let clientId = "gearfirst-client-mobile"
    private let redirectURI = "gearfirst://callback"
    private let authServer = APIConfig.Auth.baseURL
    private var codeVerifier: String?
    
    // MARK: - Step 1. 인증 URL 생성
    func createAuthURL() -> URL? {
        print("[AuthService] createAuthURL 시작")
        let verifier = randomString(length: 64)
        let challenge = generateCodeChallenge(from: verifier)
        self.codeVerifier = verifier
        
        var components = URLComponents(string: "\(authServer)/oauth2/authorize")
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "openid email offline_access"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: randomString(length: 16))
        ]
        
        let finalURL = components?.url
        print("[AuthService] 최종 인증 URL:", finalURL?.absoluteString ?? "nil")
        return finalURL
    }
    
    // MARK: - Step 2. 인가코드로 토큰 요청
    func requestAccessToken(code: String, completion: @escaping (Bool) -> Void) {
        print("[AuthService] requestAccessToken 시작")
        
        guard let codeVerifier = codeVerifier else {
            print("[AuthService] codeVerifier 없음")
            completion(false)
            return
        }

        var request = URLRequest(url: URL(string: "\(authServer)/oauth2/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
//        let basicAuth = "gearfirst-client:secret".data(using: .utf8)!.base64EncodedString()
//            request.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
//
        let credentials = "gearfirst-client-mobile:secret"
            if let encoded = credentials.data(using: .utf8)?.base64EncodedString() {
                request.setValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
            }
        let body = "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectURI)&code_verifier=\(codeVerifier)&client_id=\(clientId)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[AuthService] 요청 실패:", error.localizedDescription)
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("[AuthService] 응답 상태 코드:", httpResponse.statusCode)
            } else {
                print("[AuthService] HTTPURLResponse 캐스팅 실패")
            }
            
            guard let data = data else {
                print("[AuthService] 데이터 없음")
                completion(false)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("[AuthService] 토큰 응답:", json)
                
                if let accessToken = json["access_token"] as? String {
                    TokenManager.shared.saveAccessToken(accessToken)
                    print("[AuthService] ✅ AccessToken 저장 완료")
                    
                    if let refreshToken = json["refresh_token"] as? String {
                        TokenManager.shared.saveRefreshToken(refreshToken)
                        print("[AuthService] ✅ RefreshToken 저장 완료")
                    }
                    
                    completion(true)
                } else {
                    print("[AuthService] ❌ access_token 없음")
                    completion(false)
                }
            } else {
                print("[AuthService] ❌ JSON 파싱 실패:", String(data: data, encoding: .utf8) ?? "nil")
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - PKCE 유틸
    private func randomString(length: Int) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<length).compactMap { _ in chars.randomElement() })
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
