import Foundation
import SwiftUI

class OrderHistoryViewModel: ObservableObject {
    
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
                return [.승인대기, .승인완료, .출고중].contains(status)
            case .completed:
                return [.납품완료].contains(status)
            case .cancelled:
                return [.취소, .반려].contains(status)
            }
        }
    }
    
    @Published var items: [OrderItem] = []
    @Published var selectedFilter: OrderFilter = .all

    init(items: [OrderItem] = []) {
        self.items = items
    }

    var filteredItems: [OrderItem] {
        items.filter { selectedFilter.matches($0.orderStatus) }
    }
    
    func addNewItem(_ item: OrderItem) {
        items.insert(item, at: 0)
    }
    
    func updateOrderStatus(_ item: OrderItem, to newStatus: OrderStatus) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].orderStatus = newStatus
    }
    
    func cancelOrder(_ item: OrderItem) {
        updateOrderStatus(item, to: .취소)
    }
}
