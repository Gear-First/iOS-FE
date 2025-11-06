import SwiftUI

struct EmptyStateView: View {
    let title: String
    var message: String? = nil
    var systemImage: String = "tray"

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(AppColor.textMuted)
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
            if let message {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
