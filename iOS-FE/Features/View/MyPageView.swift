import SwiftUI

struct MyPageView: View {
    @StateObject private var userViewModel = UserViewModel()
    @State private var showLogoutConfirm = false
    @EnvironmentObject var authViewModel: AuthViewModel   // 로그인 상태 관리 (로그아웃 후 화면 전환용)
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
//                headerSection
                
                if let user = userViewModel.userInfo {
                    infoCard(user: user)
                } else if userViewModel.isLoading {
                    ProgressView("사용자 정보를 불러오는 중...")
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    Text("사용자 정보를 불러올 수 없습니다.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 200)
                }

                settingsCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
        .safeAreaInset(edge: .bottom) {
            logoutSection
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(AppColor.background.ignoresSafeArea())
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("마이 페이지")
        .navigationBarTitleDisplayMode(.inline)
        .alert("로그아웃 하시겠어요?", isPresented: $showLogoutConfirm) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                handleLogout()
            }
        } message: {
            Text("현재 세션이 종료되고 로그인 화면으로 이동합니다.")
        }
        .task {
            await userViewModel.fetchUserInfo()
        }
    }
}

extension MyPageView {
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("안녕하세요, \(userViewModel.userInfo?.name ?? "사용자")님")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppColor.mainTextBlack)
            Text("GearFirst 계정 정보를 확인하고 설정을 변경할 수 있습니다.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textMuted)
        }
    }

    // MARK: - 사용자 정보 카드
    private func infoCard(user: UserInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 42))
                    .frame(width: 72, height: 72)
                    .foregroundColor(AppColor.surface)
                    .background(AppColor.mainBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                VStack(alignment: .leading, spacing: 8) {
                    Text(user.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColor.mainTextBlack)
                    Text("\(user.workType) · \(user.rank)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColor.textMuted)
                }
            }
            Divider().overlay(AppColor.cardBorder)
            VStack(alignment: .leading, spacing: 12) {
                infoRow(label: "지점", value: user.region)
                infoRow(label: "연락처", value: user.phoneNum)
                infoRow(label: "이메일", value: user.email)
            }
        }
        .gfCardStyle()
    }

    // MARK: - 계정 설정 카드
    private var settingsCard: some View {
        SectionCard(title: "계정 설정") {
            VStack(spacing: 16) {
                NavigationLink(destination: ChangePasswordView().environmentObject(userViewModel)) {
                    settingRow(icon: "lock.fill", title: "비밀번호 변경", description: "주기적으로 비밀번호를 변경해 보안을 강화하세요.")
                }
            }
        }
    }

    // MARK: - 로그아웃 섹션
    private var logoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("세션 관리")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
            Button {
                showLogoutConfirm = true
            } label: {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text("로그아웃")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppColor.mainRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColor.mainRed.opacity(0.25), lineWidth: 1.2)
                )
            }
        }
    }

    // MARK: - Info Row
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textMuted)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
        }
    }

    // MARK: - Setting Row
    private func settingRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
                .foregroundColor(AppColor.surface)
                .background(AppColor.mainBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textMuted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColor.textMuted)
        }
        .foregroundColor(AppColor.mainTextBlack)
    }

    // MARK: - 로그아웃 처리
    private func handleLogout() {
        AuthViewModel.shared.logout()
        
        let access = TokenManager.shared.getAccessToken() ?? "없음"
        let refresh = TokenManager.shared.getRefreshToken() ?? "없음"
        print("[DEBUG] 로그아웃 후 Access Token:", access)
        print("[DEBUG] 로그아웃 후 Refresh Token:", refresh)
    }
}
