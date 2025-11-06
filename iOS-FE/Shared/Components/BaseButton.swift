import SwiftUI

struct BaseButton: View {
    var label: String
    var backgroundColor: Color = AppColor.mainBlue
    var textColor: Color = AppColor.mainWhite
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(backgroundColor)
                )
                .shadow(color: backgroundColor.opacity(0.3), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        BaseButton(label: "요청하기") {
            print("요청 버튼 클릭")
        }

        BaseButton(
            label: "취소",
            backgroundColor: AppColor.mainTextGray.opacity(0.4),
            textColor: AppColor.mainBlack
        ) {
            print("취소 클릭")
        }
    }
    .padding()
}
