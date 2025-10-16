import SwiftUI



struct CheckInListView: View {
    @ObservedObject var checkInListViewModel: CheckInListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // MARK: 전체 배경
                Color(AppColor.bgGray)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("총 \(checkInListViewModel.items.count)건")
                            .font(.subheadline)
                            .foregroundColor(AppColor.mainTextGray)
                            .padding(.trailing, 10)
                    }
                    .padding(.horizontal)
                    
                    if checkInListViewModel.items.isEmpty {
                        VStack(spacing: 8) {
                            Spacer()
                            Text("접수 이력이 없습니다.")
                                .foregroundColor(.gray)
                                .font(.body)
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 600)
                    } else {
                        if checkInListViewModel.items.isEmpty {
                            ProgressView("불러오는 중...")
                        } else {
                            // MARK: 스크롤 콘텐츠
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(checkInListViewModel.items) { item in
                                        NavigationLink {
                                            CheckInDetailView(checkInDetailViewModel: CheckInDetailViewModel(item: item))
                                        } label: {
                                            CheckInCard(item: item)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("접수 목록")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await checkInListViewModel.fetchReceipts()
                }
            }
        }
    }
}

#Preview {
    let viewModel = CheckInListViewModel()
    CheckInListView(checkInListViewModel: viewModel)
}
