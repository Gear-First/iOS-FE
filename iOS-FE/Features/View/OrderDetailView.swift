import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    let orderId: Int
    @State private var order: OrderHistoryItem?
    let onCancel: () -> Void
    let onBack: (() -> Void)?
    
    // MARK: - 초기화
    init(orderId: Int, onCancel: @escaping () -> Void, onBack: (() -> Void)? = nil) {
        self.orderId = orderId
        self._order = State(initialValue: nil)
        self.onCancel = onCancel
        self.onBack = onBack
    }
    
    private var status: OrderStatus {
        guard let order = order else { return .PENDING }
        return OrderStatusMapper.map(order.status)
    }
    
    // MARK: - View Body
    var body: some View {
        Group {
            if isLoading {
                ProgressView("불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("오류 발생")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("다시 시도") {
                        Task {
                            await loadOrderDetail()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            else if let safeOrder = order {
                orderDetailContent(order: safeOrder)
            }
            else {
                Text("데이터를 불러올 수 없습니다.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await loadOrderDetail()
        }
        .navigationTitle("발주 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onBack?()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColor.mainDarkBlue)
                }
            }
        }
    }
    
    // MARK: - 상세 내용 뷰
    @ViewBuilder
    private func orderDetailContent(order: OrderHistoryItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 헤더
                VStack(alignment: .leading, spacing: 8) {
                    Text("발주 진행 현황")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColor.mainTextBlack)
                    Text("각 단계별 상태와 처리 일정을 한 눈에 확인하세요.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textMuted)
                }

                // 진행 상황
                SectionCard(title: "진행 상황") {
                    let steps: [OrderStatus] = [.PENDING, .APPROVED, .SHIPPED, .COMPLETED]
                    let stepDates: [OrderStatus: String] = [
                        .PENDING: formatDateYYYYMMDD(order.requestDate),
                        .APPROVED: formatDateYYYYMMDD(order.processedDate),
                        .SHIPPED: formatDateYYYYMMDD(order.transferDate),
                        .COMPLETED: formatDateYYYYMMDD(order.completedDate)
                    ]
                    let special: OrderStatus? = ["CANCELLED", "REJECTED"].contains(order.status) ? status : nil
                    
                    StepProgressView(
                        steps: steps,
                        currentStep: status,
                        colorProvider: { _ in AppColor.mainBlue },
                        labelProvider: { $0.rawValue },
                        dates: stepDates,
                        specialStatus: special
                    )
                }

                // 상세 정보
                DetailInfoSection(
                    title: "발주 상세 정보",
                    statusText: status.rawValue,
                    statusColor: status.badgeColor,
                    rows: [
                        ("발주번호", order.orderNumber),
                        ("총 금액", formatCurrency(order.totalPrice)),
                        ("요청 일자", formatDate(order.requestDate)),
                        ("승인 일자", formatDate(order.processedDate)),
                        ("이관 일자", formatDate(order.transferDate)),
                        ("완료 일자", formatDate(order.completedDate))
                    ]
                )

                // 부품 내역
                // MARK: - 부품 내역 (새 디자인)
                SectionCard(title: "부품 내역") {
                    if order.items.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(AppColor.textMuted)
                            Text("등록된 부품이 없습니다.")
                                .foregroundColor(AppColor.textMuted)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.horizontal, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppColor.surfaceMuted))
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(spacing: 8) {
                                ForEach(order.items) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.partName)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColor.mainTextBlack)

                                            HStack(spacing: 10) {
                                                Text("수량 \(item.quantity)EA")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                                Text("단가 \(formatCurrency(item.price))원")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Text(formatCurrency(item.totalPrice))
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color(hex: "#1E293B"))
                                    }
                                    .padding(10)
                                    .background(AppColor.surfaceMuted)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }

                            // 총 합계
                            HStack {
                                Spacer()
                                Text("총 합계: \(formatCurrency(order.items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }))원")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColor.mainBlue)
                            }
                            .padding(.top, 6)
                        }
                    }
                }

                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(AppColor.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if let safeOrder = self.order {
                bottomActionBar(order: safeOrder)
            }
        }
    }
    
    // MARK: - API 호출
    private func loadOrderDetail() async {
        isLoading = true
        errorMessage = nil
        
        print("[OrderDetailView] 발주 상세 데이터 로드 시작 - orderId: \(orderId)")
        
        do {
            let fetchedOrder = try await PurchaseOrderAPI.fetchOrderDetail(orderId: orderId)
            await MainActor.run {
                self.order = fetchedOrder
                self.isLoading = false
                print("[OrderDetailView] 발주 상세 데이터 로드 성공")
                print("[OrderDetailView] - 발주번호: \(fetchedOrder.orderNumber)")
                print("[OrderDetailView] - 상태: \(fetchedOrder.status)")
                print("[OrderDetailView] - 총 금액: \(fetchedOrder.totalPrice)")
                print("[OrderDetailView] - 부품 개수: \(fetchedOrder.items.count)")
                print("[OrderDetailView] - 요청일: \(fetchedOrder.requestDate ?? "nil")")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("[OrderDetailView] 발주 상세 데이터 로드 실패: \(error.localizedDescription)")
                if let urlError = error as? URLError {
                    print("[OrderDetailView] URLError code: \(urlError.code.rawValue)")
                }
            }
        }
    }

    // MARK: - 하단 버튼
    @ViewBuilder
    private func bottomActionBar(order: OrderHistoryItem) -> some View {
        VStack(spacing: 16) {
            Divider().overlay(AppColor.cardBorder)
            if ["PENDING", "APPROVED"].contains(order.status) {
                BaseButton(
                    label: "요청 취소",
                    backgroundColor: AppColor.mainRed,
                    textColor: .white
                ) {
                    showCancelAlert = true
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
                .alert("요청을 취소하시겠습니까?", isPresented: $showCancelAlert) {
                    Button("확인", role: .destructive) {
                        onCancel()
                        Task {
                            await loadOrderDetail()
                        }
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("한 번 취소하면 되돌릴 수 없습니다.")
                }
            }
        }
        .background(AppColor.surface.ignoresSafeArea())
    }

    // MARK: - 포맷 함수
    private func parseDate(_ iso: String?) -> Date? {
        guard let iso else { return nil }
        
        // 1️⃣ ISO 포맷 시도
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = fmt.date(from: iso) { return d }
        
        // 2️⃣ 포맷 실패 시 커스텀 DateFormatter 시도 (소수점 5자리 대응)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS" // ← 5자리 소수 대응
        if let d = df.date(from: iso) { return d }

        // 3️⃣ fallback (소수점 없는 기본 형태)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = df.date(from: iso) { return d }

        return nil
    }


    private func formatDate(_ raw: String?) -> String {
        guard let date = parseDate(raw) else { return "-" }
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy.MM.dd HH:mm"
        return df.string(from: date)
    }

    private func formatDateYYYYMMDD(_ raw: String?) -> String {
        guard let date = parseDate(raw) else { return "-" }
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yy-MM-dd"
        return df.string(from: date)
    }

    private func formatCurrency(_ val: Double?) -> String {
        guard let val else { return "-" }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: val)) ?? "-"
    }
}
