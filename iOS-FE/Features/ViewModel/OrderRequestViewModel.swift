import Foundation
import SwiftUI

final class OrderRequestViewModel: ObservableObject {
    // MARK: - 차량 관련
    @Published var selectedCarNumber: String = ""
    @Published var selectedCarType: String = ""

    // MARK: - 부품 관련
    @Published var orderName: String = ""     // 부품명
    @Published var orderCode: String = ""     // 부품코드

    // MARK: - 수량
    @Published var orderQuantity: Int = 1

    // MARK: - 날짜
    @Published var requestDate: Date = Date()

    // MARK: - 포맷터
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    // MARK: - 주문 생성
    func submitRequestOrder() -> OrderItem {
        let formattedDate = dateFormatter.string(from: requestDate)
        return OrderItem(
            inventoryCode: orderCode.isEmpty ? "AUTO" : orderCode,
            inventoryName: orderName.isEmpty ? "미지정 부품" : orderName,
            quantity: orderQuantity,
            requestDate: formattedDate,
            id: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16)),
            orderStatus: OrderStatus.승인대기
        )
    }

    // MARK: - 유효성 검사
    func isValid() -> Bool {
        return !selectedCarNumber.isEmpty &&
               !selectedCarType.isEmpty &&
               !orderName.isEmpty &&
               !orderCode.isEmpty &&
               orderQuantity > 0
    }

    // MARK: - 폼 초기화
    func resetForm() {
        selectedCarNumber = ""
        selectedCarType = ""
        orderName = ""
        orderCode = ""
        orderQuantity = 1
        requestDate = Date()
    }
}
