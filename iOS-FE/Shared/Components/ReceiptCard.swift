import SwiftUI

struct ReceiptCard: View {
    let item: ReceiptItem
    var showStatus: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(item.id)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                
                if showStatus {
                    Spacer()
                    Text(item.status.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.surface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor(for: item.status))
                        .clipShape(Capsule())
                }
            }
            
            Text(item.requestContent)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColor.textMuted)
            
            Divider()
                .overlay(AppColor.cardBorder)
            
            infoGrid
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.carModel)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.mainTextBlack)
                    if let lead = item.leadTimeDays {
                        Text("평균 \(lead)일 소요")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColor.textMuted)
                    }
                }

                Spacer()
                Text(item.date)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColor.textMuted)
            }
        }
        .gfCardStyle()
    }
    
    private func statusColor(for status: ReceiptStatus) -> Color {
        switch status {
        case .checkIn: return AppColor.mainBlue
        case .inProgress: return AppColor.mainYellow
        case .completed: return AppColor.mainGreen
        }
    }
    
    // MARK: - Helper Row
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
        }
    }

    private var infoGrid: some View {
        VStack(spacing: 12) {
            infoRow(label: "차주", value: item.ownerName)
            infoRow(label: "차량번호", value: item.carNumber)
            if let manager = item.manager {
                infoRow(label: "담당자", value: manager)
            }
        }
    }
}

// MARK: - Preview
#Preview("상태 표시") {
    let mockItem = ReceiptItem(
        id: "CHK-2025",
        carNumber: "11가 1234",
        ownerName: "박우진",
        carModel: "그랜저",
        requestContent: "엔진오일 교체 요청",
        date: "2025-11-11",
        phoneNumber: "010-1234-5678",
        manager: "정상기",
        status: .completed
    )
    return ReceiptCard(item: mockItem, showStatus: true)
        .padding()
}

#Preview("상태 미표시") {
    let mockItem = ReceiptItem(
        id: "CHK-2026",
        carNumber: "22나 5678",
        ownerName: "김민수",
        carModel: "아반떼",
        requestContent: "점검 요청",
        date: "2025-11-12",
        phoneNumber: "010-9876-5432",
        manager: nil,
        status: .checkIn
    )
    return ReceiptCard(item: mockItem)
        .padding()
}
