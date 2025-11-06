import SwiftUI

struct GFSearchField<Trailing: View>: View {
    @Binding var text: String
    var placeholder: String
    var icon: String = "magnifyingglass"
    @ViewBuilder var trailing: () -> Trailing

    init(
        text: Binding<String>,
        placeholder: String,
        icon: String = "magnifyingglass",
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        _text = text
        self.placeholder = placeholder
        self.icon = icon
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(AppColor.textMuted)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundColor(AppColor.mainTextBlack)
            if !(Trailing.self == EmptyView.self) {
                Spacer(minLength: 6)
                trailing()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 0.8)
        )
        .shadow(color: AppColor.cardShadow, radius: 10, x: 0, y: 4)
    }
}

extension GFSearchField where Trailing == EmptyView {
    init(
        text: Binding<String>,
        placeholder: String,
        icon: String = "magnifyingglass"
    ) {
        self.init(text: text, placeholder: placeholder, icon: icon) {
            EmptyView()
        }
    }
}
