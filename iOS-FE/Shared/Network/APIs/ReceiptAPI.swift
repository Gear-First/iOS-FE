import Foundation

enum ReceiptAPI {
    private static var baseURL: String {
        "\(APIConfig.Receipt.baseURL)"
    }
    
    // MARK: - 미처리 접수 목록 조회
    static func fetchUnprocessedReceipts() async throws -> [ReceiptItem] {
        let url = "\(baseURL)/getUnprocessedReceipt"
        let response: ReceiptResponse = try await NetworkManager.shared.request(url: url)
        return response.data.map { $0.toReceiptItem() }
    }
    
    // MARK: - 내 접수 목록 조회 (1년치)
    static func fetchMyReceipts() async throws -> [ReceiptItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let today = Date()
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today)!
        
        let startDate = formatter.string(from: oneYearAgo)
        let endDate = formatter.string(from: today)
        
        let url = "\(baseURL)/getMyReceipt?startDate=\(startDate)&endDate=\(endDate)"
        let response: ReceiptResponse = try await NetworkManager.shared.request(url: url)
        return response.data.map { $0.toReceiptItem() }
    }
    
    // MARK: - 수리 시작
    static func startRepair(receiptId: String) async throws {
        let url = "\(baseURL)/startRepair"
        let _: EmptyResponse = try await NetworkManager.shared.request(
            url: url,
            method: "POST",
            body: receiptId
        )
    }
    
    // MARK: - 수리 상세 등록
    static func submitRepairDetail(request: RepairRequest) async throws {
        let url = "\(baseURL)/repairDetail"
        let _: EmptyResponse = try await NetworkManager.shared.request(
            url: url,
            method: "POST",
            body: try request.toDictionary()
        )
    }
    
    // MARK: - 상세 정보
    static func fetchReceiptDetail(receiptId: String) async throws -> ReceiptItem {
        let url = "\(baseURL)/getReceiptDetail?receiptHistoryId=\(receiptId)"
        let response: ReceiptDetailResponse = try await NetworkManager.shared.request(
            url: url,
            method: "GET"
        )
        return response.data.toReceiptItem()
    }
    
    // MARK: - 발주 상세
    static func fetchCompleteParts(receiptNum: String, vehicleNumber: String, branchCode: String = "서울 대리점", engineerId: Int = 10) async throws -> [OrderItem] {
        let encodedVehicle = vehicleNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? vehicleNumber
        let url = "\(APIConfig.Order.baseURL)/purchase-orders/repair/parts/\(receiptNum)/\(encodedVehicle)?branchCode=\(branchCode)&engineerId=\(engineerId)"

        // 서버는 빈 바디를 기대할 수 있으므로 빈 Data()로 POST 해 본다.
        let response: CompletePartsResponse = try await NetworkManager.shared.request(
            url: url,
            method: "GET"
        )

        let data = response.data
        return data.items.compactMap { dto in
            guard let code = dto.partCode,
                  let name = dto.partName,
                  let qty = dto.quantity
            else { return nil }
            return OrderItem(
                partCode: code,
                partName: name,
                quantity: qty,
                price: dto.price ?? 0,
                id: "\(data.orderId)-\(code)",
                orderStatus: OrderStatus(rawValue: data.orderStatus ?? "") ?? .PENDING
            )
        }
    }
}

// MARK: - 서버에서 응답이 단순 성공/실패일 때 사용
struct EmptyResponse: Decodable {
    let success: Bool?
    let message: String?
}
