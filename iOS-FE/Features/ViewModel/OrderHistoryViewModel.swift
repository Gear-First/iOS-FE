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
}
