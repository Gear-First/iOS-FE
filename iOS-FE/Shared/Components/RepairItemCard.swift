import SwiftUI

struct RepairItemCard: View {
    @ObservedObject var form: RepairItemForm
    var onRemove: (() -> Void)?
    @State private var showPartSearch = false
    @State private var showQuantityPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("수리 항목")
                    .font(.headline)
                Spacer()
                if let onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            Divider()
            
            // 수리 내용
            EditableField(
                value: $form.description,
                placeholder: "수리 내용",
                isEditable: true
            )
            
            // 원인
            EditableField(
                value: $form.cause,
                placeholder: "원인",
                isEditable: true
            )
            
            // 부품 선택
            EditableField(
                value: $form.partName,
                placeholder: "부품 선택",
                isEditable: false
            ) {
                showPartSearch.toggle()
            }
            .onChange(of: form.partName) { _ in
                // 부품 선택 후 자동 랜덤 가격 설정
                form.parentViewModel?.autofillRandomPrice(for: form)
            }
            
            // MARK: 수량 + 가격
            HStack(spacing: 8) {
                // 가격(개당)
                VStack(alignment: .leading, spacing: 4) {
                    EditableField(
                        value: $form.unitPrice,
                        placeholder: "가격(개당)",
                        isEditable: true
                    )
                    .keyboardType(.numbersAndPunctuation)
                    .frame(maxWidth: .infinity)
                }
                // 수량 (아이콘 포함)
                ZStack {
                    EditableField(
                        value: $form.quantity,
                        placeholder: "수량",
                        isEditable: true
                    )
                    .keyboardType(.numberPad)
                    .padding(.trailing, 36) // 아이콘 공간 확보
                    
                    HStack {
                        Spacer()
                        Button(action: { showQuantityPicker = true }) {
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(AppColor.mainTextGray)
                                .frame(width: 36, height: 44)
                                .background(AppColor.mainWhite)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .background(AppColor.mainWhite)
                .cornerRadius(10)
                .shadow(color: AppColor.mainBlack.opacity(0.05), radius: 3, x: 0, y: 1)
                .frame(width: 120)
            }
            
            HStack {
                Spacer()
                Text("\(Int(form.totalPrice))원")
                    .font(.headline)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
//        .sheet(isPresented: $showPartSearch) {
//            PartSearchSheetView(viewModel: form)
//        }
        .sheet(isPresented: $showQuantityPicker) {
            VStack {
                Text("수량 선택")
                    .font(.headline)
                    .padding()
                Divider()
                Picker("수량", selection: $form.quantity) {
                    ForEach(1..<101, id: \.self) { num in
                        Text("\(num)").tag(num)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                
                Button("완료") {
                    showQuantityPicker = false
                }
                .padding()
            }
            .presentationDetents([.fraction(0.4)])
        }
    }
}

#Preview {
    let repairForm = RepairItemForm()
    repairForm.description = "엔진 오일 교체"
    repairForm.cause = "주행거리 10,000km 이상"
    repairForm.partName = "엔진오일"
    repairForm.unitPrice = 45000
    repairForm.quantity = 2
    
    return RepairItemCard(form: repairForm, onRemove: {
        print("삭제")
    })
    .padding()
}
