import Foundation
import SwiftUICore

struct OrderItem: Identifiable, Codable {
    var id: String {
        _id ?? UUID().uuidString
    }

    let _id: String?
    let inventoryCode: String
    let inventoryName: String
    let quantity: Int
    let requestDate: String
    var status: String?

    init(
        inventoryCode: String,
        inventoryName: String,
        quantity: Int,
        requestDate: String,
        id: String? = nil,
        status: String? = nil
    ) {
        self.inventoryCode = inventoryCode
        self.inventoryName = inventoryName
        self.quantity = quantity
        self.requestDate = requestDate
        self._id = id
        self.status = status
    }
}


enum OrderStatus: String {
    case 승인대기 = "승인 대기"
    case 승인완료 = "승인 완료"
    case 반려 = "반려"
    case 출고중 = "출고 중"
    case 납품완료 = "납품 완료"
    case 취소 = "취소"

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
}
