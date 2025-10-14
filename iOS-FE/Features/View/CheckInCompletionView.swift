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
            // 전체 배경
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    Spacer().frame(height: 8)
                    
                    // 수리내용
                    TextField("수리내용", text: $formVM.repairDescription)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .cornerRadius(8)
                    
                    // 원인
                    TextField("원인", text: $formVM.cause)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .cornerRadius(8)
                    
                    // 완료일
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
                    
                    // 부품명
                    TextField("부품명", text: $formVM.partName, onEditingChanged: { _ in
                        formVM.autofillPriceIfMatches()
                    })
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .cornerRadius(8)
                    
                    // 수량 + 가격
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
                    
                    // 총가격
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
                    
                    Button {
                        if let info = formVM.buildCompletionInfo() {
                            showConfirm = true
                        } else {
                            showInvalidAlert = true
                        }
                    } label: {
                        Text("완료 제출")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .navigationTitle("완료 입력")
                .navigationBarTitleDisplayMode(.inline)
                .alert("입력 값을 확인해주세요.", isPresented: $showInvalidAlert) {
                    Button("확인", role: .cancel) {}
                }
                .alert("정말 완료 처리하시겠어요?", isPresented: $showConfirm) {
                    Button("완료", role: .destructive) {
                        guard let info = formVM.buildCompletionInfo() else { return }
                        detailViewModel.applyCompletionInfo(info)
                        // 완료 후 이전 화면(상세)로 돌아감
                        dismiss()
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("제출 후에는 상태를 되돌릴 수 없습니다.")
                }
            }
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
