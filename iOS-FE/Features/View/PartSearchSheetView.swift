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
    
    var carModelName: String? = nil
    var categoryName: String? = nil
    
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
                    placeholder: "부품명 / 부품 코드 입력"
                )
                .padding()
                
                if isLoading {
                    ProgressView("검색 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredParts.isEmpty {
                    Spacer()
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredParts) { item in
                                let isDisabled = disabledCodes.contains(item.partCode)
                                Button {
                                    guard !isDisabled else { return }
                                    // RepairPartForm인 경우 partId와 partCode를 모두 설정
                                    if let repairPart = viewModel as? RepairPartForm {
                                        // MainActor에서 즉시 설정하여 UI 업데이트 보장
                                        repairPart.partId = Int(item.id)
                                        repairPart.partCode = item.partCode
                                        repairPart.partName = item.partName
                                        repairPart.unitPrice = item.price ?? 0.0
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
            .background(AppColor.background.ignoresSafeArea())
        }
        .task { await searchParts() }
    }
    
    private var filteredParts: [PartItem] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return partList
        } else {
            return partList.filter {
                $0.partName.localizedCaseInsensitiveContains(searchText)
                || $0.partCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// 화면 제목 자동 지정
        private var sheetTitle: String {
            if categoryName == "소모품" { return "소모품 검색" }
            if carModelName != nil { return "차량별 부품 검색" }
            return "부품 검색"
        }
        
        /// 검색 로직 통합
        private func searchParts() async {
            isLoading = true
            do {
                if let categoryName, !categoryName.isEmpty {
                    // ex) categoryName = "소모품"
                    partList = try await PurchaseOrderAPI.fetchIntegratedParts(categoryName: categoryName)
                } else if let carModelName, !carModelName.isEmpty {
                    // ex) carModelName = "아반떼"
                    partList = try await PurchaseOrderAPI.fetchIntegratedParts(carModelName: carModelName)
                } else {
                    // 기본 (전체 부품)
                    partList = try await PurchaseOrderAPI.fetchIntegratedParts()
                }
            } catch {
                print("부품 검색 오류:", error.localizedDescription)
                partList = []
            }
            isLoading = false
        }
}
