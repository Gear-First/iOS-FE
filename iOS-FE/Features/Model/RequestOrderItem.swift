import Foundation
import SwiftUI

// MARK: - OrderItem (발주 요청용)
struct OrderItem: Identifiable, Codable {
    let id: String           // 로컬 고유 ID
    let _id: String?         // 서버에서 받은 MongoDB ObjectID 등

    let inventoryCode: String
    let inventoryName: String
    let quantity: Int

    var requestDate: String?
    var approvalDate: String?
    var deliveryStartDate: String?
    var deliveredDate: String?

    var orderStatus: OrderStatus

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

// MARK: - 주문 상태
enum OrderStatus: String, Codable, CaseIterable, Identifiable {
    case PENDING = "승인 대기"
    case APPROVED = "승인 완료"
    case REJECTED = "반려"
    case SHIPPED = "출고 중"
    case COMPLETED = "납품 완료"
    case CANCELLED = "취소"

    var id: String { rawValue }

    var displayName: String { rawValue }

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

// MARK: - 차량 관련
struct VehicleResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [Vehicle]
}

struct Vehicle: Codable, Identifiable {
    let repairNumber: String
    let plateNumber: String
    let model: String
    let manufacturer: String
    let registeredDate: String

    var id: String { repairNumber }
}

// MARK: - 부품 관련
struct PartResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [PartItem]
}

struct PartItem: Codable, Identifiable {
    let inventoryId: String
    let inventoryName: String

    var id: String { inventoryId }
}

// MARK: - 주문 요청 DTO
struct OrderRequestBody: Codable {
    let vehicleNumber: String
    let vehicleModel: String
    let engineerId: Int
    let branchId: Int
    let items: [OrderItemDTO]
}

struct OrderItemDTO: Codable {
    let inventoryId: Int
    let inventoryName: String
    let inventoryCode: String
    let price: Double
    let quantity: Int
}

// MARK: - 주문 응답
struct OrderResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - 주문 상태 조회
struct OrderStatusResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [OrderStatusItem]
}

struct OrderStatusItem: Codable, Identifiable {
    let repairNumber: String
    var status: String
    let items: [OrderStatusPart]

    var id: String { repairNumber }
}

struct OrderStatusPart: Codable, Identifiable {
    let inventoryId: Int
    let name: String
    let quantity: Int

    var id: Int { inventoryId }
}

// MARK: - 주문 히스토리
struct OrderHistoryResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [OrderHistoryItem]
}

struct OrderHistoryItem: Identifiable, Decodable, Hashable {
    let id: Int
    let orderNumber: String
    var status: String
    let totalPrice: Double
    let requestDate: String
    let approvedDate: String?
    let transferDate: String?
    let completedDate: String?
    let items: [OrderHistoryPart]
}

struct OrderHistoryPart: Identifiable, Decodable, Hashable {
    let id: Int
    let inventoryName: String
    let inventoryCode: String
    let price: Double
    let quantity: Int
    let totalPrice: Double
}

struct MessageResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
}
