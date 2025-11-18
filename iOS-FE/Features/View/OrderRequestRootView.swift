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
            OrderRequestView(
                historyViewModel: historyViewModel,
                formVM: formVM,
                initialVehicle: nil,  // 발주요청 탭에서는 차량 정보 없음
                receiptNum: ""  // 발주요청 탭에서는 접수번호 없음
            ) { order in
                // 발주 생성 완료 시 상세 화면으로 이동
                createdOrder = order
                showOrderDetail = true
            }
            .navigationTitle("부품 요청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $showOrderDetail) {
                createdOrderDetailView()
            }
        }
    }
    
    @ViewBuilder
    private func createdOrderDetailView() -> some View {
        if let order = createdOrder {
            OrderDetailView(
                orderId: order.orderId,
                onCancel: {
                    Task {
                        await self.historyViewModel.cancelOrder(
                            orderId: order.orderId
                        )
                        // 취소 후 발주 내역 새로고침
                        await self.historyViewModel.refreshOrders()
                    }
                },
                onBack: {
                    // 뒤로가기 시 발주 요청 화면으로 돌아감
                    createdOrder = nil
                    showOrderDetail = false
                }
            )
        } else {
            ProgressView("불러오는 중...")
        }
    }

}
