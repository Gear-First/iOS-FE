import Foundation

enum PurchaseOrderAPI {
    private static var baseURL: String {
        "\(APIConfig.Order.baseURL)/mock-purchase-orders"
    }
    
    // 차량 목록 조회(Mock)
    static func fetchAllVehicles(engineerId: Int) async throws -> [Vehicle] {
        let url = "\(baseURL)/vehicles/all?engineerId=\(engineerId)"
        let response: VehicleResponse = try await NetworkManager.shared.request(url: url)
        return response.data
    }
    
    // 부품 검색(Mock)
    static func fetchParts(carModelId: Int, keyword: String?) async throws -> [PartItem] {
        var url = "\(baseURL)/inventories?carModelId=\(carModelId)"
        
        if let keyword = keyword, !keyword.isEmpty {
            url += "&keyword=\(keyword)"
        }
        let response: PartResponse = try await NetworkManager.shared.request(url: url)
        return response.data
       }

    // 발주 생성
    static func createOrder(order: OrderRequestBody) async throws {
        let url = "\(baseURL)"
        
        let data = try JSONEncoder().encode(order)
        let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        let _: OrderResponse = try await NetworkManager.shared.request(
            url: url,
            method: "POST",
            body: jsonData
        )
    }
    
    // 발주 상태 조회
    static func fetchOrderStatus(branchId: Int, engineerId: Int) async throws -> [OrderHistoryItem] {
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/branch?branchId=\(branchId)&engineerId=\(engineerId)"
        let response: OrderHistoryResponse = try await NetworkManager.shared.request(url: url)
        return response.data
    }
}


