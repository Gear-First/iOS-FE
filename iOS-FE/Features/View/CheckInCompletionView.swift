import SwiftUI

struct CheckInCompletionView: View {
    @ObservedObject var detailViewModel: CheckInDetailViewModel
    @StateObject private var formVM = CheckInCompletionViewModel()
    @State private var showDatePicker: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirm = false
    @State private var showInvalidAlert = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ScrollView는 입력 폼만 스크롤되게
                ScrollView {
                    VStack(spacing: 12) {
                        Spacer().frame(height: 8)
                        
                        // MARK: 수리내용
                        TextField("수리내용", text: $formVM.repairDescription)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .cornerRadius(8)
                        
                        // MARK: 원인
                        TextField("원인", text: $formVM.cause)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .cornerRadius(8)
                        
                        // MARK: 완료일
                        HStack(spacing: 0) {
                            TextField("완료일 (yyyy-MM-dd)", text: $formVM.rawDateInput, onEditingChanged: { _ in
                                formVM.syncDateFromText()
                            })
                            .keyboardType(.numbersAndPunctuation)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            
                            Button(action: {
                                withAnimation { showDatePicker.toggle() }
                            }) {
                                Image(systemName: "calendar")
                                    .padding(.horizontal, 12)
                                    .foregroundColor(.blue)
                            }
                        }
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .cornerRadius(8)
                        
                        if showDatePicker {
                            DatePicker("", selection: $formVM.completionDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .onChange(of: formVM.completionDate) { _ in
                                    formVM.syncTextFromDate()
                                }
                        }
                        
                        // MARK: 부품명
                        TextField("부품명", text: $formVM.partName, onEditingChanged: { _ in
                            formVM.autofillPriceIfMatches()
                        })
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .cornerRadius(8)
                        
                        // MARK: 수량 + 가격
                        HStack {
                            TextField("수량", value: $formVM.partQuantity, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                                .frame(height: 48)
                            
                            VStack(spacing: 0) {
                                Button(action: { formVM.partQuantity += 1 }) {
                                    Image(systemName: "chevron.up").frame(width: 24, height: 24)
                                }
                                Button(action: { if formVM.partQuantity > 1 { formVM.partQuantity -= 1 } }) {
                                    Image(systemName: "chevron.down").frame(width: 24, height: 24)
                                }
                            }
                            .padding(.trailing, 8)
                            
                            TextField("가격(개당)", value: $formVM.partPrice, formatter: currencyFormatter)
                                .keyboardType(.numbersAndPunctuation)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                        }
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .cornerRadius(8)
                        
                        // MARK: 총가격
                        HStack {
                            Text("총가격")
                            Spacer()
                            Text(numberToCurrency(formVM.totalPrice))
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 20) // 버튼 영역과 간격 확보
                }
                
                // 하단 고정 버튼
                VStack {
                    BaseButton(label: "완료 제출", backgroundColor: Color.green) {
                        if let info = formVM.buildCompletionInfo() {
                            showConfirm = true
                        } else {
                            showInvalidAlert = true
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -1)
                }
            }
        }
        .navigationTitle("완료 입력")
        .navigationBarTitleDisplayMode(.inline)
        .alert("입력 값을 확인해주세요.", isPresented: $showInvalidAlert) {
            Button("확인", role: .cancel) {}
        }
        .alert("정말 완료 처리하시겠어요?", isPresented: $showConfirm) {
            Button("완료", role: .destructive) {
                guard let info = formVM.buildCompletionInfo() else { return }
                detailViewModel.applyCompletionInfo(info)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("제출 후에는 상태를 되돌릴 수 없습니다.")
        }
    }
    
    // 통화 포맷터
    private var currencyFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }
    
    private func numberToCurrency(_ n: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return (f.string(from: NSNumber(value: n)) ?? "0") + "원"
    }
}

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
            )
        )
    }
}
