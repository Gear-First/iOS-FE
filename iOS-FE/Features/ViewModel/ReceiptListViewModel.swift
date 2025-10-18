import Foundation
import SwiftUI

@MainActor
class ReceiptListViewModel: ObservableObject {
    @Published var items: [ReceiptItem] = []
    @Published var isLoading: Bool = false
    
    // MARK: - 미처리 접수 조회 API 호출
    func fetchReceipts() async {
            isLoading = true
            defer { isLoading = false }

            do {
                items = try await ReceiptAPI.fetchUnprocessedReceipts()
                print("미처리 접수 불러오기 완료: \(items.count)건")
            } catch {
                print("미처리 접수 불러오기 실패:", error)
            }
        }
    
    // MARK: - 내 접수 이려 조회 API 호출
    func fetchMyReceipts() async {
            isLoading = true
            defer { isLoading = false }

            do {
                items = try await ReceiptAPI.fetchMyReceipts()
                print("내 접수 불러오기 완료: \(items.count)건")
            } catch {
                print("내 접수 불러오기 실패:", error)
            }
        }
    
}

