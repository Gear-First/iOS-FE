import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert = false
    
    let item: OrderItem
    let onCancel: () -> Void
    
    // MARK: - 상태에 따른 색상
    private var statusColor: Color {
        item.orderStatus.badgeColor
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    DetailInfoSection(
                        title: "발주 상세 정보",
                        statusText: item.orderStatus.rawValue,
                        statusColor: statusColor,
                        rows: [
                            ("발주번호", item.id),
                            ("부품명", item.inventoryName),
                            ("부품코드", item.inventoryCode),
                            ("수량", "\(item.quantity)"),
                            ("요청 일자", item.requestDate), // 대리점에서 요청한 날짜
                            ("승인 일자", item.id), // 본사에서 승인한 날짜
                            ("이관 일자", item.id), // 창고에서 접수한 날짜
                            ("청구자", item.id),
                        ]
                    )
                    // 상태 뱃지 + 발주번호
                }
            }
            .padding(.top, 12)
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
            // 요청 취소 버튼 (승인대기 상태일 때만)
            if item.orderStatus == .승인대기 {
                BaseButton(
                    label: "요청 취소",
                    backgroundColor: .red,
                    textColor: .white
                ) {
                    showCancelAlert = true
                }
                .alert("요청을 취소하시겠습니까?",
                       isPresented: $showCancelAlert) {
                    Button("확인", role: .destructive) {
                        onCancel()
                    }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("한 번 취소하면 되돌릴 수 없습니다.")
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(AppColor.bgGray)
    }
    
    // MARK: - 정보 Row
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OrderDetailView(
        item: OrderItem(
            inventoryCode: "INV-001",
            inventoryName: "브레이크 패드",
            quantity: 5,
            requestDate: "2025-10-04",
            id: "ORD-1234",
            orderStatus: .승인대기
        ),
        onCancel: {}
    )
}
