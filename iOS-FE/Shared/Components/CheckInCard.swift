import SwiftUI

struct CheckInCard: View {
    let item: CheckInItem
    var showStatus: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - 접수번호 (상단 타이틀)
            HStack {
                Text(item.id)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                
                if showStatus {
                    Spacer()
                    Text(item.status.rawValue)
                        .font(.callout)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor(for: item.status).opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 2)
            
            Divider()
                .padding(.vertical, -4)
            
            // MARK: 차량 정보 섹션
            VStack(alignment: .leading, spacing: 8) {
                infoRow(label: "차주", value: item.ownerName)
                infoRow(label: "차량번호", value: item.carNumber)
            }
            
            HStack {
                Spacer()
                Text(item.date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func statusColor(for status: CheckInStatus) -> Color {
        switch status {
        case .checkIn: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        }
    }
    
    // MARK: Helper Row
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
#Preview("상태 표시") {
    let mockItem = CheckInItem(
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
    return CheckInCard(item: mockItem, showStatus: true)
        .padding()
}

#Preview("상태 미표시") {
    let mockItem = CheckInItem(
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
    return CheckInCard(item: mockItem)
        .padding()
}
