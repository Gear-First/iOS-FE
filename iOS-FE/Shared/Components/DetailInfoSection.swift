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

#Preview {
    DetailInfoSection(
        title: "수리 상세정보",
        statusText: "진행중",
        statusColor: .blue,
        rows: [
            ("접수번호", "CHK-2025-001"),
            ("차량번호", "34가 5678"),
            ("차주명", "곽태근"),
            ("차종", "그랜저"),
            ("담당자", "권오윤"),
            ("연락처", "010-3456-7890")
        ]
    )
    .padding()
}
