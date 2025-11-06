import SwiftUI

struct MyReceiptListView: View {
    @StateObject var receiptListViewModel: ReceiptListViewModel
    @State private var searchText: String = ""
    @State private var selectedFilter: ReceiptStatus? = nil
    
    
    // MARK: - 담당자 필터링 + 상태 필터링 + 검색 적용된 결과
    private var filteredItems: [ReceiptItem] {
        receiptListViewModel.items.filter { item in
            // MARK: 상태 필터 (nil = 전체)
            if let status = selectedFilter, item.status != status {
                return false
            }
            
            // MARK: - 검색 필터 (차주명, 차량번호, 차종)
            if !searchText.isEmpty {
                let lower = searchText.lowercased()
                return item.ownerName.lowercased().contains(lower)
                || item.carNumber.lowercased().contains(lower)
                || item.carModel.lowercased().contains(lower)
            }
            
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if receiptListViewModel.isLoading && receiptListViewModel.items.isEmpty {
                    VStack {
                        ProgressView("불러오는 중...")
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColor.mainBlue))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            filterTabs
                            GFSearchField(
                                text: $searchText,
                                placeholder: "차량번호, 차주명 검색"
                            )
                            totalCount
                            contentSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationTitle("접수 내역")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColor.background.ignoresSafeArea())
            .task {
                await receiptListViewModel.fetchMyReceipts()
            }
        }
        .background(AppColor.background)
    }

    private var filterTabs: some View {
        let filters: [ReceiptStatus?] = [nil, .inProgress, .completed]
        return HStack(spacing: 12) {
            ForEach(filters, id: \.self) { filter in
                let title = filter?.displayName ?? "전체"
                let isSelected = selectedFilter == filter
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? AppColor.surface : AppColor.textMuted)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isSelected ? AppColor.mainBlue : AppColor.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? AppColor.mainBlue.opacity(0.35) : AppColor.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var totalCount: some View {
        HStack {
            Text("총 \(filteredItems.count)건")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColor.mainTextBlack)
            Spacer()
        }
    }

    private var contentSection: some View {
        Group {
            if receiptListViewModel.isLoading {
                ProgressView("불러오는 중...")
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColor.mainBlue))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if filteredItems.isEmpty {
                EmptyStateView(
                    title: "담당한 접수 이력이 없습니다.",
                    message: "필터 조건을 조정하거나 새로운 접수를 확인하세요.",
                    systemImage: "clock.arrow.circlepath"
                )
                .frame(maxWidth: .infinity)
                .frame(height: 240)
            } else {
                VStack(spacing: 20) {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            ReceiptDetailView(
                                receiptDetailViewModel: ReceiptDetailViewModel(item: item)
                            )
                        } label: {
                            ReceiptCard(item: item, showStatus: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - 상태
extension ReceiptStatus {
    var displayName: String {
        switch self {
        case .inProgress: return "수리중"
        case .completed:  return "완료"
        @unknown default: return "기타"
        }
    }
}

// MARK: - Preview
#Preview {
    let receiptListViewModel = ReceiptListViewModel()
    receiptListViewModel.items = [
        ReceiptItem(
            id: "CHK-1010",
            carNumber: "12가 3456",
            ownerName: "김민수",
            carModel: "소나타",
            requestContent: "엔진오일 교체 및 점검",
            date: "2025-10-13",
            phoneNumber: "010-1234-5678",
            manager: "티파니 송",
            status: .inProgress
        ),
        ReceiptItem(
            id: "CHK-1011",
            carNumber: "45너 7890",
            ownerName: "박지훈",
            carModel: "아반떼",
            requestContent: "브레이크 패드 교체",
            date: "2025-10-12",
            phoneNumber: "010-9876-5432",
            manager: "티파니 송",
            status: .inProgress
        ),
        ReceiptItem(
            id: "CHK-1012",
            carNumber: "33러 5678",
            ownerName: "최유진",
            carModel: "투싼",
            requestContent: "냉각수 점검",
            date: "2025-10-10",
            phoneNumber: "010-2222-3333",
            manager: "티파니 송",
            status: .completed,
            leadTimeDays: 4,
            completionInfos: [
                ReceiptDetailViewModel.CompletionInfo(
                    completionDate: "2025-10-14",
                    repairDescription: "엔진오일 교체",
                    cause: "주행거리 초과",
                    partName: "엔진오일",
                    partQuantity: 2,
                    partPrice: 45000,
                    totalPrice: 90000
                ),
                ReceiptDetailViewModel.CompletionInfo(
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
        
    ]
    return MyReceiptListView(receiptListViewModel: receiptListViewModel)
}
