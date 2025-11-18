import Foundation

struct UserInfo: Codable, Identifiable {
    let id: Int
    let name: String
    let regionId: Int
    let region: String
    let workTypeId: Int
    let workType: String
    let rank: String
    let email: String
    let phoneNum: String
}

struct UserResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: UserInfo
}
