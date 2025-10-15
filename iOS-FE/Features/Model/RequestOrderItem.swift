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

