import SwiftUI

struct OrderRequestView: View {
    @StateObject private var viewModel = OrderRequestViewModel()
    @ObservedObject var historyViewModel: OrderHistoryViewModel
    @State private var showDatePicker: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Spacer().frame(height: 40)
                // 부품명 검색
                TextField("부품명 검색", text: $viewModel.orderName)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14) // ← 이게 진짜 높이를 키움
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                // 수량 입력
                HStack {
                    TextField("수량 입력", value: $viewModel.orderQuantity, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .frame(height: 48)
                    
                    VStack(spacing: 0) {
                        Button(action: { viewModel.orderQuantity += 1 }) {
                            Image(systemName: "chevron.up")
                                .frame(width: 24, height: 24)
                        }
                        Button(action: {
                            if viewModel.orderQuantity > 0 {
                                viewModel.orderQuantity -= 1
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 8)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .cornerRadius(8)
                
                // 요청일
                HStack(spacing: 0) {
                    TextField("요청일 (yyyy-MM-dd)", text: $viewModel.rawDateInput)
                        .keyboardType(.numbersAndPunctuation)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                    
                    Button(action: {
                        withAnimation {
                            showDatePicker.toggle()
                        }
                    }) {
                        Image(systemName: "calendar")
                            .padding(.horizontal, 12)
                            .foregroundColor(.blue)
                    }
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .cornerRadius(8)
                
                if showDatePicker {
                    DatePicker(
                        "",
                        selection: $viewModel.requestDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                
                // 부품명 코드 (비활성화)
                TextField("부품명 코드", text: $viewModel.orderCode)
                    .disabled(true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                Button(action: {
                    let newItem = viewModel.submitRequestOrder()
                    historyViewModel.addNewItem(newItem)
                    dismiss()
                }) {
                    Text("요청하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.mainBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .navigationTitle("부품 요청")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let dummyHistoryItems = [
        OrderItem(
            inventoryCode: "ORD-001",
            inventoryName: "브레이크 패드",
            quantity: 12,
            requestDate: "2025-10-04",
            id: "123",
            status: "요청됨"
        )
    ]
    
    let viewModel = OrderHistoryViewModel(items: dummyHistoryItems)
    OrderRequestView(historyViewModel: viewModel)
}
