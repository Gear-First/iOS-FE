import SwiftUI

struct OrderRequestView: View {
    // 🟩 [수정됨] 기존 OrderRequestViewModel → CheckInDetailViewModel 로 교체
        // ⚙️ [수정됨] item 파라미터 없이 초기화 불가 → 기본 CheckInItem 생성 후 전달
        @StateObject private var viewModel = CheckInDetailViewModel(
            item: CheckInItem(
                id: UUID().uuidString,           // 자동 생성
                carNumber: "",                   // UI에서 입력받음
                ownerName: "",                   // 기본값
                carModel: "",                    // UI에서 입력받음
                requestContent: "",              // 기본값
                date: Date().formatted(),        // 오늘 날짜
                phoneNumber: "",                 // 기본값
                manager: "",                     // 기본값
                status: .checkIn,                // 초기 상태
                leadTimeDays: nil                // 기본값
            )
        )
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
                            // 🟩 [유지] 차량 선택 버튼은 그대로 두되, 데이터 바인딩 대상만 변경
                            EditableField(
                                value: .constant(""),
                                placeholder: "차량번호를 선택하세요",
                                isEditable: false
                            ) {
                                showCarSearch.toggle()
                            }
                            
                            // 🟩 [수정됨] viewModel.selectedCarNumber → viewModel.item.carNumber
                            if !viewModel.item.carNumber.isEmpty {
                                HStack {
                                    Text("차량번호")
                                    Spacer()
                                    Text(viewModel.item.carNumber)
                                }
                                .padding(.top, 4)
                                
                                // 🟩 [수정됨] viewModel.selectedCarType → viewModel.item.carModel
                                HStack {
                                    Text("차종")
                                    Spacer()
                                    Text(viewModel.item.carModel)
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        // MARK: - 부품 선택
                        // 🟩 [수정됨] 조건문: selectedCarNumber → item.carNumber
                        if !viewModel.item.carNumber.isEmpty {
                            SectionCard(title: "부품 선택") {
                                EditableField(
                                    value: .constant(""),
                                    placeholder: "부품을 선택하세요",
                                    isEditable: false
                                ) {
                                    showPartSearch.toggle()
                                }
                                
                                // 🟩 [수정됨] orderName/orderCode 제거 → partName 만 사용
                                if let partName = viewModel.item.partName, !partName.isEmpty {
                                    HStack {
                                        Text("부품명")
                                        Spacer()
                                        Text(partName)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                        
                        // MARK: - 수량 입력
                        // 🟩 [수정됨] 조건문: orderName → item.partName
                        if let _ = viewModel.item.partName {
                            SectionCard(title: "수량 입력") {
                                HStack {
                                    // 🟩 [수정됨] Binding으로 Int ↔️ String 변환 처리
                                    EditableField(
                                        value: Binding(
                                            get: { String(viewModel.item.partQuantity ?? 1) },
                                            set: { viewModel.item.partQuantity = Int($0) ?? 1 }
                                        ),
                                        placeholder: "수량",
                                        isEditable: true
                                    )
                                    
                                    VStack(spacing: 0) {
                                        // 🟩 [수정됨] viewModel.orderQuantity → item.partQuantity
                                        Button(action: {
                                            viewModel.item.partQuantity = (viewModel.item.partQuantity ?? 1) + 1
                                        }) {
                                            Image(systemName: "chevron.up")
                                                .frame(width: 24, height: 24)
                                        }
                                        Button(action: {
                                            if (viewModel.item.partQuantity ?? 1) > 1 {
                                                viewModel.item.partQuantity! -= 1
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
//                 🟩 [유지 + 수정] sheet도 동일 ViewModel 전달
                .sheet(isPresented: $showCarSearch) {
                    CarSearchSheetView(viewModel: viewModel)
                }
                .sheet(isPresented: $showPartSearch) {
                    PartSearchSheetView(viewModel: viewModel)
                }
                
                // MARK: - 요청 버튼
                BaseButton(
                    label: "요청하기",
                    backgroundColor: isValid() ? AppColor.mainBlue : AppColor.mainTextGray.opacity(0.4)
                ) {

                    if let newOrderItem = OrderItem(from: viewModel.item) {
                        historyViewModel.addNewItem(newOrderItem)
                        resetForm()
                        dismiss()
                    } else {
                        // 이니셜라이저가 nil을 반환하는 경우 (이론상 isValid() 때문에 발생하지 않음)
                        print("오류: OrderItem으로 변환하는데 필요한 정보가 부족합니다.")
                    }
                }
                .disabled(!isValid())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(AppColor.bgGray)
        }
    }
}

// MARK: - Helper
extension OrderRequestView {
    // 🟩 [신규 추가] OrderRequestViewModel 의 isValid() 로직 이관
    private func isValid() -> Bool {
        guard
            let partName = viewModel.item.partName,
            !partName.isEmpty,
            let quantity = viewModel.item.partQuantity,
            quantity > 0
        else { return false }
        return true
    }
    
    // 🟩 [신규 추가] form reset 기능 (기존 ViewModel.resetForm() 대체)
    private func resetForm() {
        viewModel.item.partName = nil
        viewModel.item.partQuantity = nil
    }
}

//#Preview {
//    // 🟩 [테스트용 Mock 데이터 추가]
//    let mockItem = CheckInItem(
//        id: "CHK001",
//        carNumber: "12가3456",
//        ownerName: "홍길동",
//        carModel: "쏘나타",
//        requestContent: "브레이크 소음 발생",
//        date: "2025-10-16",
//        phoneNumber: "010-1234-5678",
//        manager: "김정훈",
//        status: .checkIn,
//        leadTimeDays: nil
//    )
//    let viewModel = CheckInDetailViewModel(item: mockItem)
//    let historyVM = OrderHistoryViewModel()
//    return OrderRequestView(viewModel: viewModel, historyViewModel: historyVM)
//}
