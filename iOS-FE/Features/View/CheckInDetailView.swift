import SwiftUI

struct CheckInDetailView: View {
    @ObservedObject var checkInDetailViewModel: CheckInDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertType: AlertType? = nil
    
    enum AlertType {
        case startRepair
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - 기본 정보 섹션
                        DetailInfoSection(
                            title: "수리 상세 정보",
                            statusText: checkInDetailViewModel.item.status.rawValue,
                            statusColor: statusColor(for: checkInDetailViewModel.item.status),
                            rows: [
                                ("접수번호", checkInDetailViewModel.item.id),
                                ("차량번호", checkInDetailViewModel.item.carNumber),
                                ("차주", checkInDetailViewModel.item.ownerName),
                                ("차주번호", checkInDetailViewModel.item.phoneNumber),
                                ("차종", checkInDetailViewModel.item.carModel),
                                ("요청사항", checkInDetailViewModel.item.requestContent),
                                ("접수일자", checkInDetailViewModel.item.date),
                                ("담당자", checkInDetailViewModel.item.manager ?? "-")
                            ]
                        )
                        
                        // MARK: - 완료 정보
                        if checkInDetailViewModel.item.status == .completed {
                            DetailInfoSection(
                                title: "수리 완료 정보",
                                rows: [
                                    ("완료일자", checkInDetailViewModel.item.completionDate ?? "-"),
                                    ("수리내용", checkInDetailViewModel.item.repairDescription ?? "-"),
                                    ("원인", checkInDetailViewModel.item.cause ?? "-"),
                                    ("부품명", checkInDetailViewModel.item.partName ?? "-"),
                                    ("수량", "\(checkInDetailViewModel.item.partQuantity ?? 0)"),
                                    ("총가격", "\(checkInDetailViewModel.item.totalPrice ?? 0)원"),
                                    ("소요일", "\(checkInDetailViewModel.item.leadTimeDays ?? 0)일")
                                ]
                            )
                        }
                        Spacer().frame(height: 80) // 버튼과의 간격 확보
                    }
                    .padding()
                }
                
                // MARK: - 하단 고정 버튼
                if checkInDetailViewModel.item.status == .checkIn {
                    BaseButton(label: "수리 시작", backgroundColor: Color.blue) {
                        alertType = .startRepair
                        showAlert = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -1)
                } else if checkInDetailViewModel.item.status == .inProgress {
                    bottomBarNavigationLink(title: "수리 완료", color: .green) {
                        CheckInCompletionView(detailViewModel: checkInDetailViewModel)
                    }
                }
            }
        }
        .navigationTitle("접수 상세")
        .navigationBarTitleDisplayMode(.inline)
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
    
    // MARK: - Info Row
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
    
    // MARK: - 하단 고정 NavigationLink 버튼
    private func bottomBarNavigationLink<Destination: View>(title: String, color: Color, @ViewBuilder destination: () -> Destination) -> some View {
        VStack {
            NavigationLink(destination: destination()) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: -1)
    }
    
    // MARK: - 상태 색상
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
