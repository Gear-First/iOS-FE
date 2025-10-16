import Foundation

struct MockCheckInData {
//    static let sample: [CheckInItem] = [
//        CheckInItem(id: "CHK-1001", carNumber: "12가 3456", ownerName: "김민수", carModel: "소나타", requestContent: "엔진오일 교체 및 점검", date: "2025-10-13", phoneNumber: "010-1234-5678", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1002", carNumber: "56나 7890", ownerName: "이영희", carModel: "아반떼", requestContent: "타이어 교체", date: "2025-10-12", phoneNumber: "010-2222-3333", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1003", carNumber: "33다 1122", ownerName: "박철수", carModel: "그랜저", requestContent: "에어컨 점검", date: "2025-10-12", phoneNumber: "010-3333-4444", manager: "홍길동", status: .inProgress),
//        CheckInItem(id: "CHK-1004", carNumber: "45라 3344", ownerName: "정하늘", carModel: "K5", requestContent: "브레이크 패드 교체", date: "2025-10-11", phoneNumber: "010-5555-6666", manager: "김도윤", status: .completed),
//        CheckInItem(id: "CHK-1005", carNumber: "78마 5566", ownerName: "최보라", carModel: "투싼", requestContent: "하체 소음 점검", date: "2025-10-11", phoneNumber: "010-7777-8888", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1006", carNumber: "99바 7788", ownerName: "이준호", carModel: "K3", requestContent: "배터리 교체 요청", date: "2025-10-10", phoneNumber: "010-9999-1111", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1007", carNumber: "11사 8899", ownerName: "김다은", carModel: "SM6", requestContent: "냉각수 누수 점검", date: "2025-10-09", phoneNumber: "010-1234-0000", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1008", carNumber: "22아 9900", ownerName: "정태훈", carModel: "카니발", requestContent: "에어컨 필터 교체", date: "2025-10-09", phoneNumber: "010-2323-4545", manager: "송지은", status: .completed),
//        CheckInItem(id: "CHK-1009", carNumber: "33자 1111", ownerName: "오상훈", carModel: "쏘렌토", requestContent: "전조등 교체", date: "2025-10-09", phoneNumber: "010-5656-7878", manager: "송지은", status: .inProgress),
//        CheckInItem(id: "CHK-1010", carNumber: "44차 2222", ownerName: "윤가영", carModel: "K7", requestContent: "오디오 소리 안남", date: "2025-10-08", phoneNumber: "010-8787-9898", manager: "송지은", status: .inProgress),
//        CheckInItem(id: "CHK-1011", carNumber: "55카 3333", ownerName: "조성민", carModel: "스포티지", requestContent: "핸들 떨림 점검", date: "2025-10-08", phoneNumber: "010-1212-3434", manager: "송지은", status: .inProgress),
//        CheckInItem(id: "CHK-1012", carNumber: "66타 4444", ownerName: "박예진", carModel: "G80", requestContent: "엔진 소음 확인 요청", date: "2025-10-08", phoneNumber: "010-4545-6767", manager: "송지은", status: .inProgress),
//        CheckInItem(id: "CHK-1013", carNumber: "77파 5555", ownerName: "배성우", carModel: "모닝", requestContent: "브레이크 등 불량", date: "2025-10-07", phoneNumber: "010-7878-9090", manager: "송지은", status: .inProgress),
//        CheckInItem(id: "CHK-1014", carNumber: "88하 6666", ownerName: "한지훈", carModel: "GV70", requestContent: "차량 진동 심함", date: "2025-10-07", phoneNumber: "010-2222-8989", manager: "송지은", status: .inProgress),
//        CheckInItem(id: "CHK-1015", carNumber: "99거 7777", ownerName: "이도윤", carModel: "스팅어", requestContent: "브레이크액 교체 요청", date: "2025-10-07", phoneNumber: "010-3030-5050", manager: "송지은", status: .completed),
//        CheckInItem(id: "CHK-1016", carNumber: "10너 8888", ownerName: "강서준", carModel: "쏘나타 하이브리드", requestContent: "도어 잠금 고장", date: "2025-10-06", phoneNumber: "010-1111-2222", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1017", carNumber: "11더 9999", ownerName: "남기현", carModel: "스파크", requestContent: "냉각수 보충 요청", date: "2025-10-06", phoneNumber: "010-3333-4444", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1018", carNumber: "22러 0000", ownerName: "홍지민", carModel: "K8", requestContent: "배기구 점검 요청", date: "2025-10-05", phoneNumber: "010-5555-6666", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1019", carNumber: "33머 1010", ownerName: "박상혁", carModel: "아반떼", requestContent: "타이어 펑크", date: "2025-10-05", phoneNumber: "010-7777-8888", manager: nil, status: .checkIn),
//        CheckInItem(id: "CHK-1020", carNumber: "44버 2020", ownerName: "이서연", carModel: "GV80", requestContent: "내비게이션 오류", date: "2025-10-04", phoneNumber: "010-9999-0000", manager: nil, status: .checkIn),
////        CheckInItem(id: "CHK-1021", carNumber: "55서 3030", ownerName: "김하늘", carModel: "포터2", requestContent: "트렁크 문이 안 닫힘", date: "2025-10-04", phoneNumber: "010-1010-2020", manager: nil, status: .checkIn),
////        CheckInItem(id: "CHK-1022", carNumber: "66어 4040", ownerName: "이상민", carModel: "K9", requestContent: "엔진 경고등 점등", date: "2025-10-03", phoneNumber: "010-3030-4040", manager: "홍길동", status: .inProgress),
////        CheckInItem(id: "CHK-1023", carNumber: "77저 5050", ownerName: "정유진", carModel: "GV60", requestContent: "EV 충전 포트 작동 안함", date: "2025-10-03", phoneNumber: "010-5050-6060", manager: nil, status: .checkIn),
////        CheckInItem(id: "CHK-1024", carNumber: "88초 6060", ownerName: "최성우", carModel: "모하비", requestContent: "진동 심함 및 오일 누유", date: "2025-10-02", phoneNumber: "010-6060-7070", manager: "김도윤", status: .completed),
////        CheckInItem(id: "CHK-1025", carNumber: "99추 7070", ownerName: "박유진", carModel: "펠리세이드", requestContent: "운전석 창문 작동 불량", date: "2025-10-02", phoneNumber: "010-8080-9090", manager: nil, status: .checkIn)
//
//    ]
}
