import SwiftUI

struct PartSearchSheetView: View {
    @ObservedObject var viewModel: OrderRequestViewModel
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
                TextField("부품명 입력", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(filteredList, id: \.code) { part in
                    Button {
                        viewModel.orderName = part.name
                        viewModel.orderCode = part.code
                        dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(part.name)
                            Text("코드: \(part.code)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("부품 검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
