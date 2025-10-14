import SwiftUI

struct DetailInfoSection: View {
    let title: String
    let statusText: String?
    let statusColor: Color?
    let rows: [(title: String, value: String)]

    init(
        title: String,
        statusText: String? = nil,
        statusColor: Color? = nil,
        rows: [(title: String, value: String)]
    ) {
        self.title = title
        self.statusText = statusText
        self.statusColor = statusColor
        self.rows = rows
    }

    var body: some View {
        SectionCard(
            title: title,
            trailing: {
                if let statusText, let statusColor {
                    Text(statusText)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                    .frame(height: 1)
                ForEach(rows, id: \.title) { row in
                    HStack {
                        Text(row.title)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(row.value)
                            .foregroundColor(.primary)
                    }
                    .font(.subheadline)
                }
            }
        }
    }
}
