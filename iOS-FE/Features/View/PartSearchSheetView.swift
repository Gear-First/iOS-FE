import SwiftUI
import Foundation

protocol PartSelectable: ObservableObject {
    var name: String { get set }
    var code: String { get set }
}

// 제네릭 플레이스홀더의 이름을 관례에 따라 대문자 한 글자(T)나 명확한 ViewModel 등으로 변경하는 것이 좋으나,
// 여기서는 기존 코드와의 일관성을 위해 ViewModel을 그대로 사용한다.
struct PartSearchSheetView<ViewModel: PartSelectable>: View {
    // MARK: - ⚙️ [오류 1 수정] 프로퍼티 타입을 제네릭 플레이스홀더로 변경
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
            // MARK: - ⚙️ [오류 2 수정] 프로토콜이 보장하는 프로퍼티에 직접 접근
            viewModel.name = item.name
            viewModel.code = item.code
            dismiss()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(AppColor.mainBlack) // AppColor가 정의되어 있다고 가정
                }
                Text(item.code)
                    .font(.subheadline)
                    .foregroundColor(AppColor.mainTextGray) // AppColor가 정의되어 있다고 가정
                Divider()
                    .padding(.vertical, 6)
            }
        }
    }
}
