import SwiftUI

struct EditableField<T: LosslessStringConvertible>: View {
    @FocusState private var isFocused: Bool
    @Binding var value: T
    var placeholder: String
    var isEditable: Bool = true
    var action: (() -> Void)? = nil

    var body: some View {
        if isEditable {
            ZStack(alignment: .leading) {
                // 실제 입력 필드
                TextField(
                    "",
                    text: Binding(
                        get: { String(describing: value) },
                        set: { newValue in
                            if let converted = T(newValue), !newValue.isEmpty {
                                value = converted
                            } else if newValue.isEmpty {
                                // 값 지웠을 때 빈값 처리 (String은 "" / Int는 0 등)
                                if let emptyValue = T("") {
                                    value = emptyValue
                                }
                            }
                        }
                    )
                )
                .focused($isFocused)
                .keyboardType(T.self == Int.self ? .numberPad : .default)
                .padding()
                .background(AppColor.mainWhite)
                .cornerRadius(10)
                .shadow(color: AppColor.mainBlack.opacity(0.05), radius: 3, x: 0, y: 1)

                // placeholder
                if String(describing: value).isEmpty && !isFocused {
                    Text(placeholder)
                        .foregroundColor(AppColor.mainTextGray)
                        .padding()
                }
            }
        } else {
            Button(action: { action?() }) {
                HStack {
                    Text(String(describing: value).isEmpty ? placeholder : String(describing: value))
                        .foregroundColor(String(describing: value).isEmpty ? AppColor.mainTextGray : .black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColor.mainTextGray)
                }
                .padding()
                .background(AppColor.mainWhite)
                .cornerRadius(10)
                .shadow(color: AppColor.mainBlack.opacity(0.05), radius: 3, x: 0, y: 1)
            }
        }
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
