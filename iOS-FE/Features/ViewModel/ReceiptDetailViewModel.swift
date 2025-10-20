import Foundation

final class ReceiptDetailViewModel: ObservableObject {
    @Published var item: ReceiptItem
    @Published var completionFormVM = ReceiptCompletionViewModel()
    
    init(item: ReceiptItem) {
        self.item = item
    }
    
    // MARK: - 접수 상태를 수리중으로 변경하는 API 호출
    func startRepair() {
            Task {
                do {
                    try await ReceiptAPI.startRepair(receiptId: item.id)
                    item.status = .inProgress
                    await fetchReceiptDetail(id: item.id)
                    print("수리 시작 성공:", item.id)
                } catch {
                    print("수리 시작 실패:", error)
                }
            }
        }
    
    // MARK: - 완료 정보 반영
    func applyMultipleCompletionInfo(_ infos: [CompletionInfo]) {
        item.status = .completed
        item.completionInfos = infos
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if
            let start = formatter.date(from: item.date),
            let end = formatter.date(from: infos.first?.completionDate ?? "")
        {
            item.leadTimeDays = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        } else {
            item.leadTimeDays = nil
        }
    }

    // MARK: - 상세 정보 API 호출
    @MainActor
    func fetchReceiptDetail(id: String) async {
        do {
            let updatedItem = try await ReceiptAPI.fetchReceiptDetail(receiptId: id)
            self.item = updatedItem
            print("상세 조회 성공:", id)
        } catch {
            print("상세 조회 실패:", error)
        }
    }
    
    // MARK: - 수리 완료 항목 구조체
    struct CompletionInfo {
        let completionDate: String      // 수리 완료일
        let repairDescription: String   // 수리 내용
        let cause: String               // 원인
        let partName: String            // 사용 부품명
        let partQuantity: Int           // 부품 수량
        let partPrice: Double           // 단가
        let totalPrice: Double          // 총액 (수량 * 단가)
    }
}
