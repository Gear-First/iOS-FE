import Foundation
import SwiftUI

@MainActor
final class OrderHistoryViewModel: ObservableObject {
    
    // MARK: - 필터
    enum OrderFilter: String, CaseIterable, Identifiable {
        case all = "전체"
        case inProgress = "진행 중"
        case completed = "완료"
        case cancelled = "취소 / 반려"

        var id: String { rawValue }

        func matches(_ status: String) -> Bool {
            switch self {
            case .all: return true
            case .inProgress: return ["PENDING", "APPROVED", "SHIPPED"].contains(status)
            case .completed: return ["COMPLETED"].contains(status)
            case .cancelled: return ["CANCELLED", "REJECTED"].contains(status)
            }
        }
    }
    
    // MARK: - Published
    @Published var orders: [OrderHistoryItem] = []
    @Published var selectedFilter: OrderFilter = .all
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - 필터링된 주문
    var filteredOrders: [OrderHistoryItem] {
        orders.filter { selectedFilter.matches($0.status) }
    }
    
    // MARK: - 서버에서 주문 불러오기
    func fetchOrders(branchId: Int, engineerId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            // 서버에서 바로 [OrderHistoryItem] 받음
            let ordersFromServer = try await PurchaseOrderAPI.fetchOrderStatus(branchId: branchId, engineerId: engineerId)
            self.orders = ordersFromServer
        } catch {
            errorMessage = error.localizedDescription
            print("fetchOrders error: \(error.localizedDescription)")
        }

        isLoading = false
    }
    
    // MARK: - 주문 상태 변경
    func cancelOrder(_ order: OrderHistoryItem) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        var updated = orders[index]
        updated.status = "CANCELLED"
        orders[index] = updated
    }
    
    // MARK: - 새 주문 추가 (서버에서 받은 데이터 그대로)
    func addNewOrder(_ newOrder: OrderHistoryItem) {
        orders.insert(newOrder, at: 0)
    }
}
