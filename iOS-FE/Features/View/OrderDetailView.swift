import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert = false
    
    @Binding var order: OrderHistoryItem
    let onCancel: () -> Void
    let onBack: (() -> Void)?
    
    
    init(order: Binding<OrderHistoryItem>, onCancel: @escaping () -> Void, onBack: (() -> Void)? = nil) {
        self._order = order
        self.onCancel = onCancel
        self.onBack = onBack
    }
    
    private var status: OrderStatus { OrderStatusMapper.map(order.status) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("발주 진행 현황")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColor.mainTextBlack)
                    Text("각 단계별 상태와 처리 일정을 한 눈에 확인하세요.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textMuted)
                }
                
                SectionCard(title: "진행 상황") {
                    let steps: [OrderStatus] = [.PENDING, .APPROVED, .SHIPPED, .COMPLETED]
                    let stepDates: [OrderStatus: String] = [
                        .PENDING: formatDateYYYYMMDD(order.requestDate),
                        .APPROVED: formatDateYYYYMMDD(order.approvedDate) ?? "-",
                        .SHIPPED: formatDateYYYYMMDD(order.transferDate) ?? "-",
                        .COMPLETED: formatDateYYYYMMDD(order.completedDate) ?? "-"
                    ]
                    let special: OrderStatus? = ["CANCELLED","REJECTED"].contains(order.status) ? status : nil
                    
                    StepProgressView(
                        steps: steps,
                        currentStep: status,
                        colorProvider: { _ in AppColor.mainBlue },
                        labelProvider: { $0.rawValue },
                        dates: stepDates,
                        specialStatus: special
                    )
                }
                
                DetailInfoSection(
                    title: "발주 상세 정보",
                    statusText: status.rawValue,
                    statusColor: status.badgeColor,
                    rows: [
                        ("발주번호", order.orderNumber),
                        ("총 금액", formatCurrency(order.totalPrice)),
                        ("요청 일자", formatDate(order.requestDate)),
                        ("승인 일자", formatDate(order.approvedDate) ?? "-"),
                        ("이관 일자", formatDate(order.transferDate) ?? "-"),
                        ("완료 일자", formatDate(order.completedDate) ?? "-"),
                    ]
                )

                // 부품 내역을 카드형 리스트로 분리 표시
                SectionCard(title: "부품 내역") {
                    if order.items.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(AppColor.textMuted)
                            Text("등록된 부품이 없습니다.")
                                .foregroundColor(AppColor.textMuted)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .padding(.horizontal, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppColor.surfaceMuted))
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(order.items) { it in
                                HStack(alignment: .center, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(it.partName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(AppColor.mainTextBlack)
                                        if !(it.partCode.isEmpty) {
                                            Text(it.partCode)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(AppColor.textMuted)
                                        }
                                    }
                                    Spacer()
                                    HStack(spacing: 8) {
                                        Text("\(it.quantity)EA")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(AppColor.mainBlue)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(AppColor.mainBlue.opacity(0.1))
                                            .clipShape(Capsule())
                                        Text(formatCurrency(it.price * Double(it.quantity)))
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(AppColor.mainTextBlack)
                                    }
                                }
                                .padding(12)
                                .background(AppColor.surfaceMuted)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(AppColor.background.ignoresSafeArea())
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
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
    }
    
    
    // MARK: 날짜 포맷 통합 버전
    private func parseDate(_ isoDate: String?) -> Date? {
        guard let isoDate = isoDate else { return nil }
        
        // 1️⃣ ISO8601 (Z 포함 / UTC)
        let isoParser = ISO8601DateFormatter()
        isoParser.formatOptions = [.withInternetDateTime]
        if let date = isoParser.date(from: isoDate) { return date }
        
        // 2️⃣ ISO8601 (밀리초 .SSS)
        let msParser = DateFormatter()
        msParser.locale = Locale(identifier: "en_US_POSIX")
        msParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = msParser.date(from: isoDate) { return date }
        
        // 3️⃣ fallback (Z + .SSS)
        let zMsParser = DateFormatter()
        zMsParser.locale = Locale(identifier: "en_US_POSIX")
        zMsParser.timeZone = TimeZone(secondsFromGMT: 0)
        zMsParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = zMsParser.date(from: isoDate) { return date }
        
        print("날짜 파싱 실패: \(isoDate)")
        return nil
    }
    
    private func formatDate(_ isoDate: String?) -> String {
        guard let date = parseDate(isoDate) else { return "-" }
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return displayFormatter.string(from: date)
    }
    
    func formatDateYYYYMMDD(_ isoDate: String?) -> String {
        guard let date = parseDate(isoDate) else { return "-" }
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.dateFormat = "yy-MM-dd"
        return displayFormatter.string(from: date)
    }
        
    private func formatCurrency(_ value: Double?) -> String {
        guard let value else { return "-" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "-"
    }
}

// MARK: - OrderStatusMapper
struct OrderStatusMapper {
    static func map(_ status: String) -> OrderStatus {
        switch status.uppercased() {
        case "PENDING": return .PENDING
        case "APPROVED": return .APPROVED
        case "SHIPPED": return .SHIPPED
        case "COMPLETED": return .COMPLETED
        case "CANCELLED": return .CANCELLED
        case "REJECTED": return .REJECTED
        default: return .PENDING
        }
    }
    
    static func color(for status: String) -> Color { map(status).badgeColor }
}

private extension OrderDetailView {
    var bottomActionBar: some View {
        VStack(spacing: 16) {
            Divider().overlay(AppColor.cardBorder)
            if ["PENDING","APPROVED"].contains(order.status) {
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
                    Button("확인", role: .destructive) { onCancel() }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("한 번 취소하면 되돌릴 수 없습니다.")
                }
            }
        }
        .background(AppColor.surface.ignoresSafeArea())
    }
}
