import SwiftUI

struct CheckInCompletionView: View {
    @ObservedObject var detailViewModel: CheckInDetailViewModel
    @ObservedObject var formVM: CheckInCompletionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPartSearch = false
    @State private var selectedPart: RepairPartForm?
    @State private var showQuantityPicker = false
    @State private var selectedQuantityPart: RepairPartForm?
    
    @State private var showConfirm = false
    @State private var showInvalidAlert = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - 카드 리스트
                    ForEach(formVM.items) { item in
                        RepairItemCard(
                            form: item,
                            title: "수리 항목",
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
                            onShowContent: true
                            )
                        }
                    // MARK: - 수리 항목 추가 버튼
                    Button {
                        if formVM.canAddNewItem() {
                            formVM.addItem()
                        } else {
                            showInvalidAlert = true
                        }
                    } label: {
                        Label("수리 항목 추가", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            
            // MARK: - 완료 제출 버튼
            BaseButton(label: "완료 제출", backgroundColor: .green) {
                if formVM.canAddNewItem() {
                    showConfirm = true
                } else {
                    showInvalidAlert = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(AppColor.bgGray).ignoresSafeArea())
        .navigationTitle("수리 완료 입력")
        .navigationBarTitleDisplayMode(.inline)
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
        .alert("입력 값을 확인해주세요.", isPresented: $showInvalidAlert) {
            Button("확인", role: .cancel) {}
        }
        .alert("정말 완료 처리하시겠어요?", isPresented: $showConfirm) {
            Button("완료", role: .destructive) {
                Task {
                    await formVM.submitRepairDetails(receiptId: detailViewModel.item.id, formVM: formVM)
                    DispatchQueue.main.async {
                        detailViewModel.item.status = .completed
                        dismiss()
                    }
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("제출 후에는 상태를 되돌릴 수 없습니다.")
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        CheckInCompletionView(
            detailViewModel: CheckInDetailViewModel(
                item: CheckInItem(
                    id: "CHK-2025",
                    carNumber: "34가 5678",
                    ownerName: "이수진",
                    carModel: "그랜저",
                    requestContent: "에어컨 고장 수리 요청",
                    date: "2025-10-13",
                    phoneNumber: "010-3456-7890",
                    manager: "송지은",
                    status: .inProgress
                )
            ),
            formVM: CheckInCompletionViewModel()
        )
    }
}
