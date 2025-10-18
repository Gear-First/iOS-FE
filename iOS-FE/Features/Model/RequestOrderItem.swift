import Foundation
import SwiftUI

struct OrderItem: Identifiable, Codable {
    // MARK: - 고유 식별자
    let id: String           // 로컬 고유 ID
    let _id: String?         // 서버에서 받은 MongoDB ObjectID 등

    // MARK: - 기본 정보
    let inventoryCode: String
    let inventoryName: String
    let quantity: Int

    // MARK: - 날짜 정보
    var requestDate: String?        // 승인대기
    var approvalDate: String?       // 승인 완료
    var deliveryStartDate: String?  // 출고중
    var deliveredDate: String?      // 납품 완료

    // MARK: - 상태
    var orderStatus: OrderStatus

    // MARK: - 생성자
    init(
        inventoryCode: String,
        inventoryName: String,
        quantity: Int,
        requestDate: String? = nil,
        approvalDate: String? = nil,
        deliveryStartDate: String? = nil,
        deliveredDate: String? = nil,
        id: String? = nil,
        orderStatus: OrderStatus = .PENDING
    ) {
        self.inventoryCode = inventoryCode
        self.inventoryName = inventoryName
        self.quantity = quantity
        self.requestDate = requestDate
        self.approvalDate = approvalDate
        self.deliveryStartDate = deliveryStartDate
        self.deliveredDate = deliveredDate
        self.id = id ?? UUID().uuidString
        self._id = id
        self.orderStatus = orderStatus
    }
}

enum OrderStatus: String, Codable, CaseIterable, Identifiable {
    case PENDING = "승인 대기"
    case APPROVED = "승인 완료"
    case REJECTED = "반려"
    case SHIPPED = "출고 중"
    case COMPLETED = "납품 완료"
    case CANCELLED = "취소"

    var id: String { rawValue }

    // MARK: - UI 표시 이름
    var displayName: String {
        switch self {
        case .PENDING: return "승인 대기"
        case .APPROVED: return "승인 완료"
        case .REJECTED: return "반려"
        case .SHIPPED: return "출고 중"
        case .COMPLETED: return "납품 완료"
        case .CANCELLED: return "취소"
        }
    }

    var badgeColor: Color {
        switch self {
        case .PENDING: return AppColor.mainBlue
        case .APPROVED: return AppColor.mainGreen
        case .SHIPPED: return AppColor.mainYellow
        case .COMPLETED: return AppColor.mainGray
        case .REJECTED: return AppColor.mainRed
        case .CANCELLED: return AppColor.mainRed.opacity(0.8)
        }
    }

    var progressValue: Double {
        switch self {
        case .PENDING: return 0.2
        case .APPROVED: return 0.4
        case .SHIPPED: return 0.7
        case .COMPLETED: return 1.0
        case .REJECTED, .CANCELLED: return 0.0
        }
    }
}

struct VehicleResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [Vehicle]
}

struct Vehicle: Codable, Identifiable {
    var id: String { repairNumber }
    let repairNumber: String
    let plateNumber: String
    let model: String
    let manufacturer: String
    let registeredDate: String
//    let carModelId: Int? = 1 // 기본값 추가
}

struct PartResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [PartItem]
}

struct PartItem: Codable, Identifiable {
    var id: String { inventoryId }
    let inventoryId: String
    let inventoryName: String
}

struct OrderStatusResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [OrderStatusItem]
}

struct OrderStatusItem: Codable, Identifiable {
    var id: String { repairNumber }
    let repairNumber: String
    let status: String
    let items: [OrderStatusPart]
}

struct OrderStatusPart: Codable, Identifiable {
    let inventoryId: Int
    let name: String
    let quantity: Int
    
    var id: Int { inventoryId }
}
