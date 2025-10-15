import SwiftUI

final class RepairItemForm: ObservableObject, Identifiable, PartSelectable {
    let id = UUID()
    weak var parentViewModel: CheckInCompletionViewModel?
    
    @Published var description: String = ""
    @Published var cause: String = ""
    @Published var partName: String = ""
    @Published var partCode: String = ""
    @Published var quantity: Int = 1
    @Published var unitPrice: Double = 0.0
    
    var totalPrice: Double { Double(quantity) * unitPrice }

    var name: String {
        get { partName }
        set { partName = newValue }
    }
    var code: String {
        get { partCode }
        set { partCode = newValue }
    }
}
