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
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                Spacer()
                if let statusText, let statusColor {
                    Text(statusText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.surface)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(statusColor)
                        .clipShape(Capsule())
                        .shadow(color: statusColor.opacity(0.3), radius: 6, x: 0, y: 4)
                }
            }

            VStack(spacing: 14) {
                ForEach(rows, id: \.title) { row in
                    HStack(alignment: .top, spacing: 12) {
                        Text(row.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColor.textMuted)
                            .frame(width: 90, alignment: .leading)

                        Spacer()

                        Text(row.value)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColor.mainTextBlack)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .gfCardStyle(cornerRadius: 22, padding: 24)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        DetailInfoSection(
            title: "수리 상세정보",
            statusText: "진행중",
            statusColor: .orange,
            rows: [
                ("접수번호", "CHK-2025-001"),
                ("차량번호", "34가 5678"),
                ("차주명", "곽태근"),
                ("차종", "그랜저"),
                ("담당자", "권오윤"),
                ("연락처", "010-3456-7890")
            ]
        )
    }
    .padding(.vertical)
}
