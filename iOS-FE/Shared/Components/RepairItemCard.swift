import SwiftUI

// MARK: - 수리 항목 카드
struct RepairItemCard: View {
    @ObservedObject var form: RepairItemForm
var completeParts: [OrderItem]? = nil
    var title: String = ""
    var onRemove: (() -> Void)?
    
    var onShowPartSearch: ((RepairPartForm) -> Void)?
    var onShowQuantityPicker: ((RepairPartForm) -> Void)?
    
    // MARK: - 임시
    var showPartSection: Bool = false
    //  (선택) 항목 탭 액션은 별도 클로저
    var onPartTap: ((RepairPartForm) -> Void)?
    
    // 임시 텍스트 리스트(백 연동 전)
    var partTexts: [String]? = nil
    
    var onShowContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerSection
            if onShowContent {
                contentSection
            }
            if showPartSection {
                partSection
            }
            
            PartSelectionSection(
                parts: $form.parts,
                onShowPartSearch: onShowPartSearch,
                onShowQuantityPicker: onShowQuantityPicker
            )
        }
        .gfCardStyle(cornerRadius: 22, padding: 24)
    }
    
    // MARK: - 헤더
    private var headerSection: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.mainTextBlack)
            Spacer()
        }
    }
    
    // MARK: - 내용 입력
    private var contentSection: some View {
        VStack(spacing: 8) {
            EditableField(value: Binding(
                get: { form.description },
                set: { form.description = $0 }),
                          placeholder: "수리 내용",
                          isEditable: true
            )
            
            EditableField(value: Binding(
                get: { form.cause },
                set: { form.cause = $0 }),
                          placeholder: "원인",
                          isEditable: true
            )
        }
    }
    
    // -MARK: 임시: 파츠
    private var partSection: some View {
        let items = completeParts ?? []
        return VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                Text("발주된 부품")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.mainTextBlack)
                Spacer()
                    CountBadge(count: items.count)
                
            }

            if items.isEmpty {
                // 비어있을 때
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(AppColor.textMuted)
                    Text("등록된 부품이 없습니다.")
                        .foregroundColor(AppColor.textMuted)
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColor.surfaceMuted)
                )
            } else {
                // 목록
                VStack(spacing: 0) {
                    ForEach(items) { it in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            // name / code
                            VStack(alignment: .leading, spacing: 2) {
                                Text(it.partName)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppColor.mainTextBlack)
                                if !(it.partCode.isEmpty) {
                                    Text(it.partCode)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppColor.textMuted)
                                }
                            }

                            Spacer(minLength: 8)

                            // qty pill
                            QtyPill(qty: it.quantity)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)

                        if it.id != items.last?.id { // 마지막 줄 구분선 제외
                            Divider().overlay(AppColor.cardBorder.opacity(0.5))
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColor.surfaceMuted)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppColor.cardBorder, lineWidth: 1)
                )
        )
    }
    
}

private struct CountBadge: View {
    let count: Int
    var body: some View {
        Text("총 \(count)개")
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 8).fill(AppColor.surfaceMuted))
            .foregroundColor(AppColor.textMuted)
    }
}

private struct QtyPill: View {
    let qty: Int
    var body: some View {
        HStack(spacing: 4) {
            Text("\(qty)개")
        }
        .font(.system(size: 12, weight: .semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(AppColor.accentBlueSoft.opacity(0.6)))
        .foregroundColor(AppColor.mainBlue)
    }
}

// MARK: - Preview
#Preview("RepairItemCard Preview") {
    let part1 = RepairPartForm()
    part1.partName = "엔진오일"
    part1.quantity = 2
    part1.unitPrice = 45_000
    
    let part2 = RepairPartForm()
    part2.partName = "오일필터"
    part2.quantity = 1
    part2.unitPrice = 12_000
    
    let repairForm = RepairItemForm()
    repairForm.description = "엔진오일 교체"
    repairForm.cause = "주행거리 초과"
    repairForm.parts = [part1, part2]
    
    return RepairItemCard(
        form: repairForm,
        onRemove: { print("삭제 버튼 클릭") },
        onShowPartSearch: { part in print("검색 클릭: \(part.partName)") },
        onShowQuantityPicker: { part in print("수량 선택: \(part.partName)") },
        // 프리뷰에서는 그냥 텍스트로 섹션 테스트
        showPartSection: true,
        partTexts: [
            "엔진룸",
            "오일",
            "필터"
        ],
        onShowContent: true
    )
    .padding()
}
