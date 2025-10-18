import SwiftUI

struct ReceiptDetailView: View {
    @ObservedObject var receiptDetailViewModel: ReceiptDetailViewModel
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

                        // MARK: - 기본 정보 섹션
                        DetailInfoSection(
                            title: "수리 상세 정보",
                            statusText: receiptDetailViewModel.item.status.rawValue,
                            statusColor: statusColor(for: receiptDetailViewModel.item.status),
                            rows: {
                                var rows: [(String, String)] = [
                                    ("접수번호", receiptDetailViewModel.item.id),
                                    ("접수일자", receiptDetailViewModel.item.date),
                                    ("차량번호", receiptDetailViewModel.item.carNumber),
                                    ("차주", receiptDetailViewModel.item.ownerName),
                                    ("차주번호", receiptDetailViewModel.item.phoneNumber),
                                    ("차종", receiptDetailViewModel.item.carModel),
                                    ("요청사항", receiptDetailViewModel.item.requestContent),
                                    ("담당자", receiptDetailViewModel.item.manager ?? "-")
                                ]
                                
                                // 완료일 있을 경우
                                if receiptDetailViewModel.item.status == .completed,
                                   let completion = receiptDetailViewModel.item.completionInfos?.first?.completionDate {
                                    rows.append(("완료일자", completion))
                                }
                                
                                // 소요일 있을 경우
                                if let days = receiptDetailViewModel.item.leadTimeDays {
                                    rows.append(("소요일", "\(days)일"))
                                }
                                
                                return rows
                            }()
                        )
                        
                        // MARK: - 완료 정보
                        if receiptDetailViewModel.item.status == .completed {
                            if let infos = receiptDetailViewModel.item.completionInfos {
                                VStack(alignment: .leading, spacing: 14) {
                                    // MARK: 제목
                                    let grouped = Dictionary(grouping: infos, by: { $0.repairDescription })
                                    HStack {
                                        Text("수리 완료 정보")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("총 \(grouped.keys.count)건")
                                            .font(.callout)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Divider().padding(.bottom, 6)
                                    
                                    ForEach(Array(grouped.keys.enumerated()), id: \.1) { index, key in
                                        if let group = grouped[key], let first = group.first {
                                            VStack(alignment: .leading, spacing: 10) {
                                                // MARK: 수리내용 + 원인
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text("\(index + 1). \(first.repairDescription)")
                                                        .font(.title3)
                                                    Text("원인: \(first.cause)")
                                                        .font(.body)
                                                }
                                                
                                                // MARK: - 부품 리스트
                                                VStack(alignment: .leading, spacing: 6) {
                                                    ForEach(group, id: \.partName) { part in
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            HStack {
                                                                Text(part.partName)
                                                                    .font(.body)
                                                                Spacer()
                                                                Text(formattedPrice(part.partPrice))
                                                                    .font(.body)
                                                                    .fontWeight(.medium)
                                                                    .foregroundColor(AppColor.mainBlue)
                                                            }
                                                            Text("수량: \(part.partQuantity)EA")
                                                                .font(.body)
                                                                .foregroundColor(.gray)
                                                        }
                                                        Divider().padding(.vertical, 4).opacity(0.15)
                                                    }
                                                }
                                                .padding(.horizontal, 2)
                                                
                                                // MARK: - 항목 합계
                                                HStack {
                                                    Spacer()
                                                    Text("항목 합계: \(formattedPrice(group.reduce(0) { $0 + $1.totalPrice }))")
                                                        .font(.callout)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                            Divider().padding(.vertical, 4)
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
                                    .padding(.top, 12)
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
                
                // MARK: - 하단 고정 버튼
                if receiptDetailViewModel.item.status == .checkIn {
                    BaseButton(label: "수리 시작", backgroundColor: Color.blue) {
                        alertType = .startRepair
                        showAlert = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -1)
                } else if receiptDetailViewModel.item.status == .inProgress {
                    bottomBarNavigationLink(title: "수리 완료", color: .green) {
                        ReceiptCompletionView(
                            detailViewModel: receiptDetailViewModel,
                            formVM: receiptDetailViewModel.completionFormVM
                        )
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
                        receiptDetailViewModel.startRepair()
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
    
    // MARK: - 수리 중 버튼
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
    private func statusColor(for status: ReceiptStatus) -> Color {
        switch status {
        case .checkIn: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        }
    }
    
    // MARK: - 총 합계
    private func totalPrice(of infos: [ReceiptDetailViewModel.CompletionInfo]) -> Double {
        infos.reduce(0) { $0 + $1.totalPrice }
    }
    
    // MARK: - 가격 스타일링
    private func formattedPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + "원"
    }
    
}

// MARK: - Preview
#Preview("접수 상태") {
    NavigationView {
        ReceiptDetailView(
            receiptDetailViewModel: ReceiptDetailViewModel(
                item: ReceiptItem(
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
        ReceiptDetailView(
            receiptDetailViewModel: ReceiptDetailViewModel(
                item: ReceiptItem(
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
        ReceiptDetailView(
            receiptDetailViewModel: ReceiptDetailViewModel(
                item: ReceiptItem(
                    id: "CHK-2025",
                    carNumber: "12가 3456",
                    ownerName: "김민수",
                    carModel: "그랜저",
                    requestContent: "정기 점검 및 교체",
                    date: "2025-10-10",
                    phoneNumber: "010-1111-2222",
                    manager: "정우성",
                    status: .completed,
                    leadTimeDays: 3,
                    completionInfos: [
                        ReceiptDetailViewModel.CompletionInfo(
                            completionDate: "2025-10-13",
                            repairDescription: "엔진오일 교체",
                            cause: "주행거리 초과",
                            partName: "엔진오일",
                            partQuantity: 2,
                            partPrice: 45000,
                            totalPrice: 90000
                        ),
                        ReceiptDetailViewModel.CompletionInfo(
                            completionDate: "2025-10-13",
                            repairDescription: "엔진오일 교체",
                            cause: "주행거리 초과",
                            partName: "오일필터",
                            partQuantity: 1,
                            partPrice: 12000,
                            totalPrice: 12000
                        ),
                        ReceiptDetailViewModel.CompletionInfo(
                            completionDate: "2025-10-13",
                            repairDescription: "엔진오일 교체",
                            cause: "주행거리 초과",
                            partName: "드레인 플러그 패킹",
                            partQuantity: 1,
                            partPrice: 3000,
                            totalPrice: 3000
                        ),
                        ReceiptDetailViewModel.CompletionInfo(
                            completionDate: "2025-10-13",
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
