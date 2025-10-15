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

    // MARK: - 목데이터
    static let mockItems: [OrderItem] = [
        OrderItem(
            inventoryCode: "INV-001",
            inventoryName: "브레이크 패드",
            quantity: 5,
            requestDate: "2025-10-04",
            orderStatus: .승인대기
        ),
        OrderItem(
            inventoryCode: "INV-002",
            inventoryName: "에어필터",
            quantity: 2,
            requestDate: "2025-10-03",
            approvalDate: "2025-10-04",
            orderStatus: .승인완료
        ),
        OrderItem(
            inventoryCode: "INV-003",
            inventoryName: "오일필터1",
            quantity: 1,
            requestDate: "2025-10-04",
            orderStatus: .취소
        ),
        OrderItem(
            inventoryCode: "INV-004",
            inventoryName: "오일필터",
            quantity: 1,
            requestDate: "2025-10-05",
            deliveredDate: "2025-10-06",
            orderStatus: .납품완료
        ),
        OrderItem(
            inventoryCode: "INV-005",
            inventoryName: "오일필터",
            quantity: 1,
            requestDate: "2025-10-06",
            deliveryStartDate: "2025-10-07",
            orderStatus: .출고중
        ),
        OrderItem(
            inventoryCode: "INV-006",
            inventoryName: "오일필터",
            quantity: 1,
            requestDate: "2025-10-07",
            orderStatus: .반려
        )
    ]
    
    // MARK: - Init
    /// 초기화 시 목데이터 사용 가능, 나중에 API 데이터로 교체 가능
    init(useMockData: Bool = true, items: [OrderItem] = []) {
        if useMockData {
            self.items = Self.mockItems
        } else {
            self.items = items
        }
    }

    var filteredItems: [OrderItem] {
        items.filter { selectedFilter.matches($0.orderStatus) }
    }
    
    // MARK: - Methods
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
