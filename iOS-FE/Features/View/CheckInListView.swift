import SwiftUI

struct CheckInListView: View {
    @ObservedObject var checkInListViewModel: CheckInListViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // 전체 배경
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                if checkInListViewModel.items.isEmpty {
                    VStack {
                        Spacer()
                        Text("접수 이력이 없습니다.")
                            .foregroundColor(.gray)
                            .font(.body)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 600)
                } else {
                    // 스크롤 콘텐츠
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(checkInListViewModel.items) { item in
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
            .navigationTitle("접수 목록")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let viewModel = CheckInListViewModel()
    
    viewModel.items = [
        CheckInItem(
            id: "CHK-1010",
            carNumber: "12가 3456",
            ownerName: "김민수",
            carModel: "소나타",
            requestContent: "엔진오일 교체 및 점검",
            date: "2025-10-11",
            phoneNumber: "010-1234-5678",
            manager: nil,
            status: .checkIn
        ),
        CheckInItem(
            id: "CHK-1011",
            carNumber: "45너 7890",
            ownerName: "박지훈",
            carModel: "아반떼",
            requestContent: "브레이크 패드 마모",
            date: "2025-10-12",
            phoneNumber: "010-9876-5432",
            manager: "이도현",
            status: .inProgress
        ),
        CheckInItem(
            id: "CHK-1012",
            carNumber: "33러 5678",
            ownerName: "최유진",
            carModel: "투싼",
            requestContent: "냉각수 점검 및 보충",
            date: "2025-10-13",
            phoneNumber: "010-2222-3333",
            manager: "김성민",
            status: .completed )
    ]
    return CheckInListView(checkInListViewModel: viewModel)
}
