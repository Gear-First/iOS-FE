import SwiftUI

struct MyCheckInListView: View {
    @ObservedObject var checkInListViewModel: CheckInListViewModel
    @State private var searchText: String = ""
    @State private var selectedFilter: CheckInStatus? = nil
    
    // 실제 로그인된 매니저 이름
    private let currentManagerName = "송지은"
    
    // 담당자 필터링 + 상태 필터링 + 검색 적용된 결과
    private var filteredItems: [CheckInItem] {
        checkInListViewModel.items.filter { item in
            // 담당자가 현재 로그인 사용자
            guard item.manager == currentManagerName else { return false }
            
            // 상태 필터 (nil = 전체)
            if let status = selectedFilter, item.status != status {
                return false
            }
            
            // 검색 필터 (차주명, 차량번호, 차종)
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
                
                // 상태 필터 탭
                Picker("상태 필터", selection: $selectedFilter) {
                    Text("전체").tag(CheckInStatus?.none)
                    Text("수리중").tag(CheckInStatus?.some(.inProgress))
                    Text("완료").tag(CheckInStatus?.some(.completed))
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 6)
                
                // 상단 검색창
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
                
                // 리스트 영역
                if filteredItems.isEmpty {
                    VStack {
                        Spacer()
                        Text("담당한 접수 이력이 없습니다.")
                            .foregroundColor(.gray)
                            .font(.body)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 500)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                NavigationLink {
                                    CheckInDetailView(
                                        checkInDetailViewModel: CheckInDetailViewModel(item: item)
                                    )
                                } label: {
                                    CheckInCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("내 접수 내역")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(AppColor.bgGray))
        }
    }
}

#Preview {
    let checkInListViewModel = CheckInListViewModel()
    checkInListViewModel.items = [
        CheckInItem(id: "CHK-1010", carNumber: "12가 3456", ownerName: "김민수", carModel: "소나타", requestContent: "엔진오일 교체 및 점검", date: "2025-10-13", phoneNumber: "010-1234-5678", manager: "송지은", status: .inProgress),
        CheckInItem(id: "CHK-1011", carNumber: "45너 7890", ownerName: "박지훈", carModel: "아반떼", requestContent: "브레이크 패드 교체", date: "2025-10-12", phoneNumber: "010-9876-5432", manager: "송지은", status: .inProgress),
        CheckInItem(id: "CHK-1012", carNumber: "33러 5678", ownerName: "최유진", carModel: "투싼", requestContent: "냉각수 점검", date: "2025-10-10", phoneNumber: "010-2222-3333", manager: "송지은", status: .completed)
    ]
    return MyCheckInListView(checkInListViewModel: checkInListViewModel)
}
