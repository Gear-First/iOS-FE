import SwiftUI

struct OrderRequestView: View {
    @StateObject private var viewModel = OrderRequestViewModel()
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @ObservedObject var formVM: CheckInCompletionViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showCarSearch = false
    @State private var showPartSearch = false
    @State private var selectedPart: RepairPartForm?
    @State private var showQuantityPicker = false
    @State private var selectedQuantityPart: RepairPartForm?

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - 차량 선택
                        SectionCard(title: "차량 선택") {
                            EditableField(
                                value: .constant(viewModel.selectedVehicle?.plateNumber ?? ""),
                                placeholder: "차량번호를 선택하세요",
                                isEditable: false
                            ) {
                                showCarSearch.toggle()
                            }

                            if let vehicle = viewModel.selectedVehicle {
                                HStack {
                                    Text("차량번호")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(vehicle.plateNumber)
                                        .font(.subheadline)
                                }
                                .padding(.top, 4)
                                HStack {
                                    Text("차종")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(vehicle.model)
                                        .font(.subheadline)
                                }
                                .padding(.top, 4)
                                HStack {
                                    Text("제조사")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(vehicle.manufacturer)
                                        .font(.subheadline)
                                }
                                .padding(.top, 4)
                            }
                        }

                        // MARK: - 항목
                        ForEach(formVM.items) { item in
                            RepairItemCard(
                                form: item,
                                title: "항목",
                                onRemove: {
                                    if formVM.items.count > 1 {
                                        formVM.removeItem(item.id)
                                    }
                                },
                                onShowPartSearch: { part in
                                    selectedPart = part
                                },
                                onShowQuantityPicker: { part in
                                    selectedQuantityPart = part
                                    showQuantityPicker = true
                                },
                                onShowContent: false
                            )
                        }
                    }
                }
                .navigationTitle("부품 요청")
                .navigationBarTitleDisplayMode(.inline)

                // MARK: - 요청 버튼
                BaseButton(
                    label: "요청하기",
                    backgroundColor: viewModel.isValid ? AppColor.mainBlue : AppColor.mainTextGray.opacity(0.4)
                ) {
                    if let newItem = viewModel.submitRequestOrder() {
                        historyViewModel.addNewItem(newItem)
                        viewModel.resetForm()
                        dismiss()
                    }
                }
                .disabled(!viewModel.isValid)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(AppColor.bgGray)
            // MARK: - Sheets
            .sheet(isPresented: $showCarSearch) {
                CarSearchSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $showPartSearch) {
                PartSearchSheetView(viewModel: viewModel)
            }
            .sheet(item: $selectedPart) { part in
                PartSearchSheetView(viewModel: part)
                    .presentationDetents([.height(420)])
            }
            .sheet(item: $selectedQuantityPart) { part in
                VStack {
                    Text("수량 선택")
                        .font(.headline)
                        .padding()
                    Divider()
                    Picker("수량", selection: Binding(
                        get: { part.quantity },
                        set: { part.quantity = $0 }
                    )) {
                        ForEach(1..<101, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()

                    Button("완료") {
                        selectedQuantityPart = nil
                    }
                    .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .presentationDetents([.height(350)])
            }
        }
    }
}
