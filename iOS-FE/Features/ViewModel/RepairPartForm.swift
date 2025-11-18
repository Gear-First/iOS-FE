import SwiftUI

final class RepairPartForm: ObservableObject, Identifiable, PartSelectable {
    let id = UUID()
    
    // 서버로 보낼 필드
    @Published var partId: Int? = nil
    @Published var partName: String = ""
    @Published var partCode: String = ""  // 부품 코드 (문자열)
    @Published var quantity: Int = 1
    
    // UI 전용 필드
    @Published var unitPrice: Double = 0.0 
    
    // 총액 계산 (UI 표시용)
    var totalPrice: Double { Double(quantity) * unitPrice }

    // PartSelectable 대응
    var name: String {
        get { partName }
        set { partName = newValue }
    }
    var code: String {
        get { partCode.isEmpty ? String(partId ?? 0) : partCode }
        set {
            // code가 숫자 문자열이면 partId로 설정, 아니면 partCode로 설정
            if let intValue = Int(newValue) {
                partId = intValue
                // 숫자 문자열이지만 partCode도 함께 저장
                partCode = newValue
            } else {
                // 문자열 코드인 경우 partCode로 저장하고 partId는 nil 유지
                partCode = newValue
            }
        }
    }
}
