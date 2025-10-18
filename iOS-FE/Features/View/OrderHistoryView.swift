import SwiftUI

struct OrderHistoryView: View {
    @StateObject var historyViewModel = OrderHistoryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                // MARK: - 필터 버튼
                HStack(spacing: 0) {
                    ForEach(OrderHistoryViewModel.OrderFilter.allCases) { filter in
                        let isSelected = historyViewModel.selectedFilter == filter
                        Button {
                            historyViewModel.selectedFilter = filter
                        } label: {
                            VStack(spacing: 4) {
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(isSelected ? AppColor.mainBlack : AppColor.mainTextGray)
                                    .frame(maxWidth: .infinity)
                                Rectangle()
                                    .fill(isSelected ? AppColor.mainBlack : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                // MARK: - 주문 리스트
                if historyViewModel.filteredOrders.isEmpty {
                    VStack {
                        Spacer()
                        Text("발주 내역이 없습니다.")
                            .foregroundColor(AppColor.mainTextGray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(historyViewModel.filteredOrders) { order in
                                NavigationLink(value: order) {
                                    orderRow(order: order)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    // Pull-to-Refresh
                    .refreshable {
                        await historyViewModel.refreshOrders(branchId: 2001, engineerId: 1001)
                    }
                }
            }
            .padding(.top, 12)
            .navigationTitle("발주 내역")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColor.bgGray)
            .task {
                await historyViewModel.fetchAllOrders(branchId: 2001, engineerId: 1001)
            }
            .navigationDestination(for: OrderHistoryItem.self) { order in
                OrderDetailView(
                    order: order,
                    onCancel: { historyViewModel.cancelOrder(order) }
                )
            }
        }
    }
    
    @ViewBuilder
    private func orderRow(order: OrderHistoryItem) -> some View {
        let status = OrderStatusMapper.map(order.status)
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("발주번호: \(order.orderNumber)")
                    .font(.headline)
                    .foregroundColor(AppColor.mainBlack)
                Spacer()
                Text(status.rawValue)
                    .font(.caption)
                    .foregroundColor(AppColor.mainWhite)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status.badgeColor)
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(order.items) { item in
                    Text("\(item.inventoryName) (\(item.quantity)개)")
                        .font(.subheadline)
                        .foregroundColor(AppColor.mainBlack)
                }
            }
            
            HStack {
                Text("요청일: \(formatDate(order.requestDate))")
                    .font(.caption)
                    .foregroundColor(AppColor.mainTextGray)
                Spacer()
            }
        }
        .padding()
        .background(AppColor.mainWhite)
        .cornerRadius(12)
        .shadow(color: AppColor.mainBlack.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate else { return "-" }
        
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        if let date = parser.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "ko_KR")
            displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
            return displayFormatter.string(from: date)
        } else {
            print("날짜 파싱 실패: \(isoDate)")
            return isoDate
        }
    }
}
