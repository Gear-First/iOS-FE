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
                    .font(.headline)
                    .foregroundColor(AppColor.mainBlack)
                Spacer()
                if let trailing = trailing {
                    trailing
                }
            }
            content
        }
        .padding()
        .background(AppColor.mainWhite)
        .cornerRadius(12)
        .shadow(color: AppColor.mainBlack.opacity(0.05), radius: 4, x: 0, y: 1)
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
