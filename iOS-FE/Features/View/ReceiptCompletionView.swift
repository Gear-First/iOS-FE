import SwiftUI

struct ReceiptCompletionView: View {
    @ObservedObject var detailViewModel: ReceiptDetailViewModel
    @ObservedObject var formVM: ReceiptCompletionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPartSearch = false
    @State private var selectedPart: RepairPartForm?
    @State private var showQuantityPicker = false
    @State private var selectedQuantityPart: RepairPartForm?
    
    @State private var showConfirm = false
    @State private var showInvalidAlert = false
    
    init(detailViewModel: ReceiptDetailViewModel,
         formVM: ReceiptCompletionViewModel = ReceiptCompletionViewModel()) {
        self.detailViewModel = detailViewModel
        self.formVM = formVM
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("수리 완료 입력")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColor.mainTextBlack)
                    Text("사용한 부품과 수리 내용을 확인하고 최종 완료 처리하세요.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textMuted)
                }
                
                ForEach(formVM.items) { item in
                    RepairItemCard(
                        form: item,
                        completeParts: formVM.completeParts,
                        title: "수리 항목",
                        onShowPartSearch: { part in
                            selectedPart = part
                        },
                        onShowQuantityPicker: { part in
                            selectedQuantityPart = part
                            showQuantityPicker = true
                        },
                        showPartSection: true,
                        onShowContent: true
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .onAppear {
            Task {
                await formVM.fetchCompleteParts(
                    receiptNum: detailViewModel.item.id,
                    vehicleNumber: detailViewModel.item.carNumber
                )
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .sheet(item: $selectedPart) { part in
            // 이미 선택된 부품은 다시 선택 못하도록 막기
            let disabledCodes = Set(formVM.items.flatMap { $0.parts }
                .map { $0.partCode.isEmpty ? $0.code : $0.partCode })
            
            PartSearchSheetView(
                viewModel: part,
                disabledCodes: disabledCodes,
                categoryName: "소모품"
            )
            .presentationDetents([.large])
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
                
                Spacer()
                
                Button("완료") { selectedQuantityPart = nil }
                
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            .presentationDetents([.height(350)])
            .background(AppColor.background.ignoresSafeArea())
        }
        .alert("입력 값을 확인해주세요.", isPresented: $showInvalidAlert) {
            Button("확인", role: .cancel) {}
        }
        .alert("정말 완료 처리하시겠어요?", isPresented: $showConfirm) {
            Button("완료", role: .destructive) {
                Task {
                    await formVM.submitRepairDetails(receiptId: detailViewModel.item.id, formVM: formVM)
                    //                    await detailViewModel.fetchReceiptDetail(id: detailViewModel.item.id)
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomActionBar
        }
        .navigationTitle("수리 완료 입력")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ReceiptCompletionView(
            detailViewModel: ReceiptDetailViewModel(
                item: ReceiptItem(
                    id: "CHK-2025",
                    carNumber: "34가 5678",
                    ownerName: "이수진",
                    carModel: "그랜저",
                    requestContent: "에어컨 고장 수리 요청",
                    date: "2025-10-13",
                    phoneNumber: "010-3456-7890",
                    manager: "티파니 송",
                    status: .inProgress
                )
            )
        )
    }
}

private extension ReceiptCompletionView {
    var bottomActionBar: some View {
        VStack(spacing: 16) {
            Divider().overlay(AppColor.cardBorder)
            BaseButton(label: "완료 제출", backgroundColor: AppColor.mainGreen) {
                if formVM.isCompletionValid() {
                    showConfirm = true
                } else {
                    showInvalidAlert = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .background(AppColor.surface.ignoresSafeArea())
    }
}
