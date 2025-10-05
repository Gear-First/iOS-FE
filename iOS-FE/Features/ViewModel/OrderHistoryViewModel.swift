import Foundation
import SwiftUI

class OrderHistoryViewModel: ObservableObject {
    @Published var items: [OrderItem] = []

    init(items: [OrderItem] = []) {
        self.items = items
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
