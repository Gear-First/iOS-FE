import Foundation
import SwiftUI

// MARK: - 주문 상태 Enum
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

// MARK: - OrderStatusMapper
struct OrderStatusMapper {
    static func map(_ status: String) -> OrderStatus {
        switch status.uppercased() {
        case "PENDING": return .PENDING
        case "APPROVED": return .APPROVED
        case "REJECTED": return .REJECTED
        case "SHIPPED": return .SHIPPED
        case "COMPLETED": return .COMPLETED
        case "CANCELLED": return .CANCELLED
        default: return .PENDING
        }
    }

    static func color(for status: String) -> Color {
        map(status).badgeColor
    }
}


// MARK: - 로컬 주문 항목 (UI/로컬 상태용)
struct OrderItem: Identifiable, Codable, Hashable {
    let id: String
    let _id: String?      // 서버 ID 등

    let partCode: String
    let partName: String
    let quantity: Int
    var price: Double

    var requestDate: String?
    var approvalDate: String?
    var deliveryStartDate: String?
    var deliveredDate: String?

    var orderStatus: OrderStatus

    init(
        partCode: String,
        partName: String,
        quantity: Int,
        price: Double? = nil,
        requestDate: String? = nil,
        approvalDate: String? = nil,
        deliveryStartDate: String? = nil,
        deliveredDate: String? = nil,
        id: String? = nil,
        serverId: String? = nil,
        orderStatus: OrderStatus = .PENDING
    ) {
        self.partCode = partCode
        self.partName = partName
        self.quantity = quantity
        self.price = price ?? 0
        self.requestDate = requestDate
        self.approvalDate = approvalDate
        self.deliveryStartDate = deliveryStartDate
        self.deliveredDate = deliveredDate
        self.id = id ?? UUID().uuidString
        self._id = serverId
        self.orderStatus = orderStatus
    }
}

// MARK: - 차량 관련 (서버 응답 DTO + 도메인 모델)
struct VehicleResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [ReceiptVehicle]
}

struct Vehicle: Codable, Identifiable {
    let repairNumber: String
    let plateNumber: String
    let model: String
    let manufacturer: String
    let registeredDate: String

    var id: String { repairNumber }
}

struct ReceiptVehicle: Codable, Identifiable {
    let carNum: String
    let carType: String
    var id: String { carNum }
}

// MARK: - 부품 관련
struct PartResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: PartData
}

struct PartData: Decodable {
    let items: [PartDTO]
    let page: Int
    let size: Int
    let total: Int
}

struct PartDTO: Decodable {
    let id: Int
    let code: String
    let name: String
    let category: CategoryDTO
}

struct CategoryDTO: Decodable {
    let id: Int
    let name: String
}

struct PartItem: Identifiable, Hashable, Codable {
    var id: String
    var partName: String
    var partCode: String
    var categoryName: String
    var price: Double?
}

extension PartItem {
    init(dto: IntegratedPartDTO) {
        self.id = String(dto.id)
        self.partName = dto.name
        self.partCode = dto.code
        self.categoryName = dto.categoryName ?? ""
        self.price = dto.price
    }
}

struct IntegratedPartResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: IntegratedPartData
}

struct IntegratedPartData: Decodable {
    let items: [IntegratedPartDTO]
    let page: Int
    let size: Int
    let total: Int
}

struct IntegratedPartDTO: Decodable {
    let id: Int
    let code: String
    let name: String
    let price: Double?
    let imageUrl: String?
    let safetyStockQty: Int?
    let enabled: Bool?
    let categoryId: Int?
    let categoryName: String?
    let carModelNames: [String]?
}

// MARK: - 주문 생성 요청 DTO
struct OrderCreateRequest: Encodable {
    let vehicleNumber: String?
    let vehicleModel: String?
    let requesterId: Int
    let requesterName: String
    let requesterRole: String
    let requesterCode: String
    let receiptNum: String
    let items: [OrderItemDTO]
}

struct OrderItemDTO: Encodable {
    let partId: Int
    let partName: String
    let partCode: String
    let price: Double
    let quantity: Int

    init(partId: Int, partName: String, partCode: String, price: Double, quantity: Int) {
        self.partId = partId
        self.partName = partName
        self.partCode = partCode
        self.price = price
        self.quantity = quantity
    }

    init(orderItem: OrderItem, partId: Int) {
        self.init(
            partId: partId,
            partName: orderItem.partName,
            partCode: orderItem.partCode,
            price: orderItem.price,
            quantity: orderItem.quantity
        )
    }

    init(part: PartItem, quantity: Int, price: Double = 0, partId: Int? = nil) {
        self.init(
            partId: partId ?? Int(part.partCode) ?? 0,
            partName: part.partName,
            partCode: part.partCode,
            price: price,
            quantity: quantity
        )
    }
}

// MARK: - 주문 생성 응답
struct OrderCreateResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: OrderCreateData
}

struct OrderCreateData: Decodable {
    let orderId: Int
    let orderNumber: String
    let totalQuantity: Int
    let orderStatus: String
    let items: [OrderCreateItem]
}

struct OrderCreateItem: Decodable {
    let id: Int
    let partName: String
    let partCode: String
    let price: Double
    let quantity: Int
    let totalPrice: Double
}
 
// MARK: - 공용 메시지
struct MessageResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
}

// MARK: - 주문 조회 관련 DTO
struct OrderHistoryResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: OrderHistoryPage
}

struct OrderHistoryPage: Decodable {
    let content: [OrderHistoryItem]
    let pageNumber: Int?
    let pageSize: Int?
    let totalElements: Int?
    let totalPages: Int?
    let last: Bool?
    let sort: [String]?
}

struct OrderDetailResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: OrderHistoryItem
}

struct OrderHistoryItem: Decodable, Hashable {
    let orderId: Int
    let orderNumber: String
    var status: String
    let totalPrice: Double
    let requestDate: String?
    let processedDate: String?
    let transferDate: String?
    let completedDate: String?
    let items: [OrderHistoryPart]
}

struct OrderHistoryPart: Identifiable, Decodable, Hashable {
    let id: Int
    let partName: String
    let partCode: String
    let price: Double
    let quantity: Int
    let totalPrice: Double? 
}

// MARK: - ViewModel 확장 (요청 바디 생성)
extension OrderRequestViewModel {
    func makeCreateRequest(
        items: [OrderItem],
        requesterId: Int,
        requesterName: String,
        requesterRole: String,
        requesterCode: String,
        receiptNum: String
    ) -> OrderCreateRequest? {
        guard let v = selectedVehicle else { return nil }

        let itemDTOs = items.map { orderItem -> OrderItemDTO in
            let numericId = Int(orderItem._id ?? "") ?? 0
            return OrderItemDTO(
                partId: numericId,
                partName: orderItem.partName,
                partCode: orderItem.partCode,
                price: orderItem.price,
                quantity: orderItem.quantity
            )
        }

        return OrderCreateRequest(
            vehicleNumber: v.carNum,
            vehicleModel: v.carType,
            requesterId: requesterId,
            requesterName: requesterName,
            requesterRole: requesterRole,
            requesterCode: requesterCode,
            receiptNum: receiptNum,
            items: itemDTOs
        )
    }
}

// MARK: - 발주 상세 조회 DTO
struct CompletePartsResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: CompletePartsData
}

struct CompletePartsData: Decodable {
    let orderId: Int
    let orderNumber: String
    let totalQuantity: Int?
    let orderStatus: String?
    let items: [CompletePartDTO]
}

struct CompletePartDTO: Decodable {
    let id: Int?
    let partName: String?
    let partCode: String?
    let price: Double?
    let quantity: Int?
    let totalPrice: Double?
}

