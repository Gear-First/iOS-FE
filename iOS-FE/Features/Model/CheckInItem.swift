import Foundation
import SwiftUICore

struct CheckInItem: Identifiable {
    let id: String              // 접수번호
    var carNumber: String       // 차량번호
    let ownerName: String       // 차주명
    var carModel: String        // 차종
    let requestContent: String  // 수리 요청사항
    let date: String            // 접수일자 (yyyy-MM-dd)
    let phoneNumber: String     // 차주번호
    var manager: String?        // 담당자
    var status: CheckInStatus   // 상태
    var leadTimeDays: Int?          // 소요일(요청일~완료일 일수)
    
    var completionInfos: [CheckInDetailViewModel.CompletionInfo]? = nil
    
    // 완료 후 채워지는 필드들
    var completionDate: String?     // 완료일자 (yyyy-MM-dd)
    var repairDescription: String?  // 수리내용
    var cause: String?              // 원인
    var partName: String?
    var partCode: String?
    var partQuantity: Int?
    var partPrice: Double?
    var totalPrice: Double?
    
    // 날짜 차이 계산 헬퍼 (yyyy-MM-dd)
    static func daysBetween(_ from: String, _ to: String) -> Int? {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy-MM-dd"
        guard let d1 = fmt.date(from: from), let d2 = fmt.date(from: to) else { return nil }
        let days = Calendar.current.dateComponents([.day], from: d1, to: d2).day
        return days
    }
    

}

enum CheckInStatus: String, Codable, CaseIterable {
    case checkIn = "접수"
    case inProgress = "수리중"
    case completed = "완료"
}
