import Foundation
import Combine
import SwiftUI
import Foundation

class CheckInListViewModel: ObservableObject {
    @Published var items: [CheckInItem] = []
    
    func fetchReceipts() async {
        guard let url = URL(string: "http://34.160.169.52/receipt/api/v1/getUnprocessedReceipt") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ReceiptResponse.self, from: data)
            
            DispatchQueue.main.async {
                print("서버 응답: \(decoded.data.count)건")
                self.items = decoded.data.map { $0.toCheckInItem() }
                print("변환된 아이템 수: \(self.items.count)")
                print("첫번째 아이템:", self.items.first ?? "없음")
            }
        } catch {
            print("디코딩 오류:", error)
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let str = String(data: data, encoding: .utf8) {
                print("원본 응답:\n\(str)")
            }
        }
    }
    
    func fetchMyReceipts() async {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            
            let today = Date()
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today)!
            
            let startDate = formatter.string(from: oneYearAgo)
            let endDate = formatter.string(from: today)
            
            let urlString = "http://34.160.169.52/receipt/api/v1/getMyReceipt?startDate=\(startDate)&endDate=\(endDate)"
            print(today, oneYearAgo)
            
            guard let url = URL(string: urlString) else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode(ReceiptResponse.self, from: data)
                
                if decoded.success {
                    DispatchQueue.main.async {
                        self.items = decoded.data.map { $0.toCheckInItem() }
                        print(startDate, endDate)
                        print(urlString)
                    }
                } else {
                    print("⚠️ 서버 응답 실패: \(decoded.message)")
                }
            } catch {
                print("❌ 네트워크 오류:", error)
            }
        }

}

