import Foundation

final class CheckInCompletionViewModel: ObservableObject {
    @Published var items: [RepairItemForm] = [RepairItemForm()]  // 시작 시 하나
    
    // 오늘 날짜 고정
    var todayString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    var totalSum: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    init() {
        let first = RepairItemForm()
        first.parentViewModel = self
        items = [first]
    }
    
    func addItem() {
        let new = RepairItemForm()
        new.parentViewModel = self
        items.append(new)
    }
    
    func canAddNewItem() -> Bool {
        for form in items {
            if form.description.trimmingCharacters(in: .whitespaces).isEmpty ||
               form.cause.trimmingCharacters(in: .whitespaces).isEmpty ||
               form.partName.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
        }
        return true
    }
    
    func removeItem(_ id: UUID) {
        items.removeAll { $0.id == id }
    }
    
    func buildCompletionInfo() -> [CheckInDetailViewModel.CompletionInfo]? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())
        
        let mapped: [CheckInDetailViewModel.CompletionInfo] = items.compactMap { form in
            guard !form.description.isEmpty,
                  !form.cause.isEmpty,
                  !form.partName.isEmpty
            else { return nil }
            
            return CheckInDetailViewModel.CompletionInfo(
                completionDate: today,
                repairDescription: form.description,
                cause: form.cause,
                partName: form.partName,
                partQuantity: form.quantity,
                partPrice: form.unitPrice,
                totalPrice: form.totalPrice
            )
        }
        
        return mapped.isEmpty ? nil : mapped
    }
    
    // 10,000 ~ 1,000,000원 사이 랜덤 가격을 자동 지정
    func autofillRandomPrice(for form: RepairItemForm) {
        let random = Double(Int.random(in: 10...1000) * 1000)
        form.unitPrice = random
    }
}
