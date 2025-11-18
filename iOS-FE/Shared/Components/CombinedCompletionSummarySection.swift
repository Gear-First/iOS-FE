import SwiftUI

/// 완료 상태: 수리 내용/원인 + 발주 부품 + 추가 사용 부품 + 총합계
struct CombinedCompletionSummarySection: View {
    struct Line: Identifiable {
        let id = UUID()
        let name: String
        let quantity: Int
        let unitPrice: Double
        
        var totalPrice: Double { Double(quantity) * unitPrice }
    }
    
    var descriptionText: String
    var causeText: String
    var orderedLines: [Line]
    var extraUsedLines: [Line]
    
    private var orderedTotal: Double {
        orderedLines.reduce(0) { $0 + $1.totalPrice }
    }
    
    private var extraTotal: Double {
        extraUsedLines.reduce(0) { $0 + $1.totalPrice }
    }
    
    private var grandTotal: Double {
        orderedTotal + extraTotal
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("완료 요약")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
            
            summaryPills
            
            if !orderedLines.isEmpty {
                linesSection(title: "발주된 부품", lines: orderedLines, accent: AppColor.mainBlue.opacity(0.08))
            }
            
            if !extraUsedLines.isEmpty {
                linesSection(title: "추가 사용 부품", lines: extraUsedLines, accent: AppColor.mainYellow.opacity(0.08))
            }
            
            totalFooter
        }
        .gfCardStyle(cornerRadius: 22, padding: 24)
    }
    
    private var summaryPills: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoChip(title: "수리 내용", text: descriptionText, icon: "wrench.and.screwdriver.fill")
            infoChip(title: "원인", text: causeText, icon: "exclamationmark.octagon.fill")
        }
    }
    
    private func infoChip(title: String, text: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.mainBlue)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.textMuted)
            }
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.mainTextBlack)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func linesSection(title: String, lines: [Line], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
            
            VStack(spacing: 10) {
                ForEach(lines) { line in
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(line.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.mainTextBlack)
                            Text("수량 \(line.quantity)EA · 단가 \(formatCurrency(line.unitPrice))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColor.textMuted)
                        }
                        Spacer()
                        Text(formatCurrency(line.totalPrice))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppColor.mainTextBlack)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    private var totalFooter: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("발주 합계")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textMuted)
                Spacer()
                Text(formatCurrency(orderedTotal))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColor.mainTextBlack)
            }
            HStack {
                Text("추가 사용 합계")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textMuted)
                Spacer()
                Text(formatCurrency(extraTotal))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColor.mainTextBlack)
            }
            // 구분선 제거로 여백만 유지
            HStack {
                Text("총 비용")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColor.mainTextBlack)
                Spacer()
                Text(formatCurrency(grandTotal))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColor.mainBlue)
            }
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

//#Preview {
//    CombinedCompletionSummarySection(
//        descriptionText: "엔진오일 교체 및 배선 점검을 완료했습니다.",
//        causeText: "오랜 주행으로 배선이 손상되어 교체가 필요했습니다.",
//        orderedLines: [
//            .init(name: "엔진오일", quantity: 2, unitPrice: 45000),
//            .init(name: "오일필터", quantity: 1, unitPrice: 12000)
//        ],
//        extraUsedLines: [
//            .init(name: "전선", quantity: 3, unitPrice: 3500)
//        ]
//    )
//    .padding()
//    .background(AppColor.background)
//}
