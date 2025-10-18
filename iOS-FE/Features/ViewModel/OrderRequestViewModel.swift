import Foundation
import SwiftUI

@MainActor
final class OrderRequestViewModel: ObservableObject {
    // MARK: - 차량 검색 결과
    @Published var vehicleList: [Vehicle] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - 선택 차량
    @Published var selectedVehicle: Vehicle?
    
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
    
    // MARK: - 주문 생성
    func submitRequestOrder() -> OrderItem? {
        guard let vehicle = selectedVehicle else { return nil }
        let formattedDate = dateFormatter.string(from: requestDate)
        return OrderItem(
            inventoryCode: orderCode.isEmpty ? "AUTO" : orderCode,
            inventoryName: orderName.isEmpty ? "미지정 부품" : orderName,
            quantity: orderQuantity,
            requestDate: formattedDate,
            id: UUID().uuidString,
            orderStatus: .pending
        )
    }
    
    // MARK: - 차량 전체 조회(담당자id) API 호출
    func fetchAllVehicles(engineerId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let vehicles = try await PurchaseOrderAPI.fetchAllVehicles(engineerId: engineerId)
            self.vehicleList = vehicles
        } catch {
            self.errorMessage = error.localizedDescription
            print("fetchAllVehicles error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // MARK: - 부품 리스트
    @Published var partList: [PartItem] = []
    
    // MARK: - 부품 검색 API
    func fetchParts(for carModelId: Int, keyword: String = "") async {
        isLoading = true
        errorMessage = nil
        do {
            let parts = try await PurchaseOrderAPI.fetchParts(carModelId: carModelId, keyword: keyword)
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
