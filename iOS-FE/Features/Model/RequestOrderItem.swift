import Foundation
import SwiftUI

struct OrderItem: Identifiable, Codable {
    let id: String

    let _id: String?
    let inventoryCode: String
    let inventoryName: String
    let quantity: Int
    
    var requestDate: String       // 승인대기
    var approvalDate: String?     // 승인 완료
    var deliveryStartDate: String?// 출고중
    var deliveredDate: String?    // 납품 완료
    
    var orderStatus: OrderStatus

    init(
        inventoryCode: String,
        inventoryName: String,
        quantity: Int,
        requestDate: String,
        approvalDate: String? = nil,
        deliveryStartDate: String? = nil,
        deliveredDate: String? = nil,
        id: String? = nil,
        orderStatus: OrderStatus = .승인대기
    ) {
        self.inventoryCode = inventoryCode
        self.inventoryName = inventoryName
        self.quantity = quantity
        self.requestDate = requestDate
        self.approvalDate = approvalDate
        self.deliveryStartDate = deliveryStartDate
        self.deliveredDate = deliveredDate
        self.id = id ?? String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16))
        self._id = id
        self.orderStatus = orderStatus
    }
}


// MARK: - 발주 상태 Enum
enum OrderStatus: String, Codable, CaseIterable, Identifiable {
    case 승인대기 = "승인 대기"
    case 승인완료 = "승인 완료"
    case 반려 = "반려"
    case 출고중 = "출고 중"
    case 납품완료 = "납품 완료"
    case 취소 = "취소"

    var id: String { rawValue }

    var badgeColor: Color {
        switch self {
        case .승인대기: return AppColor.mainBlue
        case .승인완료: return AppColor.mainGreen
        case .출고중: return AppColor.mainYellow
        case .납품완료: return AppColor.mainGray
        case .반려: return AppColor.mainRed
        case .취소: return AppColor.mainRed.opacity(0.8)
        }
    }
    
    /// 진행도 단계 (0~1)
    var progressValue: Double {
        switch self {
        case .승인대기: return 0.2
        case .승인완료: return 0.4
        case .출고중: return 0.7
        case .납품완료: return 1.0
        case .반려, .취소: return 0.0
        }
    }
}


extension OrderItem {
    /// CheckInItem 객체로부터 OrderItem을 생성하는 변환 이니셜라이저
    /// 부품 이름, 코드, 수량 등 필수 정보가 없으면 생성에 실패하고 nil을 반환한다.
    init?(from checkInItem: CheckInItem) {
        // 1. 주문 생성에 필요한 필수 정보가 있는지 확인한다.
        guard
            let partCode = checkInItem.partCode, !partCode.isEmpty,
            let partName = checkInItem.partName, !partName.isEmpty,
            let quantity = checkInItem.partQuantity, quantity > 0
        else {
            // 필수 정보가 없으면 변환 실패
            return nil
        }
        
        // 2. OrderItem의 각 프로퍼티에 값을 매핑한다.
        self.id = "ORD-\(UUID().uuidString.prefix(8))" // 주문 요청이므로 새로운 주문 ID를 생성
        
        self._id = id
        self.inventoryCode = partCode
        self.inventoryName = partName
        self.quantity = quantity
        
        // 3. 날짜는 '주문 요청일'이므로 현재 시각을 사용한다.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.requestDate = formatter.string(from: Date())
        
        // 4. 나머지 상태 관련 프로퍼티는 초기값으로 설정한다.
        self.approvalDate = nil
        self.deliveryStartDate = nil
        self.deliveredDate = nil
        self.orderStatus = .승인대기 // 새로 요청된 주문의 초기 상태
    }
}


