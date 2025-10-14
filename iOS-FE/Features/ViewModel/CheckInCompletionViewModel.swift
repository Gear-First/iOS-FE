import Foundation
import SwiftUI

final class CheckInCompletionViewModel: ObservableObject {
    // 입력값
    @Published var repairDescription: String = ""
    @Published var cause: String = ""
    @Published var rawDateInput: String = ""     // yyyy-MM-dd 텍스트 입력
    @Published var completionDate: Date = Date()
    @Published var partName: String = ""
    @Published var partCode: String = ""
    @Published var partQuantity: Int = 1
    @Published var partPrice: Double = 0.00
    
    // 모의 가격표
    private let mockPartPriceTable: [String: Double] = [
        "엔진오일": 45000,
        "브레이크 패드": 68000,
        "타이어": 120000,
        "에어컨 필터": 18000,
        "배터리": 150000
    ]
    
    var totalPrice: Double {
        Double(partQuantity) * partPrice
    }
    
    // 없으면 10,000 ~ 1,000,000원 사이 랜덤 가격을 자동 지정
    func autofillPriceIfMatches() {
        guard partName.trimmingCharacters(in: .whitespaces).count >= 2 else { return }
            
        if let p = mockPartPriceTable[partName] {
            partPrice = p
        } else {
            let random = Double(Int.random(in: 10...1000) * 1000)
            partPrice = random
        }
    }
    
    // yyyy-MM-dd 포맷 변환
    private var fmt: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }
    
    init() {
            self.rawDateInput = fmt.string(from: completionDate)
        }
    
    func syncTextFromDate() {
        rawDateInput = fmt.string(from: completionDate)
    }
    
    func syncDateFromText() {
        if let d = fmt.date(from: rawDateInput) {
            completionDate = d
        }
    }
    
    // 제출 페이로드로 변환
    func buildCompletionInfo() -> CheckInDetailViewModel.CompletionInfo? {
        // 날짜 문자열 확정
        let dateString: String
        if !rawDateInput.isEmpty {
            syncDateFromText()
            dateString = rawDateInput
        } else {
            dateString = fmt.string(from: completionDate)
        }
        
        guard !repairDescription.trimmingCharacters(in: .whitespaces).isEmpty,
              !cause.trimmingCharacters(in: .whitespaces).isEmpty,
              !partName.trimmingCharacters(in: .whitespaces).isEmpty,
              partQuantity > 0, partPrice >= 0
        else { return nil }
        
        return .init(
            completionDate: dateString,
            repairDescription: repairDescription,
            cause: cause,
            partName: partName,
            partQuantity: partQuantity,
            partPrice: partPrice,
            totalPrice: totalPrice
        )
    }
}

extension CheckInCompletionViewModel: PartSelectable {
    var name: String {
        get { partName }
        set { partName = newValue }
    }

    var code: String {
        get { partCode }
        set { partCode = newValue }
    }
}
