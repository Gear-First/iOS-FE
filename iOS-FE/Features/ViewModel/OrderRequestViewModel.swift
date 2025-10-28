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
    
    // MARK: - 부품 관련
    @Published var orderName: String = ""     // 부품명
    @Published var orderCode: String = ""     // 부품코드
    @Published var orderQuantity: Int = 1
    
    // MARK: - 날짜
    @Published var requestDate: Date = Date()
    
    // MARK: - 포맷터
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    // MARK: - 주문 생성(로컬 모델)
    func submitRequestOrder() -> OrderItem? {
        guard selectedVehicle != nil else { return nil }
        let formattedDate = dateFormatter.string(from: requestDate)
        return OrderItem(
            inventoryCode: orderCode.isEmpty ? "AUTO" : orderCode,
            inventoryName: orderName.isEmpty ? "미지정 부품" : orderName,
            quantity: orderQuantity,
            requestDate: formattedDate,
            id: UUID().uuidString,
            orderStatus: .PENDING
        )
    }
    
    // MARK: - 서버 전송용 바디 생성 (수정: OrderCreateRequest를 반환)
    /// RepairItemForm 배열을 요청 DTO 배열로 변환하고, 선택 차량을 이용해 최종 요청 바디를 만든다.
    private func makeCreateRequest(
        engineerId: Int,
        branchId: Int,
        items: [RepairItemForm]
    ) -> OrderCreateRequest? {
        guard let v = selectedVehicle else { return nil }
        
        // 요청용 DTO만 사용 (응답용 OrderHistoryPart 사용 X)
        var itemDTOs: [OrderItemDTO] = []
        for item in items {
            for part in item.parts {
                itemDTOs.append(
                    OrderItemDTO(
                        // 서버 계약에 따라 inventoryId가 필수면 값 넣기, 선택이면 nil 가능
                        inventoryId: part.partId,         // Int? 라면 그대로 전달
                        inventoryName: part.partName,
                        inventoryCode: part.code,
                        quantity: part.quantity
                    )
                )
            }
        }
        
        return OrderCreateRequest(
            vehicleNumber: v.carNum,    // ReceiptVehicle 사용
            vehicleModel: v.carType,
            engineerId: engineerId,
            branchId: branchId,
            items: itemDTOs
        )
    }
    
    // MARK: - 발주 요청 API
    func submitOrderToServer(
        engineerId: Int,
        branchId: Int,
        items: [RepairItemForm]
    ) async -> Bool {
        // 수정: 위에서 만든 createRequest를 사용
        guard let body = makeCreateRequest(engineerId: engineerId, branchId: branchId, items: items) else {
            return false
        }
        
        do {
            try await PurchaseOrderAPI.createOrder(order: body) // OrderCreateRequest 사용
            return true
        } catch {
            print("발주 요청 실패:", error.localizedDescription)
            return false
        }
    }
    
    // MARK: - 차량 전체 조회 API 호출
    func fetchAllVehicles() async {
        isLoading = true
        errorMessage = nil
        do {
            let vehicles = try await PurchaseOrderAPI.fetchAllVehicles()
            self.vehicleList = vehicles
        } catch {
            self.errorMessage = error.localizedDescription
            print("fetchAllVehicles error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // MARK: - 부품 리스트
    @Published var partList: [PartItem] = []
    
    // MARK: - 부품 검색 (Mock)
    func fetchPartsMock() async {
        isLoading = true
        errorMessage = nil
        do {
            let parts = try await PurchaseOrderAPI.fetchPartsMock()
            self.partList = parts
        } catch {
            self.errorMessage = error.localizedDescription
            print("fetchParts error:", error.localizedDescription)
        }
        isLoading = false
    }
    
    // MARK: - 유효성 검사
    var isValid: Bool {
        selectedVehicle != nil &&
        !orderName.isEmpty &&
        !orderCode.isEmpty &&
        orderQuantity > 0
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

// MARK: - 잘못된 함수 교체 (요청용으로 변경)
// 기존의 makeOrderHistoryItem(from:)은 응답용 타입(OrderHistoryPart)을 사용하고
// OrderItem에 없는 필드를 접근하므로 삭제/교체합니다.
// 필요 시 아래와 같은 오버로드를 추가로 둘 수 있습니다.
extension OrderRequestViewModel {
    /// 단일 OrderItem으로 요청 바디를 만들고 싶을 때(샘플)
    func makeCreateRequest(
        from orderItem: OrderItem,
        engineerId: Int,
        branchId: Int
    ) -> OrderCreateRequest? {
        guard let v = selectedVehicle else { return nil }
        let dto = OrderItemDTO(
            inventoryId: nil,                    // 서버 계약에 따라 값 세팅
            inventoryName: orderItem.inventoryName,
            inventoryCode: orderItem.inventoryCode,
            quantity: orderItem.quantity
        )
        return OrderCreateRequest(
            vehicleNumber: v.carNum,
            vehicleModel: v.carType,
            engineerId: engineerId,
            branchId: branchId,
            items: [dto]
        )
    }
}
