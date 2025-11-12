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
//    static func fetchParts() async throws -> [PartItem] {
//        let url = "\(APIConfig.Warehouse.baseURL)/parts/integrated"
//        let response: PartResponse = try await NetworkManager.shared.request(url: url)
//        return response.data.items.map(PartItem.init(dto:))
//    }
    
    // 통합 부품 검색 (차종 또는 카테고리 필터 지원)
    static func fetchIntegratedParts(
        carModelName: String? = nil,
        categoryName: String? = nil
    ) async throws -> [PartItem] {
        var queryItems: [String] = []
        
        if let carModelName, !carModelName.isEmpty {
            let encodedModel = carModelName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            queryItems.append("carModelName=\(encodedModel)")
        }
        
        if let categoryName, !categoryName.isEmpty {
            let encodedCategory = categoryName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            queryItems.append("categoryName=\(encodedCategory)")
        }
        
        // 기본 URL + 쿼리 결합
        let query = queryItems.joined(separator: "&")
        let url = "\(APIConfig.Warehouse.baseURL)/parts/integrated?\(query)"
//        print("통합검색 URL:", url)
        
        let response: IntegratedPartResponse = try await NetworkManager.shared.request(url: url)
        
        return response.data.items.map { dto in
            PartItem(
                id: String(dto.id),
                partName: dto.name,
                partCode: dto.code,
                categoryName: dto.categoryName ?? "-",
                price: dto.price
            )
        }
    }

    
    // 발주 생성
    static func createOrder(order: OrderCreateRequest) async throws -> OrderCreateResponse {
        guard let session = UserSession.current else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = "\(APIConfig.Order.baseURL)/purchase-orders"
        print("[PurchaseOrderAPI] 발주 생성 요청 (engineerId: \(session.engineerId), branch: \(session.branchCode))")

        let data = try JSONEncoder().encode(order)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(TokenManager.shared.getAccessToken() ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = data

        // 네트워크 요청 실행
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        // 상태코드 + 응답 바디 로그 출력
        if let httpResponse = response as? HTTPURLResponse {
            print("Status:", httpResponse.statusCode)
            
            // 401 Unauthorized 에러 처리
            if httpResponse.statusCode == 401 {
                print("[PurchaseOrderAPI] 현재 토큰:", TokenManager.shared.getAccessToken() ?? "nil")
//                TokenManager.shared.clearTokens()
//                UserSession.clear()
                await MainActor.run {
                    NotificationCenter.default.post(name: NSNotification.Name("UnauthorizedError"), object: nil)
//                    AuthViewModel.shared.logout()
                }
                throw URLError(.userAuthenticationRequired)
            }
            
            if let body = String(data: responseData, encoding: .utf8) {
                print("Response Body:", body)
            }
        }

        // JSON 구조가 맞지 않아도 앱이 튕기지 않도록 예외 처리
        do {
            let decoded = try JSONDecoder().decode(OrderCreateResponse.self, from: responseData)
            print("[PurchaseOrderAPI] 디코딩 성공:", decoded)
            return decoded
        } catch {
            print("[PurchaseOrderAPI] 디코딩 실패:", error)
            if let raw = String(data: responseData, encoding: .utf8) {
                print("[PurchaseOrderAPI] 서버 원본 응답:", raw)
            }
            throw error
        }
    }


    
    
    // 발주 취소
    static func cancelOrder(orderId: Int) async throws -> MessageResponse {
        guard let session = UserSession.current else {
            throw URLError(.userAuthenticationRequired)
        }
    let url = "\(APIConfig.Order.baseURL)/purchase-orders/\(orderId)/cancel"
        
        let response: MessageResponse = try await NetworkManager.shared.request(
            url: url,
            method: "PATCH",
            body: nil
        )
        return response
    }
    
    // 발주 내역 조회
    static func fetchOrderAllStatus() async throws -> [OrderHistoryItem] {
        guard let session = UserSession.current else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = "\(APIConfig.Order.baseURL)/purchase-orders/branch?size=100"
        print("[PurchaseOrderAPI] 요청 URL:", url)

        let response: OrderHistoryResponse = try await NetworkManager.shared.request(url: url)
        print("[PurchaseOrderAPI] 응답 성공:", response.data.content.count, "건 수신")

        return response.data.content
    }

    


    
    // 발주 상태별 조회
    static func fetchOrderStatus(filterType: String) async throws -> [OrderHistoryItem] {
        guard let session = UserSession.current else {
            throw URLError(.userAuthenticationRequired)
        }
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/status?filterType=\(filterType)"
            print("[PurchaseOrderAPI] 상태별 조회 URL:", url)

            let response: OrderHistoryResponse = try await NetworkManager.shared.request(url: url)
            return response.data.content
    }
    
    // 발주 상세 조회 추가
    static func fetchOrderDetail(orderId: Int) async throws -> OrderHistoryItem {
        guard let session = UserSession.current else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/\(orderId)"
            print("[PurchaseOrderAPI] 상세 조회 URL:", url)

            let response: OrderDetailResponse = try await NetworkManager.shared.request(url: url)
            print("[PurchaseOrderAPI] 상세 응답:", response)
            return response.data
    }
}
