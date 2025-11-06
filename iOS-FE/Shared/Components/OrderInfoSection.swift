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

            LazyVStack(spacing: 10) {
                ForEach(items) { item in
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.partName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.mainTextBlack)
                            Text(item.partCode)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColor.textMuted)
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            Text("\(item.quantity)EA")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColor.mainBlue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppColor.mainBlue.opacity(0.1))
                                .clipShape(Capsule())
                            if item.price > 0 {
                                Text("\(formatCurrency(item.price * Double(item.quantity)))")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColor.mainTextBlack)
                            }
                        }
                    }
                    .padding(12)
                    .background(AppColor.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
