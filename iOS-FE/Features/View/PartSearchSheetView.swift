import SwiftUI
import Foundation

protocol PartSelectable: ObservableObject, AnyObject {
    var name: String { get set }
    var code: String { get set }
}

import SwiftUI

struct PartSearchSheetView<ViewModel: PartSelectable>: View {
    @ObservedObject var viewModel: ViewModel
    var disabledCodes: Set<String> = []
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
                                let isDisabled = disabledCodes.contains(item.partCode)
                                Button {
                                    guard !isDisabled else { return }
                                    // RepairPartForm인 경우 partId와 partCode를 모두 설정
                                    if let repairPart = viewModel as? RepairPartForm {
                                        // MainActor에서 즉시 설정하여 UI 업데이트 보장
                                        repairPart.partId = Int(item.id)
                                        repairPart.partCode = item.partCode
                                        repairPart.partName = item.partName
                                    } else {
                                        // 다른 ViewModel인 경우 code만 설정
                                        viewModel.name = item.partName
                                        viewModel.code = item.partCode
                                    }
                                    dismiss()
                                } label: {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(item.partName)
                                                .font(.headline)
                                            Text("\(item.partCode)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        if isDisabled {
                                            Text("선택됨")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(RoundedRectangle(cornerRadius: 6).fill(AppColor.bgGray))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .foregroundColor(isDisabled ? AppColor.textMuted : AppColor.mainBlack)
                                }
                                .disabled(isDisabled)
                                Divider()
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
            let response = try await PurchaseOrderAPI.fetchParts()
            partList = response
        } catch {
            print("부품 검색 오류:", error.localizedDescription)
            partList = []
        }
        isLoading = false
    }
}
