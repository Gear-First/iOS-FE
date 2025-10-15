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
            Color(AppColor.bgGray)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: 기본 정보 섹션
                        DetailInfoSection(
                            title: "수리 상세 정보",
                            statusText: checkInDetailViewModel.item.status.rawValue,
                            statusColor: statusColor(for: checkInDetailViewModel.item.status),
                            rows: {
                                var rows: [(String, String)] = [
                                    ("접수번호", checkInDetailViewModel.item.id),
                                    ("접수일자", checkInDetailViewModel.item.date),
                                    ("차량번호", checkInDetailViewModel.item.carNumber),
                                    ("차주", checkInDetailViewModel.item.ownerName),
                                    ("차주번호", checkInDetailViewModel.item.phoneNumber),
                                    ("차종", checkInDetailViewModel.item.carModel),
                                    ("요청사항", checkInDetailViewModel.item.requestContent),
                                    ("담당자", checkInDetailViewModel.item.manager ?? "-")
                                ]
                                
                                // 완료일 있을 경우
                                if checkInDetailViewModel.item.status == .completed,
                                   let completion = checkInDetailViewModel.item.completionInfos?.first?.completionDate {
                                    rows.append(("완료일자", completion))
                                }
                                
                                // 소요일 있을 경우
                                if let days = checkInDetailViewModel.item.leadTimeDays {
                                    rows.append(("소요일", "\(days)일"))
                                }
                                
                                return rows
                            }()
                        )
                        
                        
                        // MARK: 완료 정보
                        if checkInDetailViewModel.item.status == .completed {
                            if let infos = checkInDetailViewModel.item.completionInfos {
                                VStack(alignment: .leading, spacing: 14) {
                                    // MARK: - 제목
                                    HStack {
                                        Text("수리 완료 정보")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("총 \(infos.count)건")
                                            .font(.callout)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Divider().padding(.bottom, 6)
                                    
                                    // MARK: 리스트
                                    VStack(alignment: .leading, spacing: 18) {
                                        ForEach(infos.indices, id: \.self) { index in
                                            let info = infos[index]
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Text("\(index + 1). \(info.repairDescription)")
                                                        .font(.system(size: 18))
                                                        .fontWeight(.bold)
                                                    Spacer()
                                                    Text(formattedPrice(info.totalPrice))
                                                        .font(.body)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.green)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("원인: \(info.cause)")
                                                        .font(.body)
                                                        .foregroundColor(.black)
                                                    Text("부품: \(info.partName) (\(info.partQuantity)개)")
                                                        .font(.callout)
                                                        .foregroundColor(.primary)
                                                }
                                            }
                                            .padding(.vertical, 6)
                                            
                                            if index < infos.count - 1 {
                                                Divider().opacity(0.25)
                                            }
                                        }
                                    }
                                    
                                    // MARK: - 총 합계
                                    HStack {
                                        Spacer()
                                        Text("총 합계: \(formattedPrice(totalPrice(of: infos)))")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppColor.mainBlue)
                                    }
                                    .padding(.top, 10)
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                                )
                                .padding(.bottom, 10)
                            }
                        }
                        
                        
                        Spacer().frame(height: 80) // 버튼과의 간격 확보
                    }
                    .padding()
                }
                
                // MARK: 하단 고정 버튼
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
    
    // MARK: Info Row
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
    
    // MARK: 하단 고정 NavigationLink 버튼
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
    
    // MARK: 상태 색상
    private func statusColor(for status: CheckInStatus) -> Color {
        switch status {
        case .checkIn: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        }
    }
    
    private func totalPrice(of infos: [CheckInDetailViewModel.CompletionInfo]) -> Double {
        infos.reduce(0) { $0 + $1.totalPrice }
    }
    
    private func formattedPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + "원"
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
                    status: .completed,
                    leadTimeDays: 4,
                    completionInfos: [
                        CheckInDetailViewModel.CompletionInfo(
                            completionDate: "2025-10-14",
                            repairDescription: "엔진오일 교체",
                            cause: "주행거리 초과",
                            partName: "엔진오일",
                            partQuantity: 2,
                            partPrice: 45000,
                            totalPrice: 90000
                        ),
                        CheckInDetailViewModel.CompletionInfo(
                            completionDate: "2025-10-14",
                            repairDescription: "브레이크 패드 교체",
                            cause: "마모 심함",
                            partName: "브레이크 패드",
                            partQuantity: 1,
                            partPrice: 68000,
                            totalPrice: 68000
                        )
                    ]
                )
            )
        )
    }
}
