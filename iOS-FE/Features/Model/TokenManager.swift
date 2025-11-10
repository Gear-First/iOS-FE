import Foundation
import Security

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    private let accessKey = "access_token"
    private let refreshKey = "refresh_token"

    func saveAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: accessKey)
    }

    func getAccessToken() -> String? {
        UserDefaults.standard.string(forKey: accessKey)
    }

    func clearAccessToken() {
        UserDefaults.standard.removeObject(forKey: accessKey)
    }

    func saveRefreshToken(_ token: String) {
        let key = "refresh_token"
        let data = token.data(using: .utf8)!
        SecItemDelete([kSecClass: kSecClassGenericPassword, kSecAttrAccount: key] as CFDictionary)
        SecItemAdd([kSecClass: kSecClassGenericPassword, kSecAttrAccount: key, kSecValueData: data] as CFDictionary, nil)
    }

    func getRefreshToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "refresh_token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
           let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func clearTokens() {
            UserDefaults.standard.removeObject(forKey: accessKey)
            UserDefaults.standard.removeObject(forKey: refreshKey)
            print("[TokenManager] 모든 토큰 삭제 완료")
        }
}


struct JWTDecoder {
    static func decode(_ token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        let payloadSegment = String(segments[1])
        var base64 = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Base64 padding 처리
        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}
