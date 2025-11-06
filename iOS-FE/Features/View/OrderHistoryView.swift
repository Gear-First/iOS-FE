import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    filterTabs
                    GFSearchField(
                        text: $historyViewModel.searchText,
                        placeholder: "발주번호, 부품명 검색"
                    )
                    totalCount
                    contentSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .refreshable {
                await historyViewModel.refreshOrders(branchCode: "서울 대리점", engineerId: 10)
            }
            .navigationTitle("발주 내역")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColor.background.ignoresSafeArea())
            .task {
                await historyViewModel.fetchAllOrders(branchCode: "서울 대리점", engineerId: 10)
            }
            .navigationDestination(for: OrderHistoryItem.self) { order in
                if let i = historyViewModel.orders.firstIndex(where: { $0.orderId == order.orderId }) {
                    OrderDetailView(order: $historyViewModel.orders[i]) {
                        Task {
                            await historyViewModel.cancelOrder(
                                orderId: order.orderId,
                                branchCode: "서울 대리점",
                                engineerId: 10
                            )
                        }
                    }
                }
            }
        }
    }

    private var filterTabs: some View {
        HStack(spacing: 12) {
            ForEach(OrderHistoryViewModel.OrderFilter.allCases) { filter in
                let isSelected = historyViewModel.selectedFilter == filter
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        historyViewModel.selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? AppColor.surface : AppColor.textMuted)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isSelected ? AppColor.mainBlue : AppColor.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? AppColor.mainBlue.opacity(0.35) : AppColor.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var totalCount: some View {
        Text("총 \(historyViewModel.filteredOrders.count)건")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(AppColor.mainTextBlack)
    }

    private var contentSection: some View {
        Group {
            if historyViewModel.isLoading {
                ProgressView("불러오는 중...")
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColor.mainBlue))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if historyViewModel.filteredOrders.isEmpty {
                EmptyStateView(
                    title: "발주 내역이 없습니다.",
                    message: "필터를 조정하거나 새로고침하여 최신 데이터를 확인하세요.",
                    systemImage: "doc.text.magnifyingglass"
                )
                .frame(maxWidth: .infinity)
                .frame(height: 240)
            } else {
                VStack(spacing: 16) {
                    ForEach(historyViewModel.filteredOrders, id: \.orderId) { order in
                        NavigationLink(value: order) {
                            orderRow(order: order)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func orderRow(order: OrderHistoryItem) -> some View {
        let status = OrderStatusMapper.map(order.status)
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("발주번호: \(order.orderNumber)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                Spacer()
                Text(status.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColor.surface)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(status.badgeColor)
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(order.items) { item in
                    Text("\(item.partName) (\(item.quantity)개)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColor.mainTextBlack)
                }
            }
            
            HStack {
                Text("요청일: \(formatDate(order.requestDate))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColor.textMuted)
                Spacer()
            }
        }
        .gfCardStyle()
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
