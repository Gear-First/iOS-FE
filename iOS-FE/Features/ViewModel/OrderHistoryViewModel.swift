import Foundation
import SwiftUI

enum OrderFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case requested = "요청됨"
    case cancelled = "취소됨"
    
    var id: String { self.rawValue }
}

class OrderHistoryViewModel: ObservableObject {
    @Published var items: [OrderItem] = []
    @Published var selectedFilter: OrderFilter = .all

    init(items: [OrderItem] = []) {
        self.items = items
    }

    var filteredItems: [OrderItem] {
            switch selectedFilter {
            case .all:
                return items
            default:
                return items.filter { ($0.status ?? "").trimmingCharacters(in: .whitespacesAndNewlines) == selectedFilter.rawValue }
            }
        }
    
    func addNewItem(_ item: OrderItem) {
        items.insert(item, at: 0)
    }
    
    func cancelOrder(_ item: OrderItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].status = "취소됨"
        print("요청 \(item.id ?? "") 취소 완료")
    }
}
