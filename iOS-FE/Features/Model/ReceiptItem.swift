import Foundation
import SwiftUI

// MARK: - 접수 아이템
struct ReceiptItem: Identifiable {
    let id: String              // 접수번호
    let carNumber: String       // 차량번호
    let ownerName: String       // 차주명
    let carModel: String        // 차종
    let requestContent: String  // 수리 요청사항
    let date: String            // 접수일자 (yyyy-MM-dd)
    let phoneNumber: String     // 차주번호
    var manager: String?        // 담당자
    var status: ReceiptStatus   // 상태
    var leadTimeDays: Int?      // 소요일(요청일~완료일 일수)
    
    var orderId: Int?
    
    // 상세 페이지에서 사용할 수리 완료 정보
    var completionInfos: [ReceiptDetailViewModel.CompletionInfo]? = nil

    // 날짜 차이 계산 헬퍼 (yyyy-MM-dd)
    static func daysBetween(_ from: String, _ to: String) -> Int? {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let d1 = fmt.date(from: from), let d2 = fmt.date(from: to) else { return nil }
        let days = Calendar.current.dateComponents([.day], from: d1, to: d2).day
        return (days ?? 0) + 1
    }

}

// MARK: - 접수 상태 Enum
enum ReceiptStatus: String, Codable, CaseIterable {
    case checkIn = "접수"
    case inProgress = "수리중"
    case completed = "완료"
}

// MARK: - 서버 응답 모델들
// 리스트용 응답
struct ReceiptResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [ReceiptDTO]
}

// 상세용 응답
struct ReceiptDetailResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: ReceiptDTO
}

// MARK: 서버에서 내려주는 접수 단일 데이터
struct ReceiptDTO: Codable {
    let receiptHistoryId: String
    let receipterName: String
    let receipterCarNum: String
    let receipterCarType: String
    let receipterPhone: String
    let receipterRequest: String
    let engineer: String?
    let status: String
    let repairHistories: [RepairHistory]?
}

// MARK: - 수리 관련 하위 구조
struct RepairHistory: Codable {
    let repairDetail: String?
    let repairCause: String?
    let usedParts: [UsedPart]?
}

struct UsedPart: Codable {
    let partName: String?
    let quantity: Int?
    let price: Int?
}

// MARK: - 변환 메서드 (서버 모델 -> 화면 표시용 모델)
extension ReceiptDTO {
    func toReceiptItem() -> ReceiptItem {
        // 오늘 날짜 기본값
        let today = {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return fmt.string(from: Date())
        }()
        
        // 수리 정보 (없으면 빈 배열)
        let completionInfos: [ReceiptDetailViewModel.CompletionInfo] = (repairHistories ?? []).flatMap { history in
            (history.usedParts ?? []).map { part in
                ReceiptDetailViewModel.CompletionInfo(
                    completionDate: today, // 오늘 날짜
                    repairDescription: history.repairDetail ?? "수리 내역 없음",
                    cause: history.repairCause ?? "원인 미정",
                    partName: part.partName ?? "부품 미정",
                    partQuantity: part.quantity ?? 0,
                    partPrice: Double(part.price ?? 0),
                    totalPrice: Double(part.price ?? 0) * Double(part.quantity ?? 0)
                )
            }
        }
        
        // leadTimeDays 계산
        let leadTime: Int? = {
                guard let firstDate = completionInfos.first?.completionDate else { return nil }
                return ReceiptItem.daysBetween(today, firstDate)
            }()

        // 문자열 상태를 ReceiptStatus로 변환
        let convertedStatus: ReceiptStatus = {
            switch status.lowercased() {
            case "receipt", "접수":
                return .checkIn
            case "inprogress", "수리중":
                return .inProgress
            case "completed", "완료":
                return .completed
            default:
                return .checkIn
            }
        }()
        // ReceiptItem으로 변환해서 반환
        return ReceiptItem(
            id: receiptHistoryId,
            carNumber: receipterCarNum,
            ownerName: receipterName,
            carModel: receipterCarType,
            requestContent: receipterRequest,
            date: today,
            phoneNumber: receipterPhone,
            manager: engineer ?? "미지정",
            status: convertedStatus,
            leadTimeDays: leadTime,
            completionInfos: completionInfos
        )
    }
}
