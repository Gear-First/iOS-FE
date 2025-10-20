import SwiftUI

struct CarSearchSheetView: View {
    @ObservedObject var viewModel: OrderRequestViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                EditableField(
                    value: $searchText,
                    placeholder: "차량번호를 입력해주세요"
                )
                .padding(.horizontal, 12)
                .onChange(of: searchText) { newValue in
                    Task {
                        await viewModel.fetchAllVehicles(engineerId: 1)
                    }
                }

                if viewModel.isLoading {
                    ProgressView("검색 중...")
                        .padding(.top, 24)
                } else if let error = viewModel.errorMessage {
                    Text("\(error)")
                        .foregroundColor(.red)
                        .padding(.top, 24)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.vehicleList) { vehicle in
                                Button {
                                    viewModel.selectedVehicle = vehicle
                                    dismiss()
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(vehicle.plateNumber)
                                                .font(.headline)
                                                .foregroundColor(AppColor.mainBlack)
                                            Spacer()
                                            Text(vehicle.repairNumber)
                                                .font(.caption)
                                                .foregroundColor(AppColor.mainTextGray)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(AppColor.mainBorderGray.opacity(0.6))
                                                )
                                        }
                                        Text(vehicle.model)
                                            .font(.subheadline)
                                            .foregroundColor(AppColor.mainTextGray)
                                        Divider()
                                            .padding(.vertical, 6)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("차량번호 검색")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchAllVehicles(engineerId: 1) // 초기 전체 목록
            }
        }
    }
}
