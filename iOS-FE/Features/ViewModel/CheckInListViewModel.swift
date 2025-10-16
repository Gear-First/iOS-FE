import Foundation
import Combine
import SwiftUI
import Foundation

@MainActor
class CheckInListViewModel: ObservableObject {
    @Published var items: [CheckInItem] = []
    @Published var isLoading: Bool = false
    
    func fetchReceipts() async {
        guard let url = URL(string: "http://34.160.169.52/receipt/api/v1/getUnprocessedReceipt") else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ReceiptResponse.self, from: data)
            items = decoded.data.map { $0.toCheckInItem() }
        } catch {
            print("디코딩 오류:", error)
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
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ReceiptResponse.self, from: data)
            
            if decoded.success {
                items = decoded.data.map { $0.toCheckInItem() }
                print("불러오기 성공: \(items.count)건")
            } else {
                print("서버 응답 실패: \(decoded.message)")
            }
        } catch {
            print("네트워크 오류:", error)
        }
    }
    
}

