import SwiftUI

struct SectionCard<Content: View, Trailing: View>: View {
    let title: String
    let trailing: Trailing?
    let content: Content
    
    init(
        title: String,
        @ViewBuilder trailing: () -> Trailing? = { nil },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.trailing = trailing()
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                Spacer()
                if let trailing = trailing {
                    trailing
                }
            }
            content
        }
        .gfCardStyle(cornerRadius: 18, padding: 20)
    }
}

extension SectionCard where Trailing == EmptyView {
    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.trailing = EmptyView()
        self.content = content()
    }
}
