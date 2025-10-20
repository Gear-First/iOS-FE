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
        NavigationView {
            VStack(spacing: 10) {
                
                // MARK: - 상태 필터 탭 (접수 제외)
                HStack(spacing: 0) {
                    let filters: [ReceiptStatus?] = [nil, .inProgress, .completed]
                    
                    ForEach(filters, id: \.self) { filter in
                        let title: String = filter?.displayName ?? "전체"
                        let isSelected = selectedFilter == filter
                        
                        Button {
                            withAnimation(.easeInOut) {
                                selectedFilter = filter
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(title)
                                    .font(.subheadline)
                                    .foregroundColor(isSelected ? AppColor.mainBlack : AppColor.mainTextGray)
                                    .frame(maxWidth: .infinity)
                                
                                Rectangle()
                                    .fill(isSelected ? AppColor.mainBlack : .clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                // MARK: - 상단 검색창
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("차량번호, 차주명 검색", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                .padding(.horizontal)
                
                // MARK: - 총 개수 표시
                HStack {
                    Spacer()
                    Text("총 \(filteredItems.count)건")
                        .font(.subheadline)
                        .foregroundColor(AppColor.mainTextGray)
                }
                .padding(.horizontal, 20)
                
                // MARK: - 리스트 영역
                if receiptListViewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("불러오는 중...")
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColor.mainBlue))
                            .font(.headline)
                        Spacer()
                    }
                } else if filteredItems.isEmpty {
                    VStack {
                        Spacer()
                        Text("담당한 접수 이력이 없습니다.")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
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
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("접수 내역")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(AppColor.bgGray))
            .task {
                await receiptListViewModel.fetchMyReceipts()
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
            manager: "송지은",
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
            manager: "송지은",
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
            manager: "송지은",
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

