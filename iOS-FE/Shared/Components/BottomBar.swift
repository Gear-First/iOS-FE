import SwiftUI

struct BottomBar: View {
    @StateObject private var tabRouter = TabRouter()
    @StateObject private var historyViewModel = OrderHistoryViewModel()
    @StateObject private var receiptListViewModel = ReceiptListViewModel()
    @StateObject private var receiptCompletionViewModel = ReceiptCompletionViewModel()

    private let tabs: [TabItem] = [
        TabItem(index: 0, title: "대시보드", icon: "rectangle.grid.2x2"),
        TabItem(index: 1, title: "접수 목록", icon: "tray.full"),
        TabItem(index: 2, title: "접수 내역", icon: "clock.arrow.circlepath"),
        TabItem(index: 3, title: "발주 요청", icon: "square.and.pencil"),
        TabItem(index: 4, title: "발주 내역", icon: "doc.text")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch tabRouter.selectedIndex {
                case 0:
                    DashboardView(
                        receiptListViewModel: receiptListViewModel,
                        historyViewModel: historyViewModel,
                        tabRouter: tabRouter
                    )
                case 1:
                    ReceiptListView(receiptListViewModel: receiptListViewModel)
                case 2:
                    MyReceiptListView(receiptListViewModel: receiptListViewModel)
                case 3:
                    OrderRequestRootView(
                        historyViewModel: historyViewModel,
                        formVM: receiptCompletionViewModel,
                        tabRouter: tabRouter
                    )
                case 4:
                    OrderHistoryView(historyViewModel: historyViewModel)
                default:
                    DashboardView(
                        receiptListViewModel: receiptListViewModel,
                        historyViewModel: historyViewModel,
                        tabRouter: tabRouter
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack(spacing: 12) {
                ForEach(tabs) { tab in
                    bottomBarItem(tab: tab)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(
                AppColor.surface
                    .ignoresSafeArea()
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AppColor.mainBorderGray.opacity(0.6)),
                alignment: .top
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func bottomBarItem(tab: TabItem) -> some View {
        let isSelected = tabRouter.selectedIndex == tab.index
        return Button {
            tabRouter.selectedIndex = tab.index
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? AppColor.surface : AppColor.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AppColor.mainColor : AppColor.surfaceMuted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppColor.mainColor.opacity(0.3) : AppColor.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TabItem: Identifiable {
    let index: Int
    let title: String
    let icon: String
    var id: Int { index }
}

#Preview {
    BottomBar()
}
