import SwiftUI

struct EditableField<T: LosslessStringConvertible>: View {
    @FocusState private var isFocused: Bool
    @Binding var value: T
    var placeholder: String
    var isEditable: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if isEditable {
                editableField
            } else {
                selectionField
            }
        }
    }

    // MARK: - Editable Mode
    private var editableField: some View {
        ZStack(alignment: .leading) {
            TextField(
                "",
                text: Binding(
                    get: {
                        if let doubleValue = value as? Double {
                            return String(format: "%.2f", doubleValue)
                        } else {
                            return String(describing: value)
                        }
                    },
                    set: { newValue in
                        if let converted = T(newValue), !newValue.isEmpty {
                            value = converted
                        } else if newValue.isEmpty, let emptyValue = T("") {
                            value = emptyValue
                        }
                    }
                )
            )
            .focused($isFocused)
            .keyboardType(T.self == Int.self ? .numberPad : .default)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isFocused ? AppColor.mainColor : AppColor.cardBorder, lineWidth: 1)
            )
            .shadow(color: AppColor.cardShadow, radius: isFocused ? 12 : 6, x: 0, y: 4)
            
            if String(describing: value).isEmpty && !isFocused {
                Text(placeholder)
                    .foregroundColor(AppColor.textMuted)
                    .padding(.horizontal, 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Selection Mode
    private var selectionField: some View {
        Button(action: { action?() }) {
            HStack {
                Text(displayText)
                    .foregroundColor(displayText.isEmpty ? AppColor.textMuted : AppColor.mainTextBlack)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColor.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColor.cardBorder, lineWidth: 1)
            )
            .shadow(color: AppColor.cardShadow, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var displayText: String {
        let text = String(describing: value)
        return text == "0" ? "" : text
    }
}

#Preview {
    VStack(spacing: 16) {
        // 버튼 모드
        EditableField(
            value: .constant(""),
            placeholder: "차량번호를 선택하세요",
            isEditable: false,
            action: { print("버튼 클릭") }
        )
        
        // 텍스트 입력 모드
        EditableField(
            value: .constant(""),
            placeholder: "이름을 입력하세요"
        )
        
        // 숫자 입력 모드
        EditableField(
            value: .constant(0),
            placeholder: "수량을 입력하세요"
        )
    }
    .padding()
}
