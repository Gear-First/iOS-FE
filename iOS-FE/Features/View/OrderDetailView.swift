import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert = false
    
    let item: OrderItem
    let onCancel: () -> Void
    
    private var statusColor: Color { item.orderStatus.badgeColor }
    
    // StepProgress 관련 변수 뷰 바깥에서 계산
    private var steps: [OrderStatus] {
        OrderStatus.allCases.filter { $0.progressValue > 0 }
    }
    
    private var stepDates: [OrderStatus: String] {
        [
            .승인대기: item.requestDate,
            .승인완료: item.approvalDate ?? "-",
            .출고중: item.deliveryStartDate ?? "-",
            .납품완료: item.deliveredDate ?? "-"
        ]
    }
    
    private var specialStatus: OrderStatus? {
        [.취소, .반려].contains(item.orderStatus) ? item.orderStatus : nil
    }
    
    var body: some View {
        VStack {
            SectionCard(title: "진행 상황") {
                StepProgressView(
                    steps: steps,
                    currentStep: item.orderStatus,
                    colorProvider: { _ in AppColor.mainBlue },
                    labelProvider: { $0.rawValue },
                    dates: stepDates,
                    specialStatus: specialStatus
                )
            }
            .padding(.vertical)
            ScrollView {
                DetailInfoSection(
                    title: "발주 상세 정보",
                    statusText: item.orderStatus.rawValue,
                    statusColor: statusColor,
                    rows: [
                        ("발주번호", item.id),
                        ("부품명", item.inventoryName),
                        ("부품코드", item.inventoryCode),
                        ("수량", "\(item.quantity)"),
                        ("요청 일자", item.requestDate),
                        ("승인 일자", item.approvalDate ?? "-"),
                        ("이관 일자", item.deliveryStartDate ?? "-"),
                        ("납품 일자", item.deliveredDate ?? "-"),
                        ("담당자", "추창우")
                    ]
                )
            }
            Spacer()
            
            if item.orderStatus == .승인대기 || item.orderStatus == .승인완료 {
                BaseButton(
                    label: "요청 취소",
                    backgroundColor: .red,
                    textColor: .white
                ) { showCancelAlert = true }
                    .alert("요청을 취소하시겠습니까?",
                           isPresented: $showCancelAlert) {
                        Button("확인", role: .destructive) { onCancel() }
                        Button("취소", role: .cancel) {}
                    } message: {
                        Text("한 번 취소하면 되돌릴 수 없습니다.")
                    }
            }
        }
        .padding()
        
        .background(AppColor.bgGray)
        .navigationTitle("발주 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColor.mainDarkBlue)
                }
            }
        }
    }
}

struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrderDetailView(
                item: OrderItem(
                    inventoryCode: "INV-001",
                    inventoryName: "브레이크 패드",
                    quantity: 5,
                    requestDate: "2025-10-04",
                    id: "ORD-1234",
                    orderStatus: .승인대기
                ),
                onCancel: {
                    print("발주 요청 취소")
                }
            )
        }
    }
}
