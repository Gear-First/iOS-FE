import Foundation

final class ReceiptCompletionViewModel: ObservableObject {
    @Published var items: [RepairItemForm] = [RepairItemForm()]
    
    // API에서 가져온 관련 발주 부품
        @Published var completeParts: [OrderItem] = []
    
    init() {
        if items.isEmpty {
            let first = RepairItemForm()
            first.parentViewModel = self
            items.append(first)
            print("초기 RepairItemForm 생성됨 \(first.id)")
        }
    }
    
    // MARK: - 오늘 날짜 문자열
    var todayString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f.string(from: Date())
    }
    
    // MARK: - 항목 추가 / 삭제
    func addItem() {
        let new = RepairItemForm()
        new.parentViewModel = self
        items.append(new)
    }
    
    func removeItem(_ id: UUID) {
        items.removeAll { $0.id == id }
    }
    
    // MARK: - 항목 유효성 검사
    func isCompletionValid() -> Bool {
            for form in items {
                // 수리 내용 & 원인은 필수
                if form.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    form.cause.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return false
                }
            }
            return true
        }
    
    // MARK: - 수리 요청 데이터 구성
    func buildRepairRequest(receiptId: String) -> RepairRequest {
        let details = items.map { item in
            RepairDetailRequest(
                repairDetail: item.description,
                repairCause: item.cause,
                usedParts: item.parts.map { part in
                    UsedPartRequest(
                        partId: part.partId ?? Int.random(in: 100...999), // 더미 id 보정
                        partName: part.partName,
                        quantity: part.quantity
                    )
                }
            )
        }
        return RepairRequest(
            receiptHistoryId: receiptId,
            repairDetailRequests: details
        )
    }
    
    // MARK: - 임시: 랜덤 단가 채우기
    func autofillRandomPrice(for part: RepairPartForm) {
        let random = Double(Int.random(in: 10...1000) * 1000)
        part.unitPrice = random
    }
    
    func resetForm() {
        items = [RepairItemForm()] // 항목 하나만 남기고 리셋
    }
    
    // MARK: - 수리 상세 등록 API 호출
    func submitRepairDetails(receiptId: String, formVM: ReceiptCompletionViewModel) async {
            let requestBody = buildRepairRequest(receiptId: receiptId)

            do {
                try await ReceiptAPI.submitRepairDetail(request: requestBody)
                print("수리 상세 등록 성공")
            } catch {
                print("수리 상세 등록 실패:", error)
            }
        }
    
    // receiptId, 차량번호, 지점, 엔지니어 아이디로 부품 조회
       func fetchCompleteParts(receiptNum: String, vehicleNumber: String, branchCode: String = "서울 대리점", engineerId: Int = 10) async {
           do {
               let parts = try await ReceiptAPI.fetchCompleteParts(
                   receiptNum: receiptNum,
                   vehicleNumber: vehicleNumber,
                   branchCode: branchCode,
                   engineerId: engineerId
               )
               DispatchQueue.main.async {
                   self.completeParts = parts
               }
           } catch {
               print("발주 부품 조회 실패:", error)
           }
       }
}

