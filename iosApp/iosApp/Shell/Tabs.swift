import SwiftUI

/// SPEC.md §3 탭 구조.
///
/// 웨이트 탭을 누르면 하단 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
/// 되돌리자고 하지 말 것 — 운동 중에는 스토어·마이가 방해된다는 판단이다.
enum TabSet {
    case base, weight
}

/// 탭 아이콘 출처.
///
/// 기본은 SF Symbols. SF Symbols 에 원하는 모양이 없을 때만 우리 벡터를 쓴다.
/// **섞을 때는 채움/아웃라인 톤을 맞춰야 한다** (DESIGN.md §6.7).
enum TabIcon {
    case system(String)
    case asset(String)
}

protocol MyFisTab: Hashable, CaseIterable {
    var label: String { get }
    var icon: TabIcon { get }
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

    var icon: TabIcon {
        switch self {
        // SF Symbols 의 house.fill 은 지붕이 뾰족하고 처마가 튀어나오고 문이 네모다.
        // 우리가 원하는 건 둥근 지붕 + 아치 문이라 직접 그렸다.
        case .home: .asset("ic_tab_home")
        case .benefit: .system("sparkles")
        case .store: .system("takeoutbag.and.cup.and.straw")
        case .weight: .system("dumbbell")
        case .my: .system("person")
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

    var icon: TabIcon {
        switch self {
        case .back: .system("chevron.left")
        case .weight: .system("dumbbell")
        case .cardio: .system("figure.run")
        case .ranking: .system("trophy")
        case .group: .system("person.2")
        }
    }
}
