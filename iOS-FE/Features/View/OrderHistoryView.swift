import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var historyViewModel: OrderHistoryViewModel

    // ✅ 발주 상세 이동 제어용 상태
    @State private var selectedOrder: OrderHistoryItem?
    @State private var goToDetail = false

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
                await historyViewModel.refreshOrders()
            }
            .navigationTitle("발주 내역")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColor.background.ignoresSafeArea())
            .task {
                await historyViewModel.fetchAllOrders()
            }

            // ✅ ① 새로 만든 주문을 선택했을 때 이동
            .navigationDestination(isPresented: $goToDetail) {
                if let order = selectedOrder {
                    OrderDetailView(
                        orderId: order.orderId,
                        onCancel: {
                            Task {
                                await historyViewModel.cancelOrder(orderId: order.orderId)
                                await historyViewModel.refreshOrders()
                            }
                        },
                        onBack: {
                            selectedOrder = nil
                            goToDetail = false
                        }
                    )
                }
            }

            // ✅ ② 리스트 클릭 시 이동
            .navigationDestination(for: OrderHistoryItem.self) { order in
                OrderDetailView(
                    orderId: order.orderId,
                    onCancel: {
                        Task {
                            await historyViewModel.cancelOrder(orderId: order.orderId)
                            await historyViewModel.refreshOrders()
                        }
                    },
                    onBack: {
                        selectedOrder = nil
                        goToDetail = false
                    }
                )
            }
        }
    }

    // MARK: - 필터 탭
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
                                .fill(isSelected ? AppColor.mainColor : AppColor.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? AppColor.mainColor.opacity(0.35) : AppColor.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 총 개수 표시
    private var totalCount: some View {
        Text("총 \(historyViewModel.filteredOrders.count)건")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(AppColor.mainTextBlack)
    }

    // MARK: - 콘텐츠 섹션
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
                    // ✅ 리스트 클릭 시 상세로 이동
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

    // MARK: - 발주 리스트 셀
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

    // MARK: - 날짜 포맷
    private func formatDate(_ raw: String?) -> String {
        guard let raw = raw else { return "-" }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) { return displayString(from: d) }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: raw) { return displayString(from: d) }

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
