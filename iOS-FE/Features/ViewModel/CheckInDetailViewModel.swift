import Foundation

final class CheckInDetailViewModel: ObservableObject {
    @Published var item: CheckInItem
    
    init(item: CheckInItem) {
        self.item = item
    }
    
    // 상태 업데이트 (예: 접수 → 수리중 → 완료)
    func updateStatus(to newStatus: CheckInStatus, manager: String? = nil) {
        item.status = newStatus
        item.manager = manager
    }
    
    // 완료 정보 반영
    func applyCompletionInfo(_ info: CompletionInfo) {
        item.completionDate = info.completionDate
        item.repairDescription = info.repairDescription
        item.cause = info.cause
        item.partName = info.partName
        item.partQuantity = info.partQuantity
        item.partPrice = info.partPrice
        item.totalPrice = info.totalPrice
        item.leadTimeDays = CheckInItem.daysBetween(item.date, info.completionDate)
        item.status = .completed
    }
    
    struct CompletionInfo {
        let completionDate: String
        let repairDescription: String
        let cause: String
        let partName: String
        let partQuantity: Int
        let partPrice: Double
        let totalPrice: Double
    }
}
