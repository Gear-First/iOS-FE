import SwiftUI
import Foundation

protocol PartSelectable: ObservableObject, AnyObject {
    var name: String { get set }
    var code: String { get set }
}

import SwiftUI

struct PartSearchSheetView<ViewModel: PartSelectable>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var partList: [PartItem] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 검색창
                EditableField(
                    value: $searchText,
                    placeholder: "부품명을 입력"
                )
                .padding()
                .onSubmit {
                    Task { await searchParts() }
                }
                
                if isLoading {
                    ProgressView("검색 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if partList.isEmpty {
                    Spacer()
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(partList) { item in
                                Button {
                                    viewModel.name = item.partName
                                    viewModel.code = item.partCode
                                    dismiss()
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(item.partName)
                                            .font(.headline)
                                        Text("\(item.partCode)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Divider()
                                    }
                                    .foregroundColor(AppColor.mainBlack)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("부품 검색")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await searchParts() }
    }
    
    private func searchParts() async {
        guard let carModelId = 1 as Int? else { return } // 테스트용, 실제로는 선택 차량 ID
        isLoading = true
        do {
//            let response = try await PurchaseOrderAPI.fetchParts(carModelId: carModelId, keyword: searchText)
            let response = try await PurchaseOrderAPI.fetchPartsMock()
            partList = response
        } catch {
            print("부품 검색 오류:", error.localizedDescription)
            partList = []
        }
        isLoading = false
    }
}
