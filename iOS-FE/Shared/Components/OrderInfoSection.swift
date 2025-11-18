import SwiftUI

struct OrderInfoSection: View {
    let items: [OrderItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("발주 상세 정보")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                Spacer()
                Text("총 \(items.count)건")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textMuted)
            }
            
            
            
            
            
            
            VStack(spacing: 8) {
                ForEach(items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.partName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColor.mainTextBlack)
                            HStack(spacing: 10) {
                                Text("수량 \(item.quantity)EA")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("단가 \(formatCurrency(item.price))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        
                            Text("\(formatCurrency(item.price * Double(item.quantity)))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#1E293B"))
                    }
                    .padding(10)
                    .background(AppColor.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
        }
        .gfCardStyle(cornerRadius: 22, padding: 24)
    }
}

private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: value)) ?? "0"
}
