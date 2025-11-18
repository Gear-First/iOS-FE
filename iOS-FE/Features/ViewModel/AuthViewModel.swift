import Foundation
import AuthenticationServices

final class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthViewModel()

    @Published var isLoggedIn = false
    private var session: ASWebAuthenticationSession?

    private override init() {
        super.init()
        checkLoginStatus()

        // 401 Unauthorized 에러 발생 시 자동 로그아웃 처리
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UnauthorizedError"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let statusCode = notification.userInfo?["statusCode"] as? Int ?? -1
            let responseBody = notification.userInfo?["responseBody"] as? String ?? "응답 본문 없음"
            let failingURL = notification.userInfo?["url"] as? String ?? "알 수 없는 URL"
            print("[AuthViewModel] \(statusCode) 에러 감지 (\(failingURL)) → \(responseBody)")
//            self?.logout()
        }
    }

    // MARK: - 로그인 상태 확인
    func checkLoginStatus() {
        if let token = TokenManager.shared.getAccessToken(), !token.isEmpty {
            print("[AuthViewModel] 기존 토큰 발견 → 로그인 상태 유지")
            isLoggedIn = true
        } else {
            print("[AuthViewModel] 토큰 없음 → 로그인 필요")
            isLoggedIn = false
        }
    }

    // MARK: - 로그인
    func login() {
        guard let url = AuthService.shared.createAuthURL() else {
            print("[AuthViewModel] 인증 URL 생성 실패")
            return
        }

        session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "gearfirst"
        ) { callbackURL, error in
            guard error == nil,
                  let callbackURL = callbackURL,
                  let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                    .queryItems?.first(where: { $0.name == "code" })?.value
            else {
                print("[AuthViewModel] 인가 코드 없음")
                return
            }

            AuthService.shared.requestAccessToken(code: code) { [weak self] success in
                DispatchQueue.main.async {
                    self?.isLoggedIn = success
                    if success {
                        print("[AuthViewModel] 로그인 성공 → 메인화면으로 이동")
                    } else {
                        print("[AuthViewModel] 로그인 실패")
                    }
                }
            }
        }

        // Safari 세션 쿠키를 재사용하지 않도록 (자동 로그인 방지)
        if #available(iOS 13.0, *) {
            session?.prefersEphemeralWebBrowserSession = true
        }

        session?.presentationContextProvider = self
        session?.start()
    }

    // MARK: - 로그아웃
    func logout() {
        print("[AuthViewModel] 로그아웃 시작")
        TokenManager.shared.clearTokens()
        UserSession.clear()

        DispatchQueue.main.async {
            self.isLoggedIn = false
            print("[AuthViewModel] 로그아웃 완료 - 토큰 및 세션 삭제 완료")
        }
    }

    // MARK: - Anchor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows.first!
    }
}
