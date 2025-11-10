import Foundation

@MainActor
final class UserViewModel: ObservableObject {
    @Published var userInfo: UserInfo? = nil
    @Published var isLoading = false

    func fetchUserInfo() async {
        guard let session = UserSession.current else {
            print("UserSession 없음")
            return
        }

        let userId = session.engineerId
        let urlString = "http://34.120.215.23/user/api/v1/getUser?userId=\(userId)"
        print("📡 [UserViewModel] 사용자 정보 요청 URL:", urlString)

        do {
            isLoading = true
            let response: UserResponse = try await NetworkManager.shared.request(url: urlString)
            userInfo = response.data
            print("[UserViewModel] 사용자 정보 로드 성공:", response.data.name)
        } catch {
            print("사용자 정보 로드 실패:", error.localizedDescription)
        }
        isLoading = false
    }
}

