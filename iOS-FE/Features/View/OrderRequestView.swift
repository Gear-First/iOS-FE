import SwiftUI

struct OrderRequestView: View {
    @StateObject private var viewModel: OrderRequestViewModel
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @ObservedObject var formVM: ReceiptCompletionViewModel
    let receiptNum: String
    let onOrderCreated: (OrderHistoryItem) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var showCarSearch = false
    @State private var selectedPart: RepairPartForm?
    @State private var showQuantityPicker = false
    @State private var selectedQuantityPart: RepairPartForm?
    @State private var navigateToHistory = false

    @State private var showInvalidAlert = false
    @State private var showConfirmAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    @State private var isOrderSubmitted = false  // 발주 제출 완료 여부

    let isFromReceipt: Bool  // 내접수에서 발주한 경우 true
    
    init(
        historyViewModel: OrderHistoryViewModel,
        formVM: ReceiptCompletionViewModel,
        initialVehicle: ReceiptVehicle? = nil,
        receiptNum: String,
        isFromReceipt: Bool = false,
        onOrderCreated: @escaping (OrderHistoryItem) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: OrderRequestViewModel(initialVehicle: initialVehicle))
        self.historyViewModel = historyViewModel
        self.formVM = formVM
        self.receiptNum = receiptNum
        self.isFromReceipt = isFromReceipt
        self.onOrderCreated = onOrderCreated
    }

    private var isFormValid: Bool {
        guard !formVM.items.isEmpty else { return false }
        for item in formVM.items {
            if item.parts.isEmpty { return false }
            for part in item.parts {
                if part.partName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
                if part.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
            }
        }
        return true
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("발주 요청서 작성")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColor.mainTextBlack)
                    Text("필요한 수리 항목과 부품 정보를 입력해 요청을 생성합니다.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textMuted)
                }
                
                ForEach(formVM.items) { item in
                    RepairItemCard(
                        form: item,
                        title: "발주 항목",
                        onRemove: { if formVM.items.count > 1 { formVM.removeItem(item.id) } },
                        onShowPartSearch: { selectedPart = $0 },
                        onShowQuantityPicker: { selectedQuantityPart = $0; showQuantityPicker = true },
                        onShowContent: false
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("부품 요청")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { bottomButtonSection }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showCarSearch) { CarSearchSheetView(viewModel: viewModel) }
        .sheet(item: $selectedPart) { part in
            let disabledCodes = Set(formVM.items.flatMap { $0.parts }.map { $0.partCode.isEmpty ? $0.code : $0.partCode })
            PartSearchSheetView(viewModel: part, disabledCodes: disabledCodes)
                .presentationDetents([.height(420)])
        }
        .sheet(item: $selectedQuantityPart) { quantityPickerSheet(part: $0) }
        .alert("입력값을 확인해주세요.", isPresented: $showInvalidAlert) {
            Button("확인", role: .cancel) { }
        }
        .alert("정말 요청하시겠습니까?", isPresented: $showConfirmAlert) { confirmButtons }
        .alert("발주 요청 실패", isPresented: $showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onDisappear {
            // 발주 제출이 완료되지 않은 상태에서 화면을 벗어나면 데이터 초기화
            if !isOrderSubmitted {
                viewModel.resetForm()
                formVM.resetForm()
            }
        }
    }

    // MARK: - Content Section
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            Divider().overlay(AppColor.cardBorder)
            BaseButton(
                label: "요청하기",
                backgroundColor: AppColor.mainBlue,
                textColor: AppColor.mainWhite
            ) {
                if !isFormValid { showInvalidAlert = true } else { showConfirmAlert = true }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .background(AppColor.surface.ignoresSafeArea())
    }

    // MARK: - Quantity Picker Sheet
    @ViewBuilder
    private func quantityPickerSheet(part: RepairPartForm) -> some View {
        VStack {
            Text("수량 선택").font(.headline).padding()
            Divider()
            Picker("수량", selection: Binding(get: { part.quantity }, set: { part.quantity = $0 })) {
                ForEach(1..<101, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            Button("완료") { selectedQuantityPart = nil }
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        .presentationDetents([.height(350)])
    }

    // MARK: - Confirm Buttons
    @ViewBuilder
    private var confirmButtons: some View {
        Button("취소", role: .cancel) { }
        Button("요청", role: .destructive) { submitOrder() }
    }

    // MARK: - Submit Order
    private func submitOrder() {
        Task {
            guard let createdOrder = await viewModel.submitOrderToServer(
                requesterId: 10, // 예시: 로그인된 엔지니어 ID
                requesterName: "티파니 송", // 실제 사용자 이름
                requesterRole: "엔지니어", // 직책 or 역할
                requesterCode: "서울 대리점", // 대리점 코드
                items: formVM.items,
                receiptNum: receiptNum
            ) else {
                // 에러 메시지 표시
                await MainActor.run {
                    if let vmErrorMessage = viewModel.errorMessage {
                        errorMessage = vmErrorMessage
                    } else {
                        errorMessage = "발주 요청 중 오류가 발생했습니다. 다시 시도해주세요."
                    }
                    showErrorAlert = true
                }
                return
            }
            
            await MainActor.run {
                historyViewModel.addNewOrder(createdOrder)
                isOrderSubmitted = true  // 발주 제출 완료 표시
                viewModel.resetForm()
                formVM.resetForm()
                
                // 내접수에서 발주한 경우에는 발주 상세보기로 가지 않고 그냥 뒤로가기만
                if !isFromReceipt {
                    onOrderCreated(createdOrder)
                }
                dismiss()
            }
        }
    }

}
