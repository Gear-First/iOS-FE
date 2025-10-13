import SwiftUI

struct CarSearchSheetView: View {
    @ObservedObject var viewModel: OrderRequestViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    let sampleList = [
        (number: "12가 3456", type: "소나타", requestId: "REQ001"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ002")
    ]

    var filteredList: [(number: String, type: String, requestId: String)] {
        if searchText.isEmpty { return sampleList }
        return sampleList.filter { $0.number.contains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("차량번호 입력", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(filteredList, id: \.requestId) { item in
                    Button {
                        viewModel.selectedCarNumber = item.number
                        viewModel.selectedCarType = item.type
                        dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text("차량번호: \(item.number)")
                            Text("차종: \(item.type)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("차량번호 검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
