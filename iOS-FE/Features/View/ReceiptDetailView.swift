import SwiftUI

struct ReceiptDetailView: View {
    @ObservedObject var receiptDetailViewModel: ReceiptDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertType: AlertType? = nil
    @State private var goToOrder = false
    private let isPreviewMode: Bool
    
    // 새로 추가
    private var hasOrder: Bool { !orderedItems.isEmpty }

    @State private var orderedItems: [OrderItem] = []
    @State private var createdOrder: OrderHistoryItem?
    @State private var showOrderDetail = false
    
    
    //preview
    init(
           receiptDetailViewModel: ReceiptDetailViewModel,
           previewOrderedItems: [OrderItem]? = nil,
           previewHasOrder: Bool = false,
           isPreviewMode: Bool = false
       ) {
           self.receiptDetailViewModel = receiptDetailViewModel
           _orderedItems = State(initialValue: previewOrderedItems ?? [])
           self.isPreviewMode = isPreviewMode
       }
    
    enum AlertType {
        case startRepair
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    DetailInfoSection(
                        title: "수리 상세 정보",
                        statusText: receiptDetailViewModel.item.status.rawValue,
                        statusColor: statusColor(for: receiptDetailViewModel.item.status),
                        rows: detailRows()
                    )
                    
                    switch receiptDetailViewModel.item.status {
                    case .inProgress:
                        if hasOrder {
                            OrderInfoSection(items: orderedItems)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("발주가 필요합니다")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColor.mainTextBlack)
                                Text("수리 진행을 위해 필요한 부품을 바로 요청하세요.")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColor.textMuted)
                                
                                Button {
                                    goToOrder = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("발주 요청 바로가기")
                                            .font(.system(size: 15, weight: .semibold))
                                        Spacer()
                                    }
                                    .padding(.vertical, 14)
                                    .background(AppColor.mainBlue)
                                    .foregroundColor(AppColor.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                            .gfCardStyle()
                        }
                    case .completed:
                        CombinedCompletionSummarySectionCompact(
                            descriptionText: receiptDetailViewModel.item.completionInfos?.first?.repairDescription ?? "수리 내용이 등록되지 않았습니다.",
                            causeText: receiptDetailViewModel.item.completionInfos?.first?.cause ?? "원인 정보 없음",
                            orderedLines: orderedItems.map {
                                CombinedCompletionSummarySectionCompact.Line(
                                    name: $0.partName,
                                    quantity: $0.quantity,
                                    unitPrice: $0.price
                                )
                            },
                            extraUsedLines: (receiptDetailViewModel.item.completionInfos ?? []).map {
                                CombinedCompletionSummarySectionCompact.Line(
                                    name: $0.partName,
                                    quantity: $0.partQuantity,
                                    unitPrice: $0.partPrice
                                )
                            }
                        )
                    case .checkIn:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(AppColor.background.ignoresSafeArea())
            
            VStack {
                NavigationLink(
                    destination: OrderRequestView(
                        historyViewModel: OrderHistoryViewModel(),
                        formVM: receiptDetailViewModel.completionFormVM,
                        initialVehicle: ReceiptVehicle(
                            carNum: receiptDetailViewModel.item.carNumber,
                            carType: receiptDetailViewModel.item.carModel
                        ),
                        receiptNum: receiptDetailViewModel.item.id,
                        isFromReceipt: true  // 내접수에서 발주하는 경우
                    ) { order in
                        // 내접수에서 발주한 경우에는 발주 상세보기로 가지 않음
                        // handleOrderCreated는 호출하지 않음
                    },
                    isActive: $goToOrder
                ) {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(
                    destination: createdOrderDetailView(),
                    isActive: $showOrderDetail
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationTitle("접수 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomActionBar
        }
        .background(AppColor.background.ignoresSafeArea())
        .task {
            guard !isPreviewMode else { return }
            
            await receiptDetailViewModel.fetchReceiptDetail(id: receiptDetailViewModel.item.id)
            await refreshOrderedItems()
        }
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
        case .checkIn: return AppColor.mainBlue
        case .inProgress: return AppColor.mainYellow
        case .completed: return AppColor.mainGreen
        }
    }
    
    private func handleOrderCreated(_ order: OrderHistoryItem) {
        createdOrder = order
        showOrderDetail = true
        
        guard !isPreviewMode else { return }
        
        Task {
            await refreshOrderedItems()
        }
    }
    
    @ViewBuilder
    private func createdOrderDetailView() -> some View {
        if let order = createdOrder {
            OrderDetailView(
                orderId: order.orderId,
                onCancel: { },
                onBack: {
                    createdOrder = nil
                    showOrderDetail = false
                }
            )
        } else {
            EmptyView()
        }
    }
    
    @MainActor
    private func refreshOrderedItems() async {
        let orderData = await receiptDetailViewModel.fetchCompleteParts(
            receiptNum: receiptDetailViewModel.item.id,
            vehicleNumber: receiptDetailViewModel.item.carNumber
        ) ?? []
        orderedItems = orderData
    }
    
}

private extension ReceiptDetailView {
    func detailRows() -> [(String, String)] {
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
        
        if receiptDetailViewModel.item.status == .completed,
           let completion = receiptDetailViewModel.item.completionInfos?.first?.completionDate {
            rows.append(("완료일자", completion))
            if let days = receiptDetailViewModel.item.leadTimeDays {
                rows.append(("소요일", "\(days)일"))
            }
        }
        return rows
    }
    
    var bottomActionBar: some View {
        VStack(spacing: 16) {
            Divider().overlay(AppColor.cardBorder)
            Group {
                switch receiptDetailViewModel.item.status {
                case .checkIn:
                    BaseButton(label: "수리 시작") {
                        alertType = .startRepair
                        showAlert = true
                    }
                case .inProgress:
                    NavigationLink {
                        ReceiptCompletionView(
                            detailViewModel: receiptDetailViewModel,
                            formVM: receiptDetailViewModel.completionFormVM
                        )
                    } label: {
                        Text("수리 완료")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppColor.surface)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(AppColor.mainGreen)
                            )
                            .shadow(color: AppColor.mainGreen.opacity(0.35), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                case .completed:
                    EmptyView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .background(AppColor.surface.ignoresSafeArea())
    }
}

/// 완료된 수리 정보를 모아 보여주는 섹션 뷰

struct CompletionInfoSection: View {
    let infos: [ReceiptDetailViewModel.CompletionInfo]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            let grouped = Dictionary(grouping: infos, by: { $0.repairDescription })
            HStack {
                Text("수리 완료 정보")
                    .font(.title3).fontWeight(.semibold)
                Spacer()
                Text("총 \(grouped.keys.count)건")
                    .font(.callout).foregroundColor(.gray)
            }
            Divider()
                .padding(.bottom, 6)
            ForEach(Array(grouped.keys.enumerated()), id: \.1) {
                index, key in if let group = grouped[key] {
                    CompletionGroupView(index: index, group: group) } }
            HStack {
                Spacer()
                Text("총 합계: \(formattedPrice(totalPrice(of: infos)))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.mainBlue)
            }.padding(.top, 12) }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 18)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2))
        .padding(.bottom, 10) }
    
    private func totalPrice(of infos: [ReceiptDetailViewModel.CompletionInfo]) -> Double {
        infos.reduce(0) {
            $0 + $1.totalPrice
        }
    }
    
    private func formattedPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + "원" }
}

struct SingleRepairCompletionSection: View { struct PartLine: Identifiable { let id = UUID()
    let name: String
    let quantity: Int
    let unitPrice: Double
    var lineTotal: Double { Double(quantity) * unitPrice } }
    let descriptionText: String
    let causeText: String
    let parts: [PartLine]
    
    var body: some View { VStack(alignment: .leading, spacing: 14) {
        HStack { Text("수리 상세 정보")
                .font(.title3).fontWeight(.semibold)
            Spacer()
            Text("부품 \(parts.count)종")
            .font(.callout).foregroundColor(.gray) }
        Divider()
            .padding(.bottom, 6)
        // 수리내용/원인: 맨 위에 한 번만
        VStack(alignment: .leading, spacing: 8) {
            Text(descriptionText)
                .font(.headline)
            Text("원인: \(causeText)")
            .font(.subheadline)
            .foregroundColor(.secondary) }
        
        // 부품 라인
        VStack(alignment: .leading, spacing: 10) {
            ForEach(parts) {p in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(p.name).font(.body)
                        Spacer()
                        
                        Text(formatPrice(p.unitPrice * Double(p.quantity)))
                            .font(.body)
                            .fontWeight(.medium)
                        .foregroundColor(AppColor.mainBlue) }
                    Text("수량: \(p.quantity)EA")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                Divider()
                    .opacity(0.15)
            }
        }
        .padding(.top, 6) // 총 합계
        
        HStack {
            Spacer()
            Text("총 합계: \(formatPrice(parts.reduce(0) { $0 + $1.lineTotal }))")
                .font(.title3)
                .fontWeight(.bold)
            .foregroundColor(AppColor.mainBlue) }
        .padding(.top, 8) }
    .padding(20)
    .background( RoundedRectangle(cornerRadius: 18)
        .fill(Color.white)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2) ) } }

private func formatPrice(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    return (f.string(from: NSNumber(value: value)) ?? "0") + "원" }
/// 하나의 수리 내역 그룹(수리 내용 + 원인 + 부품 리스트 + 항목 합계)을 표시하는 뷰

struct CompletionGroupView: View {
    let index: Int
    let group: [ReceiptDetailViewModel.CompletionInfo]
    var body: some View {
        if let first = group.first {
            VStack(alignment: .leading, spacing: 10) {
        // 수리 내용 + 원인
        VStack(alignment: .leading, spacing: 10) {
            Text("\(index + 1). \(first.repairDescription)")
            .font(.title3)
            Text("원인: \(first.cause)") .font(.body) }
        // 부품 리스트
        VStack(alignment: .leading, spacing: 6) {
            ForEach(group, id: \.partName) {
                part in VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(part.partName) .font(.body)
                Spacer()
                Text(formatPrice(part.partPrice)) .font(.body) .fontWeight(.medium)
                .foregroundColor(AppColor.mainBlue) }
                    Text("수량: \(part.partQuantity)EA") .font(.body) .foregroundColor(.gray) }
                Divider()
                .padding(.vertical, 4).opacity(0.15) } }
        .padding(.horizontal, 2)
        // 항목 합계
        HStack {
            Spacer()
            Text("항목 합계: \(formatPrice(group.reduce(0) {$0 + $1.totalPrice }))")
            .font(.callout)
            .fontWeight(.semibold) .foregroundColor(.green) } }
        Divider().padding(.vertical, 4) } } }

struct CombinedCompletionSummarySectionCompact: View {
    struct Line: Identifiable {
        let id = UUID()
        let name: String
        let quantity: Int
        let unitPrice: Double
        var lineTotal: Double { Double(quantity) * unitPrice }
    }

    let descriptionText: String // 수리내용
    let causeText: String // 원인
    let orderedLines: [Line] // 발주된 부품
    let extraUsedLines: [Line] // Completion에서 추가 사용 부품
    
    private var orderedSubtotal: Double { orderedLines.reduce(0) { $0 + $1.lineTotal } }
    private var extraSubtotal: Double { extraUsedLines.reduce(0) { $0 + $1.lineTotal } }
    private var grandTotal: Double { orderedSubtotal + extraSubtotal }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 🧾 헤더
            Text("수리 완료 상세")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)

            // 수리 내용 / 원인
            VStack(alignment: .leading, spacing: 6) {
                Text(descriptionText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                Text("원인: \(causeText)")
                    .font(.system(size: 13))
                    .foregroundColor(AppColor.textMuted)
            }

            // 발주된 부품
            if !orderedLines.isEmpty {
                partSection(
                    title: "발주된 부품",
                    lines: orderedLines,
                    footerTotal: orderedSubtotal,
                    color: .gray
                )
            }

            // 추가 사용 부품
            if !extraUsedLines.isEmpty {
                partSection(
                    title: "추가 사용 부품",
                    lines: extraUsedLines,
                    footerTotal: extraSubtotal,
                    color: .gray
                )
            }

            // 총 합계
            HStack {
                Text("총 합계")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Text(formatPrice(grandTotal))
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(AppColor.mainBlue)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }

    // MARK: - 부품 섹션
    @ViewBuilder
    private func partSection(
        title: String,
        lines: [Line],
        footerTotal: Double,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                Spacer()
                Text("소계 \(formatPrice(footerTotal))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
            }

            VStack(spacing: 8) {
                ForEach(lines) { line in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(line.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColor.mainTextBlack)
                            HStack(spacing: 10) {
                                Text("수량 \(line.quantity)EA")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("단가 \(formatPrice(line.unitPrice))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text(formatPrice(line.lineTotal))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#1E293B"))
                    }
                    .padding(10)
                    .background(AppColor.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private func formatPrice(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return (f.string(from: NSNumber(value: value)) ?? "0") + "원"
    }
}


// MARK: - 프리뷰 예시 (상속 제거 버전)
#Preview("접수 상세 (수리중)") {
    let mockItem = ReceiptItem(
        id: "CHK-2025-01",
        carNumber: "12가 3456",
        ownerName: "김민수",
        carModel: "쏘나타",
        requestContent: "엔진오일 교체 및 점검",
        date: "2025-11-08",
        phoneNumber: "010-1234-5678",
        manager: "티파니 송",
        status: .inProgress,
        leadTimeDays: 2
    )
    
    let viewModel = ReceiptDetailViewModel(item: mockItem)
    
    return NavigationStack {
        ReceiptDetailView(
            receiptDetailViewModel: viewModel,
            previewOrderedItems: [
                OrderItem(partCode: "ENG01", partName: "엔진오일", quantity: 2, price: 45000),
                OrderItem(partCode: "FLT01", partName: "오일필터", quantity: 1, price: 12000)
            ],
            isPreviewMode: true
        )
    }
}

#Preview("접수 상세 (완료)") {
    let mockItem = ReceiptItem(
        id: "CHK-2025-02",
        carNumber: "45나 6789",
        ownerName: "박지훈",
        carModel: "아반떼",
        requestContent: "브레이크 패드 교체",
        date: "2025-11-06",
        phoneNumber: "010-2345-6789",
        manager: "티파니 송",
        status: .completed,
        leadTimeDays: 3,
        completionInfos: [
            ReceiptDetailViewModel.CompletionInfo(
                completionDate: "2025-11-08",
                repairDescription: "브레이크 패드 교체",
                cause: "마모 심함",
                partName: "브레이크 패드",
                partQuantity: 1,
                partPrice: 68000,
                totalPrice: 68000
            )
        ]
    )
    
    let viewModel = ReceiptDetailViewModel(item: mockItem)
    
    return NavigationStack {
        ReceiptDetailView(
            receiptDetailViewModel: viewModel,
            previewOrderedItems: [
                OrderItem(partCode: "BRK01", partName: "브레이크 패드", quantity: 1, price: 68000),
                OrderItem(partCode: "FIL01", partName: "차량 필터", quantity: 1, price: 68000)
            ],
            isPreviewMode: true
        )
    }
}

