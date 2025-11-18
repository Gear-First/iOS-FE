import SwiftUI

/// 공통 카드 스타일을 위한 뷰 수정자
struct GFCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColor.cardBorder, lineWidth: 0.8)
            )
            .shadow(color: AppColor.cardShadow, radius: 16, x: 0, y: 8)
    }
}

extension View {
    func gfCardStyle(cornerRadius: CGFloat = 20, padding: CGFloat = 20) -> some View {
        modifier(GFCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
