import Foundation

struct UserSession {
    static var current: UserSession? {
        guard
            let token = TokenManager.shared.getAccessToken(),
            let payload = JWTDecoder.decode(token)
        else { return nil }

        // sub이 Int or String인지 구분
        let id: Int?
        if let sub = payload["sub"] as? Int {
            id = sub
        } else if let subStr = payload["sub"] as? String, let subInt = Int(subStr) {
            id = subInt
        } else {
            id = nil
        }

        let name = payload["name"] as? String
        let branch = payload["region"] as? String ?? "서울 대리점"
        let rank = payload["rank"] as? String
        let workType = payload["work_type"] as? String

        guard let engineerId = id else { return nil }

        return UserSession(
            engineerId: engineerId,
            name: name ?? "",
            branchCode: branch,
            rank: rank,
            workType: workType
        )
    }

    let engineerId: Int
    let name: String
    let branchCode: String
    let rank: String?
    let workType: String?
    
    static func clear() {
        // 토큰이 제거되면 current가 자동으로 nil이 됨
        TokenManager.shared.clearTokens()
    }
}
