import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss

    enum Field { case current, new, confirm }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("비밀번호 변경")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColor.mainTextBlack)
                    
                    // ✅ 현재 비밀번호
                    passwordField(
                        title: "현재 비밀번호",
                        text: $currentPassword,
                        focused: $focusedField,
                        field: .current,
                        isDisabled: false
                    )
                    
                    // ✅ 새 비밀번호 (현재 비밀번호 입력 전에는 비활성화)
                    passwordField(
                        title: "새 비밀번호",
                        text: $newPassword,
                        focused: $focusedField,
                        field: .new,
                        isDisabled: currentPassword.isEmpty
                    )
                    .opacity(currentPassword.isEmpty ? 0.5 : 1.0)
                    
                    // ✅ 새 비밀번호 확인 (새 비밀번호 입력 전에는 비활성화)
                    passwordField(
                        title: "새 비밀번호 확인",
                        text: $confirmPassword,
                        focused: $focusedField,
                        field: .confirm,
                        isDisabled: newPassword.isEmpty
                    )
                    .opacity(newPassword.isEmpty ? 0.5 : 1.0)
                    
                    Text("비밀번호는 영문, 숫자, 특수문자를 포함하여 8자 이상이어야 합니다.")
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textMuted)
                        .padding(.top, 4)
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)

                Spacer(minLength: 120)
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        // ✅ 하단 버튼 고정
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(AppColor.surface.ignoresSafeArea())
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                if alertMessage.contains("성공적으로 변경") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - 하단 고정 버튼
    private var bottomActionBar: some View {
        VStack {
            Button {
                Task { await changePassword() }
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("비밀번호 변경")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty
                ? AppColor.mainBlue.opacity(0.5)
                : AppColor.mainBlue
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: AppColor.mainBlue.opacity(0.25), radius: 6, x: 0, y: 3)
            .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || isLoading)
        }
    }

    // MARK: - 커스텀 입력 필드
    private func passwordField(
        title: String,
        text: Binding<String>,
        focused: FocusState<Field?>.Binding,
        field: Field,
        isDisabled: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColor.textMuted)
            
            SecureField("", text: text)
                .focused(focused, equals: field)
                .disabled(isDisabled)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isDisabled
                                ? Color.gray.opacity(0.25)
                                : (focused.wrappedValue == field ? AppColor.mainBlue : Color.gray.opacity(0.3)),
                            lineWidth: 1.3
                        )
                        .background(Color.white.cornerRadius(12))
                )
        }
    }

    // MARK: - API 호출
    private func changePassword() async {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "모든 항목을 입력해주세요."
            showAlert = true
            return
        }

        guard newPassword == confirmPassword else {
            alertMessage = "새 비밀번호가 일치하지 않습니다."
            showAlert = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        let url = URL(string: "http://34.120.215.23/auth/api/v1/auth/change-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "userId": userViewModel.userInfo?.id ?? 0,
            "currentPassword": currentPassword,
            "newPassword": newPassword,
            "confirmPassword": confirmPassword
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                alertMessage = "비밀번호가 성공적으로 변경되었습니다."
            } else {
                let msg = String(data: data, encoding: .utf8) ?? "알 수 없는 오류"
                alertMessage = "변경 실패: \(msg)"
            }
        } catch {
            alertMessage = "네트워크 오류: \(error.localizedDescription)"
        }
        showAlert = true
    }
}
