import Foundation
import SwiftUI

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

// MARK: - 로컬 주문 항목 (UI/로컬 상태용)
struct OrderItem: Identifiable, Codable, Hashable {
    let id: String            // 로컬 고유 ID
    let _id: String?          // 서버에서 받은 ID 등 (없을 수 있음)

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
        serverId: String? = nil,
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
        self._id = serverId
        self.orderStatus = orderStatus
    }
}

// MARK: - 차량 관련 (서버 응답 DTO + 도메인 모델)
struct VehicleResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [ReceiptVehicle]     // 접수 차량 리스트
}

struct Vehicle: Codable, Identifiable {
    let repairNumber: String
    let plateNumber: String
    let model: String
    let manufacturer: String
    let registeredDate: String

    var id: String { repairNumber }
}

/// 접수 차량(간단형) DTO
struct ReceiptVehicle: Codable, Identifiable {
    let carNum: String
    let carType: String
    var id: String { carNum }
}

// MARK: - 부품 관련 (DTO ↔ 도메인 매핑)

// 서버 응답 래퍼
struct PartResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [PartDTO]
}

// 서버 DTO
struct PartDTO: Decodable {
    let id: Int
    let partName: String
    let partCode: String
}

// 도메인(화면)에서 사용할 모델
struct PartItem: Identifiable, Hashable, Codable {
    var id: String          // 문자열 통일
    var partName: String
    var partCode: String
}

extension PartItem {
    init(dto: PartDTO) {
        self.id = String(dto.id)
        self.partName = dto.partName
        self.partCode = dto.partCode
    }
}

// MARK: - 주문: 요청용 DTO (서버로 전송)

// 최종 요청 바디
struct OrderCreateRequest: Encodable {
    let vehicleNumber: String      // 예: "12가3456"
    let vehicleModel: String       // 예: "Sonata"
    let engineerId: Int            // 필요 없으면 서버 계약에 맞춰 제거 가능
    let branchId: Int              // 필요 없으면 제거 가능
    let items: [OrderItemDTO]
}

// 항목 요청 DTO (요청용)
struct OrderItemDTO: Encodable {
    let inventoryId: Int?          // 서버가 꼭 요구하면 채워서 전달, 아니면 nil
    let inventoryName: String
    let inventoryCode: String
    let quantity: Int
    // let price: Double?          // 서버 계약에 따라 사용

    init(inventoryId: Int? = nil, inventoryName: String, inventoryCode: String, quantity: Int) {
        self.inventoryId = inventoryId
        self.inventoryName = inventoryName
        self.inventoryCode = inventoryCode
        self.quantity = quantity
    }
}

extension OrderItemDTO {
    /// PartItem + 수량 → 요청 DTO
    init(part: PartItem, quantity: Int, inventoryId: Int? = nil) {
        self.init(
            inventoryId: inventoryId,
            inventoryName: part.partName,
            inventoryCode: part.partCode,
            quantity: quantity
        )
    }

    /// OrderItem → 요청 DTO
    init(orderItem: OrderItem, inventoryId: Int? = nil) {
        self.init(
            inventoryId: inventoryId,
            inventoryName: orderItem.inventoryName,
            inventoryCode: orderItem.inventoryCode,
            quantity: orderItem.quantity
        )
    }
}

// MARK: - 주문: 응답/조회용 DTO (서버에서 수신)
struct OrderResponse: Codable {
    let success: Bool
    let message: String
}

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

struct OrderHistoryResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [OrderHistoryItem]
}

struct OrderHistoryItem: Decodable, Hashable {
    let orderId: Int
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
}

// 공용 메시지 응답
struct MessageResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
}

// MARK: - ViewModel 보조: 요청 바디 생성기 예시
extension OrderRequestViewModel {
    /// 선택 차량 + 화면의 주문 항목으로 서버 요청 바디 생성
    func makeCreateRequest(
        items: [OrderItem],
        engineerId: Int,
        branchId: Int
    ) -> OrderCreateRequest? {
        guard let v = selectedVehicle else { return nil }

        let itemDTOs = items.map { OrderItemDTO(orderItem: $0, inventoryId: nil) }

        return OrderCreateRequest(
            vehicleNumber: v.carNum,  // ReceiptVehicle을 도메인 Vehicle로 변환해서 쓰는 경우에 맞춤
            vehicleModel: v.carType,
            engineerId: engineerId,
            branchId: branchId,
            items: itemDTOs
        )
    }
}
