import SwiftUI

struct CarSearchSheetView: View {
    @ObservedObject var viewModel: OrderRequestViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    let sampleList = [
        (number: "12가 3456", type: "소나타", requestId: "REQ001"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ002"),
        (number: "12가 3456", type: "소나타", requestId: "REQ003"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ004"),
        (number: "12가 3456", type: "소나타", requestId: "REQ005"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ006"),
        (number: "12가 3456", type: "소나타", requestId: "REQ007"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ008"),
        (number: "12가 3456", type: "소나타", requestId: "REQ009"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ010"),
        (number: "12가 3456", type: "소나타", requestId: "REQ011"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ012"),
        (number: "12가 3456", type: "소나타", requestId: "REQ013"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ014"),
        (number: "12가 3456", type: "소나타", requestId: "REQ015"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ016"),
        (number: "12가 3456", type: "소나타", requestId: "REQ017"),
        (number: "34나 7890", type: "그랜저", requestId: "REQ018"),
        
    ]

    var filteredList: [(number: String, type: String, requestId: String)] {
        if searchText.isEmpty { return sampleList }
        return sampleList.filter { $0.number.contains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack {
                EditableField(
                    value: $searchText,
                    placeholder: "차량번호를 입력해주세요"
                )
                .padding(.horizontal, 12)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredList, id: \.requestId) { item in
                            Button {
                                viewModel.selectedCarNumber = item.number
                                viewModel.selectedCarType = item.type
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(item.number)
                                            .font(.headline)
                                            .foregroundColor(AppColor.mainBlack)
                                        Spacer()
                                        Text(item.requestId)
                                            .font(.caption)
                                            .foregroundColor((AppColor.mainTextGray))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(
                                                RoundedRectangle(cornerRadius:4)
                                                    .fill(AppColor.mainBorderGray.opacity(0.6))
                                            )
                                    }
                                    Text(item.type)
                                        .font(.subheadline)
                                        .foregroundColor(AppColor.mainTextGray)
                                    Divider()
                                        .padding(.vertical, 6)
                                }
                                
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("차량번호 검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let mockViewModel = OrderRequestViewModel()
    return CarSearchSheetView(viewModel: mockViewModel)
}
