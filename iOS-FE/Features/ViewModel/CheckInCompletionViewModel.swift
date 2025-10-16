import Foundation

final class CheckInCompletionViewModel: ObservableObject {
    @Published var items: [RepairItemForm] = [RepairItemForm()]  // 시작 시 하나
    
    init() {
        if items.isEmpty {
            let first = RepairItemForm()
            first.parentViewModel = self
            items.append(first)
            print("[DEBUG] 초기 RepairItemForm 생성됨 \(first.id)")
        }
    }
    
    // 오늘 날짜 고정
    var todayString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
 
    func addItem() {
        let new = RepairItemForm()
        new.parentViewModel = self
        items.append(new)
    }
    
    func canAddNewItem() -> Bool {
        for form in items {
            // 수리 내용 & 원인은 필수
            if form.description.trimmingCharacters(in: .whitespaces).isEmpty ||
                form.cause.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
            // 부품 리스트 중 하나라도 이름이 비어있으면 안 됨
            if form.parts.contains(where: { $0.partName.trimmingCharacters(in: .whitespaces).isEmpty }) {
                return false
            }
        }
        return true
    }
    
    func removeItem(_ id: UUID) {
        items.removeAll { $0.id == id }
    }

    // 여러 부품을 고려한 구조로 변경
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

    // 10,000 ~ 1,000,000원 사이 랜덤 가격을 자동 지정
    func autofillRandomPrice(for part: RepairPartForm) {
        let random = Double(Int.random(in: 10...1000) * 1000)
        part.unitPrice = random
    }
}

extension CheckInCompletionViewModel {
    func submitRepairDetails(receiptId: String, formVM: CheckInCompletionViewModel) async {
        
        guard let url = URL(string: "http://34.160.169.52/receipt/api/v1/repairDetail") else { return }
        
        let requestBody = formVM.buildRepairRequest(receiptId: receiptId)
        
        do {
            let encoded = try JSONEncoder().encode(requestBody)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = encoded
            print(String(data: encoded, encoding: .utf8)!)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200..<300).contains(httpResponse.statusCode) {
                    print("수리 상세 등록 성공")
                } else {
                    print("서버 오류 코드: \(httpResponse.statusCode)")
                    if let body = String(data: data, encoding: .utf8) {
                        print("Response Body:", body)
                    }
                }
            }
        } catch {
            print("요청 실패:", error)
        }
    }

}
