import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelAlert = false
    
    let item: OrderItem
    let onCancel: () -> Void
    
    private var statusColor: Color {
        OrderStatus(rawValue: item.status ?? "요청됨")?.badgeColor ?? .blue
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                VStack(spacing: 12) {
                    Text(item.status ?? "요청됨")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(statusColor)
                        .clipShape(Capsule())
                    
                    Text("발주번호 \(item.id)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    infoRow(title: "부품", value: item.inventoryName)
                    infoRow(title: "부품코드", value: item.inventoryCode)
                    infoRow(title: "수량", value: "\(item.quantity)개")
                    infoRow(title: "요청일자", value: item.requestDate)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                if item.status == "요청됨" {
                    Button(action: { showCancelAlert = true }) {
                        Text("요청 취소하기")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 10)
                    .alert(isPresented: $showCancelAlert) {
                        Alert(
                            title: Text("요청을 취소하시겠습니까?"),
                            message: Text("한 번 취소하면 되돌릴 수 없습니다."),
                            primaryButton: .destructive(Text("취소하기"), action: {
                                onCancel()
                            }),
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Spacer(minLength: 30)
            }
            .padding()
        }
        .padding(.top, 12)
        .navigationTitle("요청 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundColor(AppColor.mainDarkBlue)
                }
            }
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OrderDetailView(
        item: OrderItem(
            inventoryCode: "INV-001",
            inventoryName: "브레이크 패드",
            quantity: 5,
            requestDate: "2025-10-04",
            id: "ORD-1234",
            status: "요청됨"
        ),
        onCancel: {}
    )
}
