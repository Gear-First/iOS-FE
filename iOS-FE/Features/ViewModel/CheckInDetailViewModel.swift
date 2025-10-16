import Foundation

final class CheckInDetailViewModel: ObservableObject {
    @Published var item: CheckInItem
    @Published var completionFormVM = CheckInCompletionViewModel()
    
    init(item: CheckInItem) {
        self.item = item
    }
    
    // 접수 api
    func startRepair() {
        guard let url = URL(string: "http://34.160.169.52/receipt/api/v1/startRepair") else { return }
        
        // JSON body에 receiptHistoryId만 담기
        let bodyData = item.id.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        // 요청 전송
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 오류:", error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if (200..<300).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {   // 반드시 메인 큐에서 변경
                                self.item.status = .inProgress
                            }
                print("수리 시작 성공:", self.item.id)
            } else {
                print("서버 응답 코드:", httpResponse.statusCode)
            }
        }.resume()
    }
    
    // 상태 업데이트 (예: 접수 → 수리중 → 완료)
    func updateStatus(to newStatus: CheckInStatus, manager: String? = nil) {
        item.status = newStatus
        item.manager = manager
    }
    
    // 완료 정보 반영
    func applyCompletionInfo(_ info: CompletionInfo) {
        var infos = item.completionInfos ?? []
        infos.append(info)
        item.completionInfos = infos
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

extension CheckInDetailViewModel {
    func applyMultipleCompletionInfo(_ infos: [CompletionInfo]) {
        item.status = .completed
        item.completionInfos = infos
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if
            let start = formatter.date(from: item.date),
            let end = formatter.date(from: infos.first?.completionDate ?? "")
        {
            item.leadTimeDays = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        } else {
            item.leadTimeDays = nil
        }
    }
}
