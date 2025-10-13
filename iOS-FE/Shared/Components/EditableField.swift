import SwiftUI

struct EditableField: View {
    @FocusState private var isFocused: Bool
    @Binding var text: String
    var placeholder: String
    var isEditable: Bool = true
    var action: (() -> Void)? = nil  // 버튼 액션
    
    var body: some View {
        if isEditable {
            ZStack(alignment: .leading) {
                // 배경 텍스트필드
                TextField("", text: $text)
                    .focused($isFocused)
                    .padding()
                    .background(AppColor.mainWhite)
                    .cornerRadius(10)
                    .shadow(color: AppColor.mainBlack.opacity(0.05), radius: 3, x: 0, y: 1)
                
                // placeholder 표시 조건
                if text.isEmpty && !isFocused {
                    Text(placeholder)
                        .foregroundColor(AppColor.mainTextGray)
                        .padding()
                }
            }
        } else {
            Button(action: {
                action?()
            }) {
                HStack {
                    Text(text.isEmpty ? placeholder : text)
                        .foregroundColor(text.isEmpty ? AppColor.mainTextGray : .black)
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
            text: .constant(""),
            placeholder: "버튼 예시",
            isEditable: false,
            action: {
                print("차량 선택")
            }
        )

        // 입력 모드
        EditableField(
            text: .constant(""),
            placeholder: "TextField 예시",
            isEditable: true
        )
    }
    .padding()
}
