import SwiftUI

private struct PartRowView: View {
    @ObservedObject var part: RepairPartForm
    let autofill: () -> Void
    let onTapSearch: () -> Void
    let onTapQuantityPicker: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        let nameBinding = Binding<String>(
            get: { part.partName },
            set: { part.partName = $0 }
        )
        let qtyBinding = Binding<Int>(
            get: { part.quantity },
            set: { part.quantity = $0 }
        )
        
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                EditableField(value: nameBinding,
                              placeholder: "부품 선택",
                              isEditable: false) {
                    onTapSearch()
                }
                              .onChange(of: part.partName) { _ in
                                  autofill()
                              }
                
                quantityPickerButton(qtyBinding)
            }
            
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("이 부품 삭제", systemImage: "minus.circle.fill")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func quantityPickerButton(_ qtyBinding: Binding<Int>) -> some View {
        ZStack {
            EditableField(value: qtyBinding,
                          placeholder: "수량",
                          isEditable: true)
            .keyboardType(.numberPad)
            .padding(.trailing, 32)
            
            HStack {
                Spacer()
                Button(action: onTapQuantityPicker) {
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(AppColor.mainTextGray)
                }
                .padding(.trailing, 8)
            }
        }
        .frame(width: 110)
    }
}

struct PartSelectionSection: View {
    @Binding var parts: [RepairPartForm]
    var onShowPartSearch: ((RepairPartForm) -> Void)?
    var onShowQuantityPicker: ((RepairPartForm) -> Void)?
    
    private var canAddNextPart: Bool {
        // 마지막 행이 유효하게 선택(이름/코드)되면 바로 추가 가능. 수량은 신경 쓰지 않음
        guard let last = parts.last else { return false }
        return !last.partName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               last.partId != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(parts) { part in
                PartRowView(
                    part: part,
                    autofill: {},
                    onTapSearch: {
                        onShowPartSearch?(part)
                    },
                    onTapQuantityPicker: {
                        onShowQuantityPicker?(part)
                    },
                    onDelete: parts.count > 1 ? {
                        withAnimation {
                            parts.removeAll { $0.id == part.id }
                        }
                    } : nil
                )
                Divider().overlay(AppColor.cardBorder.opacity(0.6))
            }
            
            // 마지막 part를 직접 관찰하는 뷰
            if let lastPart = parts.last {
                AddButtonView(
                    part: lastPart,
                    onAdd: {
                        withAnimation {
                            parts.append(RepairPartForm())
                        }
                    }
                )
            } else {
                Button {
                    withAnimation {
                        parts.append(RepairPartForm())
                    }
                } label: {
                    Label("부품 추가", systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.textMuted)
                }
                .disabled(true)
                .padding(.top, 4)
            }
        }
    }
}

// 부품 추가 버튼을 별도 뷰로 분리하여 마지막 part의 변경을 직접 관찰
private struct AddButtonView: View {
    @ObservedObject var part: RepairPartForm
    let onAdd: () -> Void
    
    private var canAdd: Bool {
        !part.partName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        part.partId != nil
    }
    
    var body: some View {
        Button {
            onAdd()
        } label: {
            Label("부품 추가", systemImage: "plus.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(canAdd ? AppColor.mainBlue : AppColor.textMuted)
        }
        .disabled(!canAdd)
        .padding(.top, 4)
    }
}

#Preview {
    let mockParts: [RepairPartForm] = [
        {
            let part = RepairPartForm()
            part.partName = "엔진오일"
            part.quantity = 2
            return part
        }(),
        {
            let part = RepairPartForm()
            part.partName = "브레이크 패드"
            part.quantity = 1
            return part
        }()
    ]
    
    return PartSelectionSection(
        parts: .constant(mockParts),
        onShowPartSearch: { part in
            print("검색 탭한 부품: \(part.partName)")
        },
        onShowQuantityPicker: { part in
            print("수량 선택 탭한 부품: \(part.partName)")
        }
    )
    .padding()
}
