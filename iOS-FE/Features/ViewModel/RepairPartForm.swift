import SwiftUI

final class RepairPartForm: ObservableObject, Identifiable, PartSelectable {
    let id = UUID()
    
    // 서버로 보낼 필드
    @Published var partId: Int? = nil
    @Published var partName: String = ""
    @Published var quantity: Int = 0  // 서버로 보냄
    
    // UI 전용 필드
    @Published var unitPrice: Double = 0.0  // 서버 전송 안함
    
    // 총액 계산 (UI 표시용)
    var totalPrice: Double { Double(quantity) * unitPrice }

    // PartSelectable 대응
    var name: String {
        get { partName }
        set { partName = newValue }
    }
    var code: String {
            get { String(partId ?? 0) }
            set {
                // code가 string이라면 id를 더미 int로 변환
                if let intValue = Int(newValue) {
                    partId = intValue
                } else {
                    partId = Int.random(in: 100...999)
                }
            }
        }
}
