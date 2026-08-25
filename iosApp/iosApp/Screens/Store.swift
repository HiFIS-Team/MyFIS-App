import Foundation

/// 스토어 자리값 데이터. SPEC.md §5 S-01.
///
/// TODO(서버): 상품·마일리지 API 가 아직 없다. 화면을 먼저 세우려고 자리값을 둔다.
/// 붙으면 이 파일의 `placeholder` 만 지우면 된다.
enum StoreCategory: String, CaseIterable, Identifiable {
    case all, drink, caffeine, protein, goods

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "전체"
        case .drink: "음료수"
        case .caffeine: "카페인"
        case .protein: "프로틴"
        case .goods: "굿즈"
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
/// TODO: 스토어에 잠깐 뒀다가 뺐다 (자리를 필터에 내줬다). **혜택 탭 P-04 미니 이벤트 허브**가 쓸 자리다.
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
    /// 이 상품을 본 사람 수
    let views: Int
    let rating: Double
    let reviewCount: Int
    var soldOut: Bool = false
}

/// 리뷰 한 건. SPEC.md §5 S-02.
///
/// TODO(서버): 리뷰 API 가 붙으면 지운다.
struct StoreReview: Identifiable, Hashable {
    let id: Int
    let author: String
    let date: String
    let rating: Int
    let body: String
    let helpful: Int
}

enum StorePlaceholder {
    /// TODO(서버): 리뷰 API 가 붙으면 지운다
    static let reviews: [StoreReview] = [
        .init(id: 1, author: "김*훈", date: "8월 20일", rating: 5,
              body: "운동 끝나고 바로 마시기 딱 좋아요. 데스크에서 받는 것도 금방이고요", helpful: 3),
        .init(id: 2, author: "이*연", date: "8월 17일", rating: 4,
              body: "가볍게 마시기 좋은데 차가운 게 남아 있을 때가 더 좋아요", helpful: 1),
        .init(id: 3, author: "박*수", date: "8월 11일", rating: 5,
              body: "마일리지로 바꾸니까 운동 가는 맛이 있네요", helpful: 7),
    ]

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
        .init(id: 1, name: "이온음료 500ml", price: 300, category: .drink,
              views: 12_400, rating: 4.6, reviewCount: 218),
        .init(id: 2, name: "제로 콜라 250ml", price: 250, category: .drink,
              views: 8_300, rating: 4.4, reviewCount: 96),
        .init(id: 3, name: "아메리카노", price: 400, category: .caffeine,
              views: 23_100, rating: 4.8, reviewCount: 512),
        .init(id: 4, name: "콜드브루", price: 500, category: .caffeine,
              views: 6_400, rating: 4.7, reviewCount: 143),
        .init(id: 5, name: "프로틴 쉐이크", price: 600, category: .protein,
              views: 31_000, rating: 4.5, reviewCount: 874),
        .init(id: 6, name: "단백질 바", price: 700, category: .protein,
              views: 15_200, rating: 4.3, reviewCount: 331),
        .init(id: 7, name: "MyFIS 스포츠 타월", price: 1_200, category: .goods,
              views: 4_100, rating: 4.9, reviewCount: 64),
        .init(id: 8, name: "쉐이커 보틀", price: 1_500, category: .goods,
              views: 9_800, rating: 4.6, reviewCount: 205),
        .init(id: 9, name: "헬스 장갑", price: 2_400, category: .goods,
              views: 2_700, rating: 4.2, reviewCount: 38, soldOut: true),
        .init(id: 10, name: "요가 매트", price: 5_000, category: .goods,
              views: 5_600, rating: 4.7, reviewCount: 121),
    ]
}

extension Int {
    /// `1,240 P`
    var mileage: String { decimal + " P" }

    /// `1.2만 명` · `724 명` — 만 단위부터는 자릿수를 줄인다. 정확한 수보다 "많다"가 읽히면 된다
    var viewCount: String {
        guard self >= 10_000 else { return decimal + " 명" }
        let man = String(format: "%.1f", Double(self) / 10_000)
        return (man.hasSuffix(".0") ? String(man.dropLast(2)) : man) + "만 명"
    }

    var decimal: String {
        let n = NumberFormatter()
        n.numberStyle = .decimal
        return n.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
