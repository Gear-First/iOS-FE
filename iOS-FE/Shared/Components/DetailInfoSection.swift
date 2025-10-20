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
        VStack(alignment: .leading, spacing: 14) {
            // MARK: - Header
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColor.mainBlack)
                Spacer()
                if let statusText, let statusColor {
                    Text(statusText)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColor.mainWhite)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: statusColor.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }

            Divider().padding(.bottom, 4)

            // MARK: - Rows
            VStack(spacing: 6) {
                ForEach(rows, id: \.title) { row in
                    HStack(alignment: .firstTextBaseline) {
                        Text(row.title)
                            .font(.body)
                            .foregroundColor(AppColor.mainTextGray)
                            .frame(width: 90, alignment: .leading)

                        Spacer()

                        Text(row.value)
                            .font(.body)
                            .foregroundColor(AppColor.mainBlack)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider()
                        .padding(.top, 4)
                        .opacity(row.title == rows.last?.title ? 0 : 0.15)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 1)
        )
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
