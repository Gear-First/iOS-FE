import SwiftUI

struct OrderRequestRootView: View {
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @ObservedObject var formVM: ReceiptCompletionViewModel
    var initialVehicle: ReceiptVehicle? = nil
    @ObservedObject var tabRouter: TabRouter
    @State private var createdOrder: OrderHistoryItem?
    @State private var showOrderDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                OrderRequestView(
                    historyViewModel: historyViewModel,
                    formVM: formVM,
                    initialVehicle: nil,  // 발주요청 탭에서는 차량 정보 없음
                    receiptNum: ""  // 발주요청 탭에서는 접수번호 없음
                ) { order in
                    createdOrder = order
                    showOrderDetail = true
                }
                
                NavigationLink(
                    destination: createdOrderDetailView(),
                    isActive: $showOrderDetail
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationTitle("부품 요청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    @ViewBuilder
    private func createdOrderDetailView() -> some View {
        if let order = createdOrder {
            OrderDetailView(
                order: Binding(
                    get: { order },
                    set: { createdOrder = $0 }
                ),
                onCancel: {
                    Task {
                        await self.historyViewModel.cancelOrder(
                            orderId: order.orderId,
                            branchCode: "서울 대리점",
                            engineerId: 10
                        )
                        self.createdOrder?.status = "CANCELLED"
                    }
                },
                onBack: {
                    createdOrder = nil
                    showOrderDetail = false
                    tabRouter.selectedIndex = 3
                }
            )
        } else {
            EmptyView()
        }
    }

}
