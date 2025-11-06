import SwiftUI

struct MyPageView: View {
    var onLogout: () -> Void = {}
    @State private var showLogoutConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                infoCard
                settingsCard
                logoutSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("마이 페이지")
        .navigationBarTitleDisplayMode(.inline)
        .alert("로그아웃 하시겠어요?", isPresented: $showLogoutConfirm) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                onLogout()
            }
        } message: {
            Text("현재 세션이 종료되고 로그인 화면으로 이동해야 합니다.")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("안녕하세요, 박우진님")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppColor.mainTextBlack)
            Text("GearFirst 계정 정보를 확인하고 설정을 변경할 수 있습니다.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textMuted)
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 42))
                    .frame(width: 72, height: 72)
                    .foregroundColor(AppColor.surface)
                    .background(AppColor.mainBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                VStack(alignment: .leading, spacing: 8) {
                    Text("박우진")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColor.mainTextBlack)
                    Text("서울 대리점 · 엔지니어")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColor.textMuted)
                }
            }
            Divider().overlay(AppColor.cardBorder)
            VStack(alignment: .leading, spacing: 12) {
                infoRow(label: "사번", value: "GF-2025-1021")
                infoRow(label: "연락처", value: "010-1234-5678")
                infoRow(label: "이메일", value: "woo.jin@gearfirst.co.kr")
            }
        }
        .gfCardStyle()
    }

    private var settingsCard: some View {
        SectionCard(title: "계정 설정") {
            VStack(spacing: 16) {
                settingRow(icon: "lock.fill", title: "비밀번호 변경", description: "주기적으로 비밀번호를 변경해 보안을 강화하세요.")
                settingRow(icon: "bell.fill", title: "알림 설정", description: "푸시 알림 수신 여부를 변경합니다.")
                settingRow(icon: "gearshape.fill", title: "환경설정", description: "앱 기본 정보를 설정합니다.")
            }
        }
    }

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
}

#Preview {
    NavigationStack {
        MyPageView()
    }
}
