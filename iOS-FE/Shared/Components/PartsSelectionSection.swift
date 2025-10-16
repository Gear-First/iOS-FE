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
                Divider().opacity(0.1)
            }
            
            Button {
                withAnimation {
                    parts.append(RepairPartForm())
                }
            } label: {
                Label("부품 추가", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(AppColor.mainBlue)
            }
            .padding(.top, 4)
        }
    }
}
