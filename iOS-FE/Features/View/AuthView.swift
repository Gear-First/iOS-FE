import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel.shared
    @State private var isLoading = false
    @State private var navigateToMain = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                // 🔧 로고 & 타이틀
                VStack(spacing: 12) {
                    Image(systemName: "gearshape.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 78)
                        .foregroundColor(Color(hex: "#111827"))
                        .padding(.bottom, 6)

                    Text("GearFirst")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(hex: "#111827"))

                    Text("스마트 정비 ERP 로그인")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }

                Spacer()

                // 🔹 로그인 버튼
                Button {
                    isLoading = true
                    viewModel.login()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("로그인하기")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#111827"))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 36)
                .disabled(isLoading)

                Spacer()

                // 푸터 문구
                Text("© 2025 GearFirst Inc.")
                    .font(.footnote)
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .background(Color.white.ignoresSafeArea())

            // 최신 방식의 화면 이동
            .navigationDestination(isPresented: $navigateToMain) {
                BottomBar()
            }

            // 로그인 성공 시 자동 이동
            .onChange(of: viewModel.isLoggedIn) { newValue in
                if newValue {
                    isLoading = false
                    navigateToMain = true
                }
            }
        }
    }
}

// MARK: - Hex Color 확장
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    AuthView()
}
