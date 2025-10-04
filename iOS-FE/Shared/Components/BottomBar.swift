import SwiftUI

struct BottomBar: View {
    @State private var selectedIndex: Int = 0
    @StateObject private var historyViewModel = OrderHistoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // 메인 컨텐츠
            ZStack {
                switch selectedIndex {
                case 0: MyPageView()
                case 1: OrderRequestView(historyViewModel: historyViewModel)
                case 2: OrderHistoryView(historyViewModel: historyViewModel)
                case 3: MyPageView()
                case 4: MyPageView()
                default: MyPageView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 커스텀 바텀바
            HStack {
                bottomBarItem(index: 0, title: "홈", icon: "house.fill")
                bottomBarItem(index: 1, title: "요청", icon: "square.and.pencil")
                bottomBarItem(index: 2, title: "내역", icon: "document")
                bottomBarItem(index: 3, title: "알림", icon: "bell")
                bottomBarItem(index: 4, title: "내 정보", icon: "person.crop.circle")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(height: 100)
            .background(AppColor.mainWhite)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AppColor.mainGray.opacity(0.6)),
                alignment: .top
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // 바텀바 아이템
    private func bottomBarItem(index: Int, title: String, icon: String) -> some View {
        Button(action: {
            selectedIndex = index
        }) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(selectedIndex == index ? AppColor.mainBlue : .gray)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(selectedIndex == index ? AppColor.mainBlue : .gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 20)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    BottomBar()
}
