import SwiftUI

final class RepairItemForm: ObservableObject, Identifiable {
    let id = UUID()
    weak var parentViewModel: CheckInCompletionViewModel?
    
    @Published var description: String = ""
    @Published var cause: String = ""
    @Published var parts: [RepairPartForm] = [RepairPartForm()]
}
