import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // MARK: - 필터 버튼 (탭 스타일)
                HStack(spacing: 0) {
                    ForEach(OrderHistoryViewModel.OrderFilter.allCases) { filter in
                        let isSelected = historyViewModel.selectedFilter == filter
                        Button(action: {
                            historyViewModel.selectedFilter = filter
                        }) {
                            VStack(spacing: 4) {
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(isSelected ? AppColor.mainBlack : AppColor.mainTextGray)
                                    .frame(maxWidth: .infinity)
                                
                                // 선택된 탭 밑줄
                                Rectangle()
                                    .fill(isSelected ? AppColor.mainBlack: Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                // MARK: - 발주 내역
                
                if historyViewModel.filteredItems.isEmpty {
                    VStack {
                        Spacer()
                        Text("발주 내역이 없습니다.")
                            .foregroundColor(AppColor.mainTextGray)
                            .font(.body)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(historyViewModel.filteredItems) { item in
                                NavigationLink(
                                    destination: OrderDetailView(item: item, onCancel: {
                                        historyViewModel.cancelOrder(item)
                                    })
                                ) {
                                    orderItemRow(item: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 12)
            .navigationTitle("발주 내역")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColor.bgGray)
        }
    }
    
    // MARK: - Row View 분리
    @ViewBuilder
    private func orderItemRow(item: OrderItem) -> some View {
        let statusText = item.orderStatus.rawValue
        let badgeColor = item.orderStatus.badgeColor
        
        VStack(alignment: .leading, spacing: 8) {
            Text("발주번호: \(item.id)")
                .font(.headline)
                .foregroundColor(AppColor.mainBlack)
            
            Text("부품: \(item.inventoryName) (\(item.quantity)개)")
                .font(.subheadline)
                .foregroundColor(AppColor.mainBlack)
            
            HStack {
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(AppColor.mainWhite)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor)
                    .cornerRadius(6)
                
                Spacer()
                
                Text(item.requestDate)
                    .font(.caption)
                    .foregroundColor(AppColor.mainTextGray)
            }
        }
        .padding()
        .background(AppColor.mainWhite)
        .cornerRadius(12)
        .shadow(color: AppColor.mainBlack.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    let dummyItems = [
        OrderItem(
            inventoryCode: "INV-001",
            inventoryName: "브레이크 패드",
            quantity: 5,
            requestDate: "2025-10-04",
            id: "ORD-1234",
            orderStatus: .승인대기
        ),
        OrderItem(
            inventoryCode: "INV-002",
            inventoryName: "에어필터",
            quantity: 2,
            requestDate: "2025-10-03",
            id: "ORD-1235",
            orderStatus: .승인완료
        ),
        OrderItem(
            inventoryCode: "INV-003",
            inventoryName: "오일필터1",
            quantity: 1,
            requestDate: "2025-10-04",
            id: "ORD-1236",
            orderStatus: .취소
        ),
        OrderItem(
            inventoryCode: "INV-004",
            inventoryName: "오일필터",
            quantity: 1,
            requestDate: "2025-10-05",
            id: "ORD-1237",
            orderStatus: .납품완료
        ),
        OrderItem(
            inventoryCode: "INV-005",
            inventoryName: "오일필터",
            quantity: 1,
            requestDate: "2025-10-06",
            id: "ORD-1238",
            orderStatus: .출고중
        ),
        OrderItem(
            inventoryCode: "INV-006",
            inventoryName: "오일필터",
            quantity: 1,
            requestDate: "2025-10-07",
            id: "ORD-1239",
            orderStatus: .반려
        )
    ]
    
    // ViewModel 생성 시 기본 필터 지정
    let viewModel = OrderHistoryViewModel(items: dummyItems)
    viewModel.selectedFilter = .all
    
    // Preview에서는 단순히 View 반환
    return OrderHistoryView(historyViewModel: viewModel)
}
