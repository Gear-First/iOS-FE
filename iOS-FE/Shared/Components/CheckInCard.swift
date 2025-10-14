import SwiftUI

struct CheckInCard: View {
    let item: CheckInItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("접수번호: \(item.id)")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("차주:")
                    .font(.subheadline)
                Spacer()
                Text("\(item.ownerName)")
                    .font(.subheadline)
            }
            
            HStack {
                Text("차량번호:")
                    .font(.subheadline)
                Spacer()
                Text("\(item.carNumber)")
                    .font(.subheadline)
            }
            
            HStack {
            Spacer()
                Text(item.date)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let mockItem = CheckInItem(
        id: "ABC-001",
        carNumber: "11가 1234",
        ownerName: "박우진",
        carModel: "그랜저",
        requestContent: "엔진오일 교체 요청",
        date: "2025-11-11",
        phoneNumber: "010-1234-5678",
        manager: "정상기",
        status: .inProgress
    )
    
    return CheckInCard(item: mockItem)
        .padding()
}
