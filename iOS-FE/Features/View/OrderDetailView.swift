import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert = false
    
    let order: OrderHistoryItem
    let onCancel: () -> Void
    
    private var status: OrderStatus { OrderStatusMapper.map(order.status) }
    
    var body: some View {
        VStack {
            SectionCard(title: "진행 상황") {
                let steps: [OrderStatus] = [.PENDING, .APPROVED, .SHIPPED, .COMPLETED]
                let stepDates: [OrderStatus: String] = [
                    .PENDING: order.requestDate,
                    .APPROVED: order.approvedDate ?? "-",
                    .SHIPPED: order.transferDate ?? "-",
                    .COMPLETED: order.completedDate ?? "-"
                ]
                let special: OrderStatus? = ["CANCELLED","REJECTED"].contains(order.status) ? status : nil
                
                StepProgressView(
                    steps: steps,
                    currentStep: status,
                    colorProvider: { _ in AppColor.mainBlue },
                    labelProvider: { $0.rawValue },
                    dates: stepDates,
                    specialStatus: special
                )
            }
            .padding(.vertical, 24)
            
            DetailInfoSection(
                title: "발주 상세 정보",
                statusText: status.rawValue,
                statusColor: status.badgeColor,
                rows: [
                    ("발주번호", order.orderNumber),
                    ("총 금액", "\(order.totalPrice)"),
                    ("요청 일자", order.requestDate),
                    ("승인 일자", order.approvedDate ?? "-"),
                    ("이관 일자", order.transferDate ?? "-"),
                    ("완료 일자", order.completedDate ?? "-"),
                    ("부품 내역", order.items.map { "\($0.inventoryName) (\($0.quantity)개)" }.joined(separator: ", "))
                ]
            )
            Spacer()
            
            if ["PENDING","APPROVED"].contains(order.status) {
                BaseButton(
                    label: "요청 취소",
                    backgroundColor: .red,
                    textColor: .white
                ) { showCancelAlert = true }
                .alert("요청을 취소하시겠습니까?", isPresented: $showCancelAlert) {
                    Button("확인", role: .destructive) { onCancel() }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("한 번 취소하면 되돌릴 수 없습니다.")
                }
                .padding()
            }
        }
        .padding(.horizontal)
        .background(AppColor.bgGray)
        .navigationTitle("발주 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColor.mainDarkBlue)
                }
            }
        }
    }
}

// MARK: - OrderStatusMapper
struct OrderStatusMapper {
    static func map(_ status: String) -> OrderStatus {
        switch status.uppercased() {
        case "PENDING": return .PENDING
        case "APPROVED": return .APPROVED
        case "SHIPPED": return .SHIPPED
        case "COMPLETED": return .COMPLETED
        case "CANCELLED": return .CANCELLED
        case "REJECTED": return .REJECTED
        default: return .PENDING
        }
    }
    
    static func color(for status: String) -> Color { map(status).badgeColor }
}
