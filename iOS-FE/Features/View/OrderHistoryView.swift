import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("필터", selection: $historyViewModel.selectedFilter) {
                    ForEach(OrderFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                ScrollView {
                    if historyViewModel.items.isEmpty {
                        // 요청 내역이 없을 때
                        VStack {
                            Spacer()
                            Text("요청 내역이 없습니다.")
                                .foregroundColor(.gray)
                                .font(.body)
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 600)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(historyViewModel.filteredItems) { item in
                                NavigationLink(
                                    destination: OrderDetailView(item: item, onCancel: {
                                        historyViewModel.cancelOrder(item)
                                    })
                                ) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        // 발주번호
                                        Text("발주번호: \(item.id ?? "-")")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        // 부품명 + 수량
                                        Text("부품: \(item.inventoryName) (\(item.quantity)개)")
                                            .font(.subheadline)
                                        
                                        // 상태 뱃지
                                        HStack {
                                            Text(item.status ?? "요청됨")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(OrderStatus(rawValue: item.status ?? "요청됨")?.badgeColor ?? .blue)
                                                .cornerRadius(6)
                                            
                                            Spacer()
                                            
                                            // 날짜
                                            Text(item.requestDate)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(.top, 12)
            .navigationTitle("요청 내역")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let dummyItems = [
        OrderItem(
            inventoryCode: "INV-001",
            inventoryName: "브레이크 패드",
            quantity: 5,
            requestDate: "2025-10-04",
            id: "ORD-1234",
            status: "요청됨"
        )
    ]
    let viewModel = OrderHistoryViewModel(items: dummyItems)
    return OrderHistoryView(historyViewModel: viewModel)
}
