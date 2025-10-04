import Foundation
import SwiftUI

class OrderRequestViewModel: ObservableObject {
    @Published var orderName: String = ""
    @Published var orderQuantity: Int = 0
    @Published var orderCode: String = ""
    
    // 날짜 변환
    @Published var requestDate: Date = Date() {
        didSet {
            // 날짜 선택 시 문자열 자동 반영
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let newString = formatter.string(from: requestDate)
            
            if rawDateInput != newString {
                rawDateInput = newString
            }
        }
    }
    @Published var rawDateInput: String = ""
    
    // 요청 버튼
    func submitRequestOrder() -> OrderItem {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: requestDate)
        
        return OrderItem(
            inventoryCode: "AB123",
            inventoryName: orderName,
            quantity: orderQuantity,
            requestDate: dateString,
            id: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16)),
            status: "요청됨" // 목 데이터
        )
    }
    
}
