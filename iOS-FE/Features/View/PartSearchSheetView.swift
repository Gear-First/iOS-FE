import SwiftUI
import Foundation

protocol PartSelectable: ObservableObject {
    var name: String { get set }
    var code: String { get set }
}

struct PartSearchSheetView<ViewModel: PartSelectable>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    let partList = [
        (name: "브레이크 패드", code: "P001"),
        (name: "에어필터", code: "P002"),
        (name: "오일필터", code: "P003")
    ]

    var filteredList: [(name: String, code: String)] {
        if searchText.isEmpty { return partList }
        return partList.filter { $0.name.contains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack {
                EditableField(
                    value: $searchText,
                    placeholder: "부품명을 입력해주세요"
                )
                .padding(.horizontal, 12)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredList, id: \.code) { item in
                            partRow(item)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top)
            }
            .navigationTitle("부품 검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func partRow(_ item: (name: String, code: String)) -> some View {
        Button(action: {
            viewModel.name = item.name
            viewModel.code = item.code
            dismiss()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(AppColor.mainBlack)
                }
                Text(item.code)
                    .font(.subheadline)
                    .foregroundColor(AppColor.mainTextGray)
                Divider()
                    .padding(.vertical, 6)
            }
        }
    }
}




#Preview {
    let mockViewModel = OrderRequestViewModel()
    return PartSearchSheetView(viewModel: mockViewModel)
}
