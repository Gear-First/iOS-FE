import SwiftUI

struct CheckInDetailView: View {
    @ObservedObject var checkInDetailViewModel: CheckInDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertType: AlertType? = nil  // 어떤 Alert인지 구분용
    
    enum AlertType {
        case startRepair
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 상태 배지
                VStack(spacing: 10) {
                    Text(checkInDetailViewModel.item.status.rawValue)
                        .font(.title3.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(statusColor(for: checkInDetailViewModel.item.status))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                
//                    Text("접수번호: \(checkInDetailViewModel.item.id)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
                }
                .padding(20)
                
                // 기본 정보 섹션
                VStack(alignment: .leading, spacing: 12) {
                    Text("수리 상세 정보")
                        .font(.headline)
                        .padding(.bottom, 4)
                    infoRow(title: "접수번호", value: checkInDetailViewModel.item.id)
                    infoRow(title: "차량번호", value: checkInDetailViewModel.item.carNumber)
                    infoRow(title: "차주", value: checkInDetailViewModel.item.ownerName)
                    infoRow(title: "차주번호", value: checkInDetailViewModel.item.phoneNumber)
                    infoRow(title: "차종", value: checkInDetailViewModel.item.carModel)
                    infoRow(title: "요청사항", value: checkInDetailViewModel.item.requestContent)
                    infoRow(title: "접수일자", value: checkInDetailViewModel.item.date)
                    infoRow(title: "담당자", value: checkInDetailViewModel.item.manager ?? "-")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // 상태 변경 버튼
                if checkInDetailViewModel.item.status == .checkIn {
                    actionButton(title: "수리 시작", color: .blue) {
                        alertType = .startRepair
                        showAlert = true
                    }
                } else if checkInDetailViewModel.item.status == .inProgress {
                    NavigationLink {
                        CheckInCompletionView(detailViewModel: checkInDetailViewModel)
                    } label: {
                        Text("수리 완료")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else if checkInDetailViewModel.item.status == .completed {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("수리 완료 정보")
                            .font(.headline)
                            .padding(.bottom, 4)
                        infoRow(title: "완료일자", value: checkInDetailViewModel.item.completionDate ?? "-")
                        infoRow(title: "수리내용", value: checkInDetailViewModel.item.repairDescription ?? "-")
                        infoRow(title: "원인", value: checkInDetailViewModel.item.cause ?? "-")
                        infoRow(title: "부품명", value: checkInDetailViewModel.item.partName ?? "-")
                        infoRow(title: "수량", value: "\(checkInDetailViewModel.item.partQuantity ?? 0)")
                        infoRow(title: "총가격", value: "\(checkInDetailViewModel.item.totalPrice ?? 0)원")
                        infoRow(title: "소요일", value: "\(checkInDetailViewModel.item.leadTimeDays ?? 0)일")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("접수 상세")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .startRepair:
                return Alert(
                    title: Text("수리를 시작하시겠습니까?"),
                    message: Text("담당자 정보가 등록됩니다."),
                    primaryButton: .destructive(Text("확인")) {
                        checkInDetailViewModel.updateStatus(to: .inProgress, manager: "송지은")
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            case .none:
                return Alert(title: Text("오류"), message: Text("잘못된 동작입니다."), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    // infoRow 뷰
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
        .font(.subheadline)
    }
    
    // 버튼
    private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
    
    // 상태 색상
    private func statusColor(for status: CheckInStatus) -> Color {
        switch status {
        case .checkIn: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        }
    }
}


#Preview("접수 상태") {
    NavigationView {
        CheckInDetailView(
            checkInDetailViewModel: CheckInDetailViewModel(
                item: CheckInItem(
                    id: "CHK-1010",
                    carNumber: "12가 3456",
                    ownerName: "김민수",
                    carModel: "소나타",
                    requestContent: "엔진오일 교체 및 점검",
                    date: "2025-10-13",
                    phoneNumber: "010-1234-5678",
                    manager: nil,
                    status: .checkIn
                )
            )
        )
    }
}

#Preview("수리중 상태") {
    NavigationView {
        CheckInDetailView(
            checkInDetailViewModel: CheckInDetailViewModel(
                item: CheckInItem(
                    id: "CHK-1011",
                    carNumber: "45너 7890",
                    ownerName: "박지훈",
                    carModel: "아반떼",
                    requestContent: "브레이크 패드 교체",
                    date: "2025-10-12",
                    phoneNumber: "010-9876-5432",
                    manager: "이도현",
                    status: .inProgress
                )
            )
        )
    }
}

#Preview("완료 상태") {
    NavigationView {
        CheckInDetailView(
            checkInDetailViewModel: CheckInDetailViewModel(
                item: CheckInItem(
                    id: "CHK-1012",
                    carNumber: "33러 5678",
                    ownerName: "최유진",
                    carModel: "투싼",
                    requestContent: "냉각수 점검 및 보충",
                    date: "2025-10-10",
                    phoneNumber: "010-2222-3333",
                    manager: "김성민",
                    status: .completed
                )
            )
        )
    }
}
