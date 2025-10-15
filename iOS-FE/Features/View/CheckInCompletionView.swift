import SwiftUI

struct CheckInCompletionView: View {
    @ObservedObject var detailViewModel: CheckInDetailViewModel
    @StateObject private var formVM = CheckInCompletionViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirm = false
    @State private var showInvalidAlert = false
    
    var body: some View {
        ZStack {
            Color(AppColor.bgGray)
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: 카드 리스트
                        ForEach(formVM.items) { item in
                            RepairItemCard(form: item) {
                                if formVM.items.count > 1 {
                                    formVM.removeItem(item.id)
                                }
                            }
                        }
                        
                        // MARK: 수리 항목 추가 버튼
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
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("총 합계")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(formattedPrice(formVM.totalSum))
                            .font(.title2)
                            .bold()
                            .foregroundColor(AppColor.mainBlue)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal, 20)

                
                // MARK: 완료 제출 버튼
                BaseButton(label: "완료 제출", backgroundColor: .green) {
                    if let infoList = formVM.buildCompletionInfo() {
                        showConfirm = true
                    } else {
                        showInvalidAlert = true
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("수리 완료 입력")
        .navigationBarTitleDisplayMode(.inline)
        .alert("입력 값을 확인해주세요.", isPresented: $showInvalidAlert) {
            Button("확인", role: .cancel) {}
        }
        .alert("정말 완료 처리하시겠어요?", isPresented: $showConfirm) {
            Button("완료", role: .destructive) {
                guard let infoList = formVM.buildCompletionInfo() else { return }
                detailViewModel.applyMultipleCompletionInfo(infoList)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("제출 후에는 상태를 되돌릴 수 없습니다.")
        }
    }
    
    func formattedPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + "원"
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
