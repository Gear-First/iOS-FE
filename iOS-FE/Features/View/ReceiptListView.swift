import SwiftUI



struct ReceiptListView: View {
    @ObservedObject var receiptListViewModel: ReceiptListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(AppColor.bgGray)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        // MARK: - 총 개수 표시
                        Text("총 \(receiptListViewModel.items.count)건")
                            .font(.subheadline)
                            .foregroundColor(AppColor.mainTextGray)
                            .padding(.trailing, 10)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - 리스트 영역
                    if receiptListViewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView("불러오는 중...")
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColor.mainBlue))
                                .font(.headline)
                            Spacer()
                        }
                    } else if receiptListViewModel.items.isEmpty {
                        VStack {
                                Spacer()
                                Text("접수 이력이 없습니다.")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(receiptListViewModel.items) { item in
                                    NavigationLink {
                                        ReceiptDetailView(receiptDetailViewModel: ReceiptDetailViewModel(item: item))
                                    } label: {
                                        ReceiptCard(item: item)
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
                    await receiptListViewModel.fetchReceipts()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let viewModel = ReceiptListViewModel()
    ReceiptListView(receiptListViewModel: viewModel)
}
