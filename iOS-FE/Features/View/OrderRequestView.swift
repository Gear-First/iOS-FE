import SwiftUI

struct OrderRequestView: View {
    @StateObject private var viewModel = OrderRequestViewModel()
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @ObservedObject var formVM: ReceiptCompletionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showCarSearch = false
    @State private var selectedPart: RepairPartForm?
    @State private var showQuantityPicker = false
    @State private var selectedQuantityPart: RepairPartForm?
    @State private var navigateToHistory = false
    
    // Alert 상태
    @State private var showInvalidAlert = false
    @State private var showConfirmAlert = false
    
    private var isFormValid: Bool {
        // 차량 정보 유효성 검사
        guard let vehicle = viewModel.selectedVehicle,
              !vehicle.carNum.isEmpty,
              !vehicle.carType.isEmpty
        else {
            return false
        }
        // 항목 유효성 검사
        guard !formVM.items.isEmpty else { return false }
        // 부품 유효성 검사
        for item in formVM.items {
            if item.parts.isEmpty { return false }
            for part in item.parts {
                if part.partName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
                if part.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
                if part.quantity < 1 { return false }
            }
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - 차량 선택
                        SectionCard(title: "차량 선택") {
                            EditableField(
                                value: .constant(viewModel.selectedVehicle?.carNum ?? ""),
                                placeholder: "차량번호를 선택하세요",
                                isEditable: false
                            ) {
                                showCarSearch.toggle()
                            }
                            
                            if let vehicle = viewModel.selectedVehicle {
                                Group {
                                    HStack {
                                        Text("차량번호")
                                        Spacer()
                                        Text(vehicle.carNum)
                                    }
                                    HStack {
                                        Text("차종")
                                        Spacer()
                                        Text(vehicle.carType)
                                    }
                                }
                                .font(.subheadline)
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
                    backgroundColor: AppColor.mainBlue,
                    textColor: AppColor.mainWhite
                ) {
                    if !isFormValid {
                        showInvalidAlert = true
                    } else {
                        showConfirmAlert = true
                    }
                }
                
                NavigationLink(
                    destination: OrderHistoryView(), // OrderHistoryView가 기본 생성자만 있을 때
                    isActive: $navigateToHistory
                ) { EmptyView() }
                .hidden()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(AppColor.bgGray)
            
            // MARK: - Sheets
            .sheet(isPresented: $showCarSearch) {
                CarSearchSheetView(viewModel: viewModel)
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
            
            // MARK: - Alerts
            .alert("입력값을 확인해주세요.", isPresented: $showInvalidAlert) {
                Button("확인", role: .cancel) { }
            }
            
            .alert("정말 요청하시겠습니까?", isPresented: $showConfirmAlert) {
                Button("취소", role: .cancel) { }
                Button("요청", role: .destructive) {
                    Task {
                        let success = await viewModel.submitOrderToServer(
                            engineerId: 123,
                            branchId: 1,
                            items: formVM.items
                        )
                        
                        if success {
                            // 서버 성공 후: 로컬 히스토리에 1건 추가(모델 분리 유지)
                            if let newOrder = viewModel.submitRequestOrder() {
                                let historyItem = makeLocalHistoryItem(from: newOrder)
                                historyViewModel.addNewOrder(historyItem)
                            }
                            viewModel.resetForm()
                            formVM.resetForm()
                            navigateToHistory = true
                        } else {
                            print("발주 요청 실패")
                        }
                    }
                }
            }
        }
    }
    
    // 로컬 OrderItem → 조회용 OrderHistoryItem(임시) 매핑
    // 서버에서 생성된 정확한 값이 필요하면, addNewOrder 대신 목록 재조회(API)로 교체
    private func makeLocalHistoryItem(from item: OrderItem) -> OrderHistoryItem {
        OrderHistoryItem(
            orderId: Int.random(in: 10000...99999),
            orderNumber: "PO-\(Int(Date().timeIntervalSince1970))",
            status: "PENDING",
            totalPrice: 0, // 서버가 계산하는 값이면 0 또는 추정치
            requestDate: item.requestDate ?? "",
            approvedDate: nil,
            transferDate: nil,
            completedDate: nil,
            items: [
                OrderHistoryPart(
                    id: Int.random(in: 1...9999),
                    inventoryName: item.inventoryName,
                    inventoryCode: item.inventoryCode,
                    price: 0,
                    quantity: item.quantity
                )
            ]
        )
    }
}
