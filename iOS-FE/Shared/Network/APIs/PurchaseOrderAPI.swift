import Foundation

enum PurchaseOrderAPI {
    private static var baseURL: String {
        "\(APIConfig.Order.baseURL)"
    }
    
    // 차량 목록 조회(Mock)
    static func fetchAllVehicles() async throws -> [ReceiptVehicle] {
        let url = "\(APIConfig.Receipt.baseURL)/getReceiptInfo"
        let response: VehicleResponse = try await NetworkManager.shared.request(url: url)
        return response.data
    }
    
    // 부품 검색
    static func fetchParts() async throws -> [PartItem] {
        let url = "\(APIConfig.Warehouse.baseURL)/parts"
        let response: PartResponse = try await NetworkManager.shared.request(url: url)
        return response.data.items.map(PartItem.init(dto:))
    }
    
    // 발주 생성
    static func createOrder(order: OrderCreateRequest) async throws -> OrderCreateResponse {
        let url = "\(baseURL)/purchase-orders"
        
        let data = try JSONEncoder().encode(order)
        
            print("Request JSON:", String(data: data, encoding: .utf8) ?? "인코딩 실패")
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data

            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status:", httpResponse.statusCode)
                if let body = String(data: responseData, encoding: .utf8) {
                    print("Response:", body)
                }
            }

            return try JSONDecoder().decode(OrderCreateResponse.self, from: responseData)
        }
    
    // 발주 취소
    static func cancelOrder(orderId: Int, branchCode: String, engineerId: Int) async throws -> MessageResponse {
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/\(orderId)/cancel?branchCode=\(branchCode)&engineerId=\(engineerId)"
        
        let response: MessageResponse = try await NetworkManager.shared.request(
            url: url,
            method: "PATCH",
            body: nil
        )
        return response
    }
    
    // 발주 내역 조회
    static func fetchOrderAllStatus(branchCode: String, engineerId: Int) async throws -> [OrderHistoryItem] {
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/branch?branchCode=\(branchCode)&engineerId=\(engineerId)"
        let response: OrderHistoryResponse = try await NetworkManager.shared.request(url: url)
        return response.data.content
    }
    
    // 발주 상태별 조회
    static func fetchOrderStatus(branchCode: String, engineerId: Int, filterType: String) async throws -> [OrderHistoryItem] {
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/status?branchCode=\(branchCode)&engineerId=\(engineerId)&filterType=\(filterType)"
        let response: OrderHistoryResponse = try await NetworkManager.shared.request(url: url)
        return response.data.content
    }
    
    // 발주 상세 조회 추가
    static func fetchOrderDetail(orderId: Int, branchCode: String, engineerId: Int) async throws -> OrderHistoryItem {
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/\(orderId)?branchCode=\(branchCode)&engineerId=\(engineerId)"
        let response: OrderDetailResponse = try await NetworkManager.shared.request(url: url)
        return response.data
    }
}

