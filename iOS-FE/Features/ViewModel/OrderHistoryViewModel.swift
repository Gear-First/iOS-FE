import Foundation
import SwiftUI

final class OrderHistoryViewModel: ObservableObject {
    
    enum OrderFilter: String, CaseIterable, Identifiable {
        case all = "전체"
        case inProgress = "진행 중"
        case completed = "완료"
        case cancelled = "취소 / 반려"

        var id: String { rawValue }

        func matches(_ status: OrderStatus) -> Bool {
            switch self {
            case .all:
                return true
            case .inProgress:
                return [.pending, .approved, .shipping].contains(status)
            case .completed:
                return [.delivered].contains(status)
            case .cancelled:
                return [.cancelled, .rejected].contains(status)
            }
        }
    }
    
    @Published var items: [OrderItem] = []
    @Published var selectedFilter: OrderFilter = .all
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - 필터링된 아이템
    var filteredItems: [OrderItem] {
        items.filter { selectedFilter.matches($0.orderStatus) }
    }
    
    func mapServerStatus(_ status: String) -> OrderStatus {
        switch status {
        case "승인대기": return .pending
        case "승인완료": return .approved
        case "출고중": return .shipping
        case "납품완료": return .delivered
        case "취소": return .cancelled
        case "반려": return .rejected
        default: return .pending
        }
    }
    
    // MARK: - API 호출
    @MainActor
    func fetchOrders(branchId: Int, filterType: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let apiItems = try await PurchaseOrderAPI.fetchOrderStatus(branchId: branchId, filterType: filterType)
            
            // 서버 데이터 → OrderItem 변환
            self.items = apiItems.flatMap { statusItem in
                statusItem.items.map { detail in
                    OrderItem(
                        inventoryCode: "\(detail.inventoryId)",
                        inventoryName: detail.name,
                        quantity: detail.quantity,
                        requestDate: nil,
                        id: statusItem.repairNumber,
                        orderStatus: mapServerStatus(statusItem.status)
                    )
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            print("fetchOrders error: \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - 로컬 데이터 수정
    func addNewItem(_ item: OrderItem) {
        items.insert(item, at: 0)
    }
    
    func updateOrderStatus(_ item: OrderItem, to newStatus: OrderStatus) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].orderStatus = newStatus
    }
    
    func cancelOrder(_ item: OrderItem) {
        updateOrderStatus(item, to: .cancelled)
    }
}
