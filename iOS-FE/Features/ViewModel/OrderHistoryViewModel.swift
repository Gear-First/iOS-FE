import Foundation
import SwiftUI

@MainActor
final class OrderHistoryViewModel: ObservableObject {
    
    // MARK: - 필터
    enum OrderFilter: String, CaseIterable, Identifiable {
        case all = "전체"
        case ready = "진행 중"
        case completed = "완료"
        case cancelled = "취소 / 반려"
        
        var id: String { rawValue }
        
        func matches(_ status: String) -> Bool {
            switch self {
            case .all: return true
            case .ready: return ["PENDING", "APPROVED", "SHIPPED"].contains(status)
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
    @Published var searchText: String = ""
    @Published private(set) var cancellingOrderIds: Set<Int> = []  // 개별 취소 로딩 상태 (주문 ID 기준)
    
    // MARK: - 필터링 + 검색 적용
    var filteredOrders: [OrderHistoryItem] {
        orders
            .filter { selectedFilter.matches($0.status) } // 상태 필터
            .filter { order in
                guard !searchText.isEmpty else { return true }
                let searchLower = searchText.lowercased()
                // 발주번호 또는 부품명 중 하나라도 포함되면 true
                return (order.orderNumber ?? "").lowercased().contains(searchLower) ||
                       order.items.contains { $0.partName.lowercased().contains(searchLower) }

            }
    }
    
    // MARK: - 서버에서 전체 주문 불러오기 (초기 로딩)
    func fetchAllOrders(branchCode: String, engineerId: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let ordersFromServer = try await PurchaseOrderAPI.fetchOrderAllStatus(branchCode: branchCode, engineerId: engineerId)
            self.orders = ordersFromServer
        } catch {
            errorMessage = error.localizedDescription
            print("fetchAllOrders error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 새로고침: 전체 데이터 다시 가져오기
    func refreshOrders(branchCode: String, engineerId: Int) async {
        await fetchAllOrders(branchCode: branchCode, engineerId: engineerId)
    }
    
    // MARK: - 주문 상태 변경 (Mock)
//    func cancelOrder(_ order: OrderHistoryItem) {
//        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
//        var updated = orders[index]
//        updated.status = "CANCELLED"
//        orders[index] = updated
//    }
    
    // MARK: - 새 주문 추가 (클라이언트)
    func addNewOrder(_ newOrder: OrderHistoryItem) {
        orders.insert(newOrder, at: 0)
    }
    
    // MARK: - 취소 (업데이트 + 실패 시 롤백)
    func cancelOrder(orderId: Int, branchCode: String, engineerId: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let res = try await PurchaseOrderAPI.cancelOrder(
                orderId: orderId,
                branchCode: branchCode,
                engineerId: engineerId
            )
            
            guard res.success else {
                errorMessage = res.message
                return
            }
            
            if let idx = orders.firstIndex(where: { $0.orderId == orderId }) {
                var updated = orders[idx]
                updated.status = "CANCELLED"
                orders[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
            print("cancel(orderId:) error: \(error.localizedDescription)")
        }
    }
}
