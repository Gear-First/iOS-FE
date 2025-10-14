import Foundation
import Combine
import SwiftUI

class CheckInListViewModel: ObservableObject {
    @Published var items: [CheckInItem] = []
    
//    init(items: [CheckInItem] = []) {
//        self.items = items
//    }
    
    init() {
            loadMockData()
        }
    
    
    
    func loadMockData() {
            items = MockCheckInData.sample
        }
}
