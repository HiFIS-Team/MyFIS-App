import SwiftUI

/// SPEC.md §3 탭 구조.
///
/// 웨이트 탭을 누르면 하단 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
/// 되돌리자고 하지 말 것 — 운동 중에는 스토어·마이가 방해된다는 판단이다.
enum TabSet {
    case base, weight
}

protocol MyFisTab: Hashable, CaseIterable {
    var label: String { get }
    var symbol: String { get }
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

    var symbol: String {
        switch self {
        case .home: "house"
        case .benefit: "gift"
        case .store: "bag"
        case .weight: "dumbbell"
        case .my: "person"
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

    var symbol: String {
        switch self {
        case .back: "chevron.left"
        case .weight: "dumbbell"
        case .cardio: "waveform.path.ecg"
        case .ranking: "trophy"
        case .group: "person.2"
        }
    }
}
