import Foundation

/// 스토어 자리값 데이터. SPEC.md §5 S-01.
///
/// TODO(서버): 상품·마일리지 API 가 아직 없다. 화면을 먼저 세우려고 자리값을 둔다.
/// 붙으면 이 파일의 `placeholder` 만 지우면 된다.
enum StoreCategory: String, CaseIterable, Identifiable {
    case all, goods, drink

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "전체"
        case .goods: "굿즈"
        case .drink: "음료"
        }
    }
}

/// 상단 배너 한 장
struct StoreBanner: Identifiable, Hashable {
    let id: Int
    let title: String
    let body: String
    let icon: String
}

/// 마일리지를 모으는 길 하나. SPEC.md §5 P-03 ~ P-10 과 1:1 이다.
///
/// **스토어에 두는 이유** — 살 수 없는 걸 봤을 때 바로 모으러 갈 수 있어야 한다.
/// S-01 규칙 "부족한 상품도 가리지 않는다. 목표가 되어야 한다" 의 짝이다.
struct StoreQuest: Identifiable, Hashable {
    let id: Int
    let label: String
    let icon: String
    let reward: Int
    /// TODO: 해당 화면이 붙으면 연결한다
    let destination: String
}

/// 교환 상품 하나
struct StoreItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let price: Int
    let category: StoreCategory
    var soldOut: Bool = false
}

enum StorePlaceholder {
    /// TODO(서버): `MileageAccount.balance`
    static let balance = 1_240

    static let banners: [StoreBanner] = [
        .init(id: 1, title: "쌓인 마일리지로\n한 잔 바꾸기", body: "아메리카노 400 P 부터", icon: "ic_tab_store"),
        .init(id: 2, title: "이번 주 새 굿즈\n스포츠 타월", body: "1,200 P · 지점 수령", icon: "ic_tab_benefit"),
        .init(id: 3, title: "출석 5일 채우면\n보너스 500 P", body: "이번 주 3일 남았어요", icon: "ic_quest_attend"),
    ]

    static let quests: [StoreQuest] = [
        .init(id: 1, label: "출석 체크", icon: "ic_quest_attend", reward: 50, destination: "P-03"),
        .init(id: 2, label: "출석판", icon: "ic_quest_board", reward: 10, destination: "P-05"),
        .init(id: 3, label: "카드긁기", icon: "ic_header_membership", reward: 30, destination: "P-06"),
        .init(id: 4, label: "스트레칭", icon: "ic_tab_cardio", reward: 20, destination: "P-09"),
        .init(id: 5, label: "체중 기록", icon: "ic_quest_scale", reward: 10, destination: "P-08"),
        .init(id: 6, label: "인스타 인증", icon: "ic_quest_camera", reward: 100, destination: "P-10"),
    ]

    static let items: [StoreItem] = [
        .init(id: 1, name: "이온음료 500ml", price: 300, category: .drink),
        .init(id: 2, name: "아메리카노", price: 400, category: .drink),
        .init(id: 3, name: "프로틴 쉐이크", price: 600, category: .drink),
        .init(id: 4, name: "MyFIS 스포츠 타월", price: 1_200, category: .goods),
        .init(id: 5, name: "쉐이커 보틀", price: 1_500, category: .goods),
        .init(id: 6, name: "헬스 장갑", price: 2_400, category: .goods, soldOut: true),
        .init(id: 7, name: "요가 매트", price: 5_000, category: .goods),
        .init(id: 8, name: "단백질 바", price: 700, category: .drink),
    ]
}

extension Int {
    /// `1,240 P`
    var mileage: String {
        let n = NumberFormatter()
        n.numberStyle = .decimal
        return (n.string(from: NSNumber(value: self)) ?? "\(self)") + " P"
    }
}
