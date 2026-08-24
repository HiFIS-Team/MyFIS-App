import SwiftUI

/// SPEC.md §3 탭 구조.
///
/// 웨이트 탭을 누르면 하단 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
/// 되돌리지 말 것 — 운동 중에는 스토어·마이가 방해된다는 판단이다.
enum TabSet {
    case base, weight
}

/// 탭 아이콘은 **두 벌**이다 — 비선택 아웃라인, 선택 채움 (DESIGN.md §6.7).
///
/// 선택을 색이 아니라 **채움**으로 알리므로 SF Symbols 를 쓰지 못한다.
/// `sparkles` · `figure.run` 에는 `.fill` 벌이 아예 없어서 그 두 자리만 안 차고,
/// 한 바 안에서 채움/아웃라인이 섞이면 톤이 어긋난다.
/// 그래서 하단 탭만은 **양 플랫폼이 같은 우리 벡터**를 쓴다 (Android `res/drawable` 과 같은 pathData).
protocol MyFisTab: Hashable, CaseIterable {
    var label: String { get }
    /// 비선택 — 아웃라인 1.5
    var icon: String { get }
    /// 선택 — 같은 실루엣의 안쪽이 찬 벌
    var iconFilled: String { get }
}

extension MyFisTab {
    /// 채움 벌 이름은 아웃라인 + `_fill` 로 맞춘다.
    var iconFilled: String { icon + "_fill" }
}

/// 기본 세트: 홈 / 혜택 / 스토어 / 웨이트 / 마이
enum BaseTab: MyFisTab {
    case home, benefit, store, weight, my

    var label: String {
        switch self {
        case .home: "홈"
        case .benefit: "혜택"
        case .store: "스토어"
        case .weight: "웨이트"
        case .my: "마이"
        }
    }

    var icon: String {
        switch self {
        case .home: "ic_tab_home"
        case .benefit: "ic_tab_benefit"
        case .store: "ic_tab_store"
        case .weight: "ic_tab_weight"
        case .my: "ic_tab_my"
        }
    }
}

/// 웨이트 세트: 이전 / 웨이트 / 유산소 / 랭킹 / 모임
enum WeightTab: MyFisTab {
    case back, weight, cardio, ranking, group

    var label: String {
        switch self {
        case .back: "이전"
        case .weight: "웨이트"
        case .cardio: "유산소"
        case .ranking: "랭킹"
        case .group: "모임"
        }
    }

    var icon: String {
        switch self {
        case .back: "ic_tab_back"
        case .weight: "ic_tab_weight"
        case .cardio: "ic_tab_cardio"
        case .ranking: "ic_tab_ranking"
        case .group: "ic_tab_group"
        }
    }

    /// `이전` 은 선택되는 자리가 아니라 채움 벌이 없다.
    var iconFilled: String { self == .back ? icon : icon + "_fill" }
}
