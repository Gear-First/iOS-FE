import SwiftUI



struct ReceiptListView: View {
    @ObservedObject var receiptListViewModel: ReceiptListViewModel
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("접수 목록")
                .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await receiptListViewModel.fetchReceipts()
                }
            }
        }
    }

    private var mainContent: some View {
        Group {
            if receiptListViewModel.isLoading && receiptListViewModel.items.isEmpty {
                loadingState
            } else if receiptListViewModel.items.isEmpty {
                EmptyStateView(
                    title: "접수 이력이 없습니다.",
                    message: "새로운 접수를 등록하면 목록이 갱신됩니다."
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        ForEach(receiptListViewModel.items) { item in
                            NavigationLink {
                                ReceiptDetailView(
                                    receiptDetailViewModel: ReceiptDetailViewModel(item: item)
                                )
                            } label: {
                                ReceiptCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                .background(AppColor.background.ignoresSafeArea())
            }
        }
        .background(AppColor.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오늘 접수된 차량을 확인하세요.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColor.textMuted)
            Text("총 \(receiptListViewModel.items.count)건")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColor.mainTextBlack)
        }
    }

    private var loadingState: some View {
        VStack {
            Spacer()
            ProgressView("불러오는 중...")
                .progressViewStyle(CircularProgressViewStyle(tint: AppColor.mainBlue))
                .font(.headline)
            Spacer()
        }
        .background(AppColor.background)
    }
}

// MARK: - Preview
#Preview {
    let viewModel = ReceiptListViewModel()
    ReceiptListView(receiptListViewModel: viewModel)
}
