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
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("발주번호, 부품명 검색", text: $historyViewModel.searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Text("총 \(historyViewModel.filteredOrders.count)건")
                        .font(.subheadline)
                        .foregroundColor(AppColor.mainTextGray)
                        .padding(.trailing, 10)
                }
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
                            ForEach(historyViewModel.filteredOrders, id: \.orderId) { order in
                                NavigationLink(value: order) {
                                    orderRow(order: order)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
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
                if let i = historyViewModel.orders.firstIndex(where: { $0.orderId == order.orderId }) {
                    OrderDetailView(order: $historyViewModel.orders[i]) {
                        Task {
                            await historyViewModel.cancelOrder(
                                orderId: order.orderId,
                                branchId: 2001,
                                engineerId: 1001
                            )
                        }
                    }
                }
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
    
    private func formatDate(_ raw: String?) -> String {
        guard let raw = raw else { return "-" }
        
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 2025-10-28T12:34:56.789Z
        if let d = iso.date(from: raw) {
            return displayString(from: d)
        }
        // 밀리초 없는 형태 대응
        iso.formatOptions = [.withInternetDateTime] // 2025-10-28T12:34:56Z
        if let d = iso.date(from: raw) {
            return displayString(from: d)
        }
        // 2) 커스텀 포맷 백업 (서버가 지역시간 문자열을 줄 경우)
        let fmts = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        for f in fmts {
            parser.dateFormat = f
            if let d = parser.date(from: raw) {
                return displayString(from: d)
            }
        }
        // 실패 시 원문 반환
        print("날짜 파싱 실패: \(raw)")
        return raw
    }
    
    private func displayString(from date: Date) -> String {
        let display = DateFormatter()
        display.locale = Locale(identifier: "ko_KR")
        display.dateFormat = "yyyy.MM.dd HH:mm"
        return display.string(from: date)
    }
}
