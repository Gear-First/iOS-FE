import SwiftUI

// MARK: - 수리 항목 카드
struct RepairItemCard: View {
    @ObservedObject var form: RepairItemForm
    var title: String = "항목"
    var onRemove: (() -> Void)?
    
    var onShowPartSearch: ((RepairPartForm) -> Void)?
    var onShowQuantityPicker: ((RepairPartForm) -> Void)?
    var onShowContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            Divider()
            if onShowContent == true {
                contentSection
            }
            PartSelectionSection(
                parts: $form.parts,
                onShowPartSearch: onShowPartSearch,
                onShowQuantityPicker: onShowQuantityPicker
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - 헤더
    private var headerSection: some View {
        HStack {
            Text("수리 항목")
                .font(.headline)
            Spacer()
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
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
}

// MARK: - Preview
#Preview("RepairItemCard Preview") {
    let part1 = RepairPartForm()
    part1.partName = "엔진오일"
    part1.quantity = 2
    part1.unitPrice = 45000

    let part2 = RepairPartForm()
    part2.partName = "오일필터"
    part2.quantity = 1
    part2.unitPrice = 12000

    let repairForm = RepairItemForm()
    repairForm.description = "엔진오일 교체"
    repairForm.cause = "주행거리 초과"
    repairForm.parts = [part1, part2]

    return RepairItemCard(
        form: repairForm,
        onRemove: { print("삭제 버튼 클릭") },
        onShowPartSearch: { part in print("검색 클릭: \(part.partName)") },
        onShowQuantityPicker: { part in print("수량 선택: \(part.partName)") },
        onShowContent: true
    )
    .padding()
}
