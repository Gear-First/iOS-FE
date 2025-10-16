import SwiftUI



struct CheckInListView: View {
    @ObservedObject var checkInListViewModel: CheckInListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(AppColor.bgGray)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        // MARK: - 총 개수 표시
                        Text("총 \(checkInListViewModel.items.count)건")
                            .font(.subheadline)
                            .foregroundColor(AppColor.mainTextGray)
                            .padding(.trailing, 10)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - 리스트 영역
                    if checkInListViewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView("불러오는 중...")
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColor.mainBlue))
                                .font(.headline)
                            Spacer()
                        }
                    } else if checkInListViewModel.items.isEmpty {
                        Text("접수 이력이 없습니다.")
                    }else {
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

// MARK: - Preview
#Preview {
    let viewModel = CheckInListViewModel()
    CheckInListView(checkInListViewModel: viewModel)
}
