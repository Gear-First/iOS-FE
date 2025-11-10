import SwiftUI

struct DashboardView: View {
    @ObservedObject var receiptListViewModel: ReceiptListViewModel
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @ObservedObject var tabRouter: TabRouter
    @StateObject private var userViewModel = UserViewModel()
    @State private var showMyPage = false

    private var openReceipts: Int {
        receiptListViewModel.items.filter { $0.status == .checkIn }.count
    }

    private var inProgressReceipts: Int {
        receiptListViewModel.items.filter { $0.status == .inProgress }.count
    }

    private var completedReceipts: Int {
        receiptListViewModel.items.filter { $0.status == .completed }.count
    }

    private var pendingOrders: Int {
        historyViewModel.orders.filter { $0.status.uppercased() == "PENDING" }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    overviewCard
//                    repairStatusCard
                    orderSummaryCard
                    quickLinksSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
            .background(AppColor.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMyPage = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 20))
                            Text("\(userViewModel.userInfo?.name ?? "로딩 중...")님")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(AppColor.mainTextBlack)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppColor.surface)
                        )
                      
                    }
                }
            }
            .sheet(isPresented: $showMyPage) {
                NavigationStack {
                    MyPageView()
                }
                .presentationDetents([.large])
            }
        }
        .task {
            await userViewModel.fetchUserInfo()
            if receiptListViewModel.items.isEmpty {
                await receiptListViewModel.fetchReceipts()
            }
            if historyViewModel.orders.isEmpty {
                await historyViewModel.fetchAllOrders()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GearFirst 운영 현황")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppColor.mainTextBlack)
            Text("오늘 처리해야 할 물류 · 조달 · 인력 워크로드를 빠르게 확인하세요.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textMuted)
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘의 접수 현황")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)

            HStack(spacing: 16) {
                metricPill(title: "접수 대기", value: openReceipts, accent: AppColor.mainBlue)
                metricPill(title: "수리 진행", value: inProgressReceipts, accent: AppColor.mainYellow)
                metricPill(title: "완료", value: completedReceipts, accent: AppColor.mainGreen)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("최근 접수")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textMuted)
                ForEach(receiptListViewModel.items.prefix(3)) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.ownerName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.mainTextBlack)
                            Text(item.carNumber)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColor.textMuted)
                        }
                        Spacer()
                        Text(item.status.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColor.surface)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(statusColor(for: item.status))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColor.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .gfCardStyle()
    }

    private func metricPill(title: String, value: Int, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColor.textMuted)
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppColor.mainTextBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [accent.opacity(0.12), AppColor.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.25), lineWidth: 1)
        )
    }

    private var repairStatusCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerWithCaption(title: "공정 밸런스", caption: "승인 · 입고 · 출고 진행량을 최근 6개월 스냅샷으로 비교합니다.")
            LinearGradient(
                colors: [
                    AppColor.mainBlue.opacity(0.2),
                    AppColor.mainBlue.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                WaveShape()
                    .stroke(AppColor.mainBlue.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
            )
            footerLegend(items: [
                ("대기", openReceipts),
                ("진행", inProgressReceipts),
                ("완료", completedReceipts)
            ])
        }
        .gfCardStyle()
    }

    private var orderSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerWithCaption(title: "발주 진행 현황", caption: "지점 별 발주 승인 흐름을 모니터링하세요.")
            HStack(spacing: 16) {
                metricPill(title: "대기", value: pendingOrders, accent: AppColor.mainBlue)
                metricPill(title: "진행", value: activeOrdersCount, accent: Color(hex: "#F97316"))
                metricPill(title: "취소", value: cancelledOrdersCount, accent: AppColor.mainRed)
            }
        }
        .gfCardStyle()
    }

    private var activeOrdersCount: Int {
        historyViewModel.orders.filter { $0.status.uppercased() == "IN_PROGRESS" }.count
    }

    private var cancelledOrdersCount: Int {
        historyViewModel.orders.filter { $0.status.uppercased() == "CANCELLED" }.count
    }

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("빠른 메뉴")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
            VStack(spacing: 12) {
                quickLinkRow(
                    icon: "square.and.pencil",
                    title: "새 발주 요청",
                    description: "부품을 빠르게 요청하고 진행 상황을 추적하세요."
                ) {
                    tabRouter.selectedIndex = 3
                }
                quickLinkRow(
                    icon: "doc.text.magnifyingglass",
                    title: "접수 상세 보기",
                    description: "진행 중인 접수 건을 한 눈에 살펴봅니다."
                ) {
                    tabRouter.selectedIndex = 2
                }
                quickLinkRow(
                    icon: "person.crop.circle",
                    title: "마이 페이지",
                    description: "프로필 정보를 확인하고 로그아웃할 수 있습니다."
                ) {
                    showMyPage = true
                }
            }
        }
        .gfCardStyle()
    }

    private func quickLinkRow(
        icon: String,
        title: String,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 48, height: 48)
                    .foregroundColor(AppColor.surface)
                    .background(AppColor.mainBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColor.mainTextBlack)
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textMuted)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func headerWithCaption(title: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
            Text(caption)
                .font(.system(size: 13))
                .foregroundColor(AppColor.textMuted)
        }
    }

    private func footerLegend(items: [(String, Int)]) -> some View {
        HStack(spacing: 16) {
            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.0.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColor.textMuted)
                    Text("\(item.1)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppColor.mainTextBlack)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppColor.surfaceMuted)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            Spacer()
        }
    }

    private func statusColor(for status: ReceiptStatus) -> Color {
        switch status {
        case .checkIn: return AppColor.mainBlue
        case .inProgress: return AppColor.mainYellow
        case .completed: return AppColor.mainGreen
        }
    }

    private func handleLogout() {
        // TODO: 연결된 인증 모듈과 연동 시 logout 로직 추가
        print("로그아웃 버튼 탭")
    }
}

private struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let height = rect.height
        let width = rect.width

        path.move(to: CGPoint(x: 0, y: height * 0.7))
        path.addCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.3),
            control1: CGPoint(x: width * 0.1, y: height * 0.1),
            control2: CGPoint(x: width * 0.2, y: height * 0.45)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.7, y: height * 0.6),
            control1: CGPoint(x: width * 0.45, y: height * 0.15),
            control2: CGPoint(x: width * 0.55, y: height * 0.75)
        )
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.35),
            control1: CGPoint(x: width * 0.85, y: height * 0.45),
            control2: CGPoint(x: width * 0.92, y: height * 0.2)
        )
        return path
    }
}
