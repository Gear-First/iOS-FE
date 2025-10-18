import SwiftUI

struct MyPageView: View {
    // MARK: - 사용자 정보
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    @State private var name: String = "홍길동"
    @State private var branch: String = "서울지점"
    @State private var position: String = "주임"
    @State private var email: String = "example@company.com"
    @State private var phoneNumber: String = "010-1234-5678"
    @State private var joinDate: String = "2023-05-01"
    @State private var role: String = "일반 직원"
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - 프로필 영역
            VStack(spacing: 16) {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(position + " | " + branch)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 40)
            
            // MARK: - 정보 카드
            VStack(spacing: 16) {
                InfoCard(icon: "envelope.fill", label: "이메일", value: email)
                InfoCard(icon: "phone.fill", label: "전화번호", value: phoneNumber)
                InfoCard(icon: "calendar", label: "가입일", value: joinDate)
                InfoCard(icon: "person.fill.checkmark", label: "권한", value: role)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // MARK: - 로그아웃 버튼
            Button(action: {
                print("로그아웃 클릭")
            }) {
                Text("로그아웃")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .navigationTitle("마이페이지")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 정보 카드 컴포넌트
struct InfoCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 미리보기
struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyPageView()
        }
    }
}
