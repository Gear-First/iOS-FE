import SwiftUI

struct BaseButton: View {
    var label: String
    var backgroundColor: Color = AppColor.mainBlue
    var textColor: Color = AppColor.mainWhite
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
                .shadow(color: AppColor.mainBlack.opacity(0.1), radius: 4, x: 0, y: 2)
        }
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
