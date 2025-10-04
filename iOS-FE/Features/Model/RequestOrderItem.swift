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
    let status: String?

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
    case 요청됨 = "요청됨"
    case 승인됨 = "승인됨"
    case 완료됨 = "완료됨"
    case 취소됨 = "취소됨"

    var badgeColor: Color {
        switch self {
        case .요청됨: return .blue
        case .승인됨: return .green
        case .완료됨: return .gray
        case .취소됨: return .red
        }
    }
}
