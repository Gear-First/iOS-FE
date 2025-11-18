import SwiftUI

final class RepairItemForm: ObservableObject, Identifiable {
    let id = UUID()
    weak var parentViewModel: ReceiptCompletionViewModel?
    
    @Published var description: String = ""
    @Published var cause: String = ""
    @Published var parts: [RepairPartForm] = [RepairPartForm()]
}
