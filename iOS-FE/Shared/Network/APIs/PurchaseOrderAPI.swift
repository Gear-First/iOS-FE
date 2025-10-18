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

    
    static func fetchOrderStatus(branchId: Int, filterType: Int) async throws -> [OrderStatusItem] {
        let url = "\(baseURL)/status?branchId=\(branchId)&filterType=\(filterType)"
           let response: OrderStatusResponse = try await NetworkManager.shared.request(url: url)
           return response.data
       }
}

