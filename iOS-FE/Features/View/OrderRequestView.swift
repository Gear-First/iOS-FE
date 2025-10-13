import SwiftUI

struct OrderRequestView: View {
    @StateObject private var viewModel = OrderRequestViewModel()
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showCarSearch = false
    @State private var showPartSearch = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 차량 선택
                    SectionCard(title: "차량 선택") {
                        Button(action: {
                            showCarSearch.toggle()
                        }) {
                            HStack {
                                Text("차량번호를 선택하세요")
                                    .foregroundColor(AppColor.mainGray)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppColor.mainGray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColor.mainWhite)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        }

                        if !viewModel.selectedCarType.isEmpty {
                            HStack {
                                Text("차량번호")
                                    .font(.subheadline)
                                Spacer()
                                Text(viewModel.selectedCarNumber)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            .padding(.top, 4)
                            HStack {
                                Text("차종")
                                    .font(.subheadline)
                                Spacer()
                                Text(viewModel.selectedCarType)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            .padding(.top, 4)
                        }
                    }

                    // MARK: - 부품 선택
                    if !viewModel.selectedCarNumber.isEmpty {
                        SectionCard(title: "부품 선택") {
                            Button(action: {
                                showPartSearch.toggle()
                            }) {
                                HStack {
                                    Text(viewModel.orderName.isEmpty ? "부품을 선택하세요" : viewModel.orderName)
                                        .foregroundColor(viewModel.orderName.isEmpty ? .gray : .black)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            }

                            if !viewModel.orderCode.isEmpty {
                                HStack {
                                    Text("부품 코드")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(viewModel.orderCode)
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }

                    // MARK: - 수량 입력
                    if !viewModel.orderName.isEmpty {
                        SectionCard(title: "수량 입력") {
                            HStack {
                                TextField("수량 입력", value: $viewModel.orderQuantity, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)

                                VStack(spacing: 0) {
                                    Button(action: { viewModel.orderQuantity += 1 }) {
                                        Image(systemName: "chevron.up")
                                            .frame(width: 24, height: 24)
                                    }
                                    Button(action: {
                                        if viewModel.orderQuantity > 0 {
                                            viewModel.orderQuantity -= 1
                                        }
                                    }) {
                                        Image(systemName: "chevron.down")
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                .padding(.leading, 4)
                            }
                        }
                    }

                    // MARK: - 요청 버튼
                    Button(action: {
                        let newItem = viewModel.submitRequestOrder()
                        historyViewModel.addNewItem(newItem)
                        viewModel.resetForm()
                        dismiss()
                    }) {
                        Text("요청하기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.headline)
                            .background(viewModel.isValid() ? AppColor.mainBlue : Color.gray.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .disabled(!viewModel.isValid())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("부품 요청")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCarSearch) {
                CarSearchSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $showPartSearch) {
                PartSearchSheetView(viewModel: viewModel)
            }
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    OrderRequestView(historyViewModel: OrderHistoryViewModel())
}
