import Foundation
import SwiftUI

@MainActor
final class OrderRequestViewModel: ObservableObject {
    // MARK: - 차량 검색 결과
    @Published var vehicleList: [ReceiptVehicle] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - 선택 차량
    @Published var selectedVehicle: ReceiptVehicle?

    init(initialVehicle: ReceiptVehicle? = nil) {
        self.selectedVehicle = initialVehicle
    }
    
    // MARK: - 부품 관련
    @Published var orderName: String = ""
    @Published var orderCode: String = ""
    @Published var orderQuantity: Int = 1
    
    // MARK: - 날짜
    @Published var requestDate: Date = Date()
    
    // MARK: - 서버 전송용 바디 생성
    private func makeCreateRequest(
        requesterId: Int,
        requesterName: String,
        requesterRole: String,
        requesterCode: String,
        items: [RepairItemForm],
        receiptNum: String
    ) -> OrderCreateRequest? {
        let finalReceiptNum = receiptNum.trimmingCharacters(in: .whitespaces).isEmpty ? "" : receiptNum
        
        // receiptNum이 빈 문자열이면 (발주요청 탭에서 바로 발주) vehicleNumber와 vehicleModel도 빈 문자열로 보냄
        // receiptNum이 있으면 (내접수에서 발주) selectedVehicle의 값을 사용
        let vehicleNumber: String
        let vehicleModel: String
        
        if finalReceiptNum.isEmpty {
            // 발주요청 탭에서 바로 발주할 때는 항상 빈 문자열
            vehicleNumber = ""
            vehicleModel = ""
        } else {
            // 내접수에서 발주할 때는 selectedVehicle의 값을 사용
            vehicleNumber = selectedVehicle?.carNum ?? ""
            vehicleModel = selectedVehicle?.carType ?? ""
        }
        
        var itemDTOs: [OrderItemDTO] = []
        for (itemIndex, item) in items.enumerated() {
            for (partIndex, part) in item.parts.enumerated() {
                let partId = part.partId ?? 0
                let partName = part.partName
                // partCode가 있으면 사용, 없으면 code 사용
                let partCode = part.partCode.isEmpty ? part.code : part.partCode
                let price = part.unitPrice
                let quantity = part.quantity
                
                itemDTOs.append(
                    OrderItemDTO(
                        partId: partId,
                        partName: partName,
                        partCode: partCode,
                        price: price,
                        quantity: quantity
                    )
                )
            }
        }
        
        let request = OrderCreateRequest(
            vehicleNumber: vehicleNumber,
            vehicleModel: vehicleModel,
            requesterId: requesterId,
            requesterName: requesterName,
            requesterRole: requesterRole,
            requesterCode: requesterCode,
            receiptNum: finalReceiptNum,
            items: itemDTOs
        )
        
        return request
    }
    
    // MARK: - 발주 요청 API 호출
    func submitOrderToServer(
        requesterId: Int,
        requesterName: String,
        requesterRole: String,
        requesterCode: String,
        items: [RepairItemForm],
        receiptNum: String
    ) async -> OrderHistoryItem? {
        
        guard let body = makeCreateRequest(
            requesterId: requesterId,
            requesterName: requesterName,
            requesterRole: requesterRole,
            requesterCode: requesterCode,
            items: items,
            receiptNum: receiptNum
        ) else {
            errorMessage = "요청 바디 생성 실패: selectedVehicle가 없습니다"
            return nil
        }
        
        do {
            // 서버 요청
            let response = try await PurchaseOrderAPI.createOrder(order: body)
            
            guard response.success else {
                errorMessage = response.message
                return nil
            }

            // 서버 응답 → OrderHistoryItem 변환
            let historyItem = OrderHistoryItem(
                orderId: response.data.orderId,
                orderNumber: response.data.orderNumber,
                status: response.data.orderStatus,
                totalPrice: 0,
                requestDate: ISO8601DateFormatter().string(from: Date()),
                processedDate: nil,
                transferDate: nil,
                completedDate: nil,
                items: response.data.items.map {
                    OrderHistoryPart(
                        id: $0.id,
                        partName: $0.partName,
                        partCode: $0.partCode,
                        price: $0.price,
                        quantity: $0.quantity,
                        totalPrice: $0.totalPrice
                    )
                }
            )
            return historyItem

        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - 차량 전체 조회
    func fetchAllVehicles() async {
        isLoading = true
        errorMessage = nil
        do {
            let vehicles = try await PurchaseOrderAPI.fetchAllVehicles()
            self.vehicleList = vehicles
        } catch {
            self.errorMessage = error.localizedDescription
            print("fetchAllVehicles error:", error.localizedDescription)
        }
        isLoading = false
    }
    
    // MARK: - 부품 리스트
    @Published var partList: [PartItem] = []
    
    func fetchIntegratedParts() async {
        isLoading = true
        errorMessage = nil
        do {
            let parts = try await PurchaseOrderAPI.fetchIntegratedParts()
            self.partList = parts
        } catch {
            self.errorMessage = error.localizedDescription
            print("fetchIntegratedParts error:", error.localizedDescription)
        }
        isLoading = false
    }
    
    // MARK: - 유효성 검사
    var isValid: Bool {
        selectedVehicle != nil &&
        !orderName.isEmpty &&
        !orderCode.isEmpty
    }
    
    // MARK: - 폼 초기화
    func resetForm() {
        selectedVehicle = nil
        orderName = ""
        orderCode = ""
        orderQuantity = 1
        requestDate = Date()
    }
}

// MARK: - PartSelectable Protocol
extension OrderRequestViewModel: PartSelectable {
    var name: String {
        get { orderName }
        set { orderName = newValue }
    }
    
    var code: String {
        get { orderCode }
        set { orderCode = newValue }
    }
}

// MARK: - 단일 부품 요청용 (옵션)
extension OrderRequestViewModel {
    func makeCreateRequest(
        from orderItem: OrderItem,
        requesterId: Int,
        requesterName: String,
        requesterRole: String,
        requesterCode: String,
        receiptNum: String
    ) -> OrderCreateRequest? {
        // selectedVehicle이 없어도 빈 문자열로 보냄
        let vehicleNumber = selectedVehicle?.carNum ?? ""
        let vehicleModel = selectedVehicle?.carType ?? ""
        let dto = OrderItemDTO(
            partId: Int(orderItem._id ?? "") ?? 0,
            partName: orderItem.partName,
            partCode: orderItem.partCode,
            price: orderItem.price,
            quantity: orderItem.quantity
        )
        return OrderCreateRequest(
            vehicleNumber: vehicleNumber,
            vehicleModel: vehicleModel,
            requesterId: requesterId,
            requesterName: requesterName,
            requesterRole: requesterRole,
            requesterCode: requesterCode,
            receiptNum: receiptNum,
            items: [dto]
        )
    }
}
