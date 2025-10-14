import SwiftUI

struct OrderRequestView: View {
    @StateObject private var viewModel = OrderRequestViewModel()
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showCarSearch = false
    @State private var showPartSearch = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - 차량 선택
                        SectionCard(title: "차량 선택") {
                            EditableField(
                                value: .constant(""),
                                placeholder: "차량번호를 선택하세요",
                                isEditable: false) {
                                    showCarSearch.toggle()
                                }
                            
                            if !viewModel.selectedCarType.isEmpty {
                                HStack {
                                    Text("차량번호")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(viewModel.selectedCarNumber)
                                        .font(.subheadline)
                                }
                                .padding(.top, 4)
                                HStack {
                                    Text("차종")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(viewModel.selectedCarType)
                                        .font(.subheadline)
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        // MARK: - 부품 선택
                        if !viewModel.selectedCarNumber.isEmpty {
                            SectionCard(title: "부품 선택") {
                                EditableField(
                                    value: .constant(""),
                                    placeholder: "부품을 선택하세요",
                                    isEditable: false) {
                                        showPartSearch.toggle()
                                    }
                                
                                if !viewModel.orderCode.isEmpty {
                                    HStack {
                                        Text("부품명")
                                            .font(.subheadline)
                                        Spacer()
                                        Text(viewModel.orderName)
                                            .font(.subheadline)
                                    }
                                    .padding(.top, 4)
                                    HStack {
                                        Text("부품 코드")
                                            .font(.subheadline)
                                        Spacer()
                                        Text(viewModel.orderCode)
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
                                    EditableField(
                                        value: $viewModel.orderQuantity,
                                        placeholder: "수량",
                                        isEditable: true)
                                    
                                    VStack(spacing: 0) {
                                        Button(action: { viewModel.orderQuantity += 1 }) {
                                            Image(systemName: "chevron.up")
                                                .frame(width: 24, height: 24)
                                        }
                                        Button(action: {
                                            if viewModel.orderQuantity > 1 {
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
                    }
                }
                .navigationTitle("부품 요청")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showCarSearch) {
                    CarSearchSheetView(viewModel: viewModel)
                }
                .sheet(isPresented: $showPartSearch) {
                    PartSearchSheetView(viewModel: viewModel)
                }
                // MARK: - 요청 버튼
                BaseButton(
                    label: "요청하기",
                    backgroundColor: viewModel.isValid() ? AppColor.mainBlue : AppColor.mainTextGray.opacity(0.4)
                ) {
                    let newItem = viewModel.submitRequestOrder()
                    historyViewModel.addNewItem(newItem)
                    viewModel.resetForm()
                    dismiss()
                }
                .disabled(!viewModel.isValid())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    let historyVM = OrderHistoryViewModel()
    OrderRequestView(historyViewModel: historyVM)
}
