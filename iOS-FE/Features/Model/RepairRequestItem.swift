import Foundation

// MARK: - 수리 상세 등록 요청 모델
struct RepairRequest: Codable {
    let receiptHistoryId: String
    let repairDetailRequests: [RepairDetailRequest]
}

struct RepairDetailRequest: Codable {
    let repairDetail: String
    let repairCause: String
    let usedParts: [UsedPartRequest]
}

struct UsedPartRequest: Codable {
    let partId: Int
    let partName: String
    let quantity: Int
}
