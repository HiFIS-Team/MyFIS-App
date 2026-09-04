import SwiftUI
import UIKit

/// 시뮬레이터 확인용 훅 — **디버그 빌드에서만 동작한다.**
///
/// 시뮬레이터에는 화면을 누를 수단이 없어서, 상태를 환경변수로 재현한다.
/// 이 훅은 **상주시킨다** — 필요할 때마다 넣었다 빼면 그 자체로 시간이 든다 (2026-08-25 교훈).
///
/// ```
/// SIMCTL_CHILD_MYFIS_ROUTE=notifications      잎 화면을 띄운 채로 시작
///   (notifications · store_my · store_cart · weight_log · activity · store_item · branch
///    · water · water_time · group_create)
/// SIMCTL_CHILD_MYFIS_TAB=benefit              그 탭에서 시작 (home · benefit · store · my)
/// SIMCTL_CHILD_MYFIS_TABSET=weight            웨이트 세트에서 시작
/// SIMCTL_CHILD_MYFIS_WEIGHTTAB=cardio         웨이트 세트의 어느 탭에서 시작할지
/// SIMCTL_CHILD_MYFIS_CARDIOTAB=monthly        유산소 미션 갈래 (daily · weekly · monthly)
/// SIMCTL_CHILD_MYFIS_WEIGHT=warmup            웨이트 탭 상태 (warmup 웜업 펼침 · reorder 순서 모드)
/// SIMCTL_CHILD_MYFIS_GROUP_CREATE=filled      모임 개설(G-03)을 채운 채로 (filled · expanded · region)
/// SIMCTL_CHILD_MYFIS_GROUP_AI=on              모임 소개(G-03 2단계)의 AI 도움받기를 켠 채로
/// SIMCTL_CHILD_MYFIS_GROUP_SORT=popular       모임 목록 칩 (popular · rising · thisWeek)
/// SIMCTL_CHILD_MYFIS_HOME_SCROLL=bottom       홈을 아래로 스크롤한 채 시작
/// SIMCTL_CHILD_MYFIS_SEARCH=음료               스토어를 검색 모드로, 이 검색어로 시작
/// SIMCTL_CHILD_MYFIS_AUTOSEARCH=2             2초 뒤 스토어 검색을 스스로 연다 (전환 프레임 확인)
/// SIMCTL_CHILD_MYFIS_MOTION=15                우리 전환을 15배 느리게 (중간 프레임 확인)
/// SIMCTL_CHILD_MYFIS_SLOWMO=0.1               **창** 애니메이션만 0.1배 (잎 밀어넣기 등)
/// SIMCTL_CHILD_MYFIS_AUTOPUSH=notifications   2초 뒤 잎을 스스로 연다
/// SIMCTL_CHILD_MYFIS_AUTOPOP=6                연 뒤 6초 뒤에 되돌아온다
/// SIMCTL_CHILD_MYFIS_ACTIVITY=ladder          활동 랜딩(MYFIS_ROUTE=activity)에 띄울 활동
/// SIMCTL_CHILD_MYFIS_AUTOPLAY=2               2초 뒤 그 활동의 연출을 스스로 재생한다
/// SIMCTL_CHILD_MYFIS_SHEET=expanded           기구 찾기(M-08) 바닥 시트를 펼친 채로 시작
/// ```
enum MyFisDebug {
    private static var env: [String: String] { ProcessInfo.processInfo.environment }

    private static func route(_ name: String?) -> Route? {
        switch name {
        case "notifications": .notifications
        case "store_my": .storeMy
        case "store_cart": .storeCart
        case "weight_log": .weightLog
        case "activity": .activity(activityAction)
        case "store_item": .storeItem(StorePlaceholder.items[0])
        case "branch": .branch
        case "water": .water
        case "water_time": .waterTime
        case "group_create": .groupCreate
        case "group_region": .groupRegion
        case "group_intro": .groupIntro
        default: nil
        }
    }

    /// 시작할 때 이미 열려 있는 잎 화면
    static var initialRoutes: [Route] {
        #if DEBUG
        route(env["MYFIS_ROUTE"]).map { [$0] } ?? []
        #else
        []
        #endif
    }

    /// 시작 탭 — 스토어 잎을 띄우면 뒤에 스토어 탭이 있어야 자연스럽다
    static var initialBaseTab: BaseTab {
        #if DEBUG
        let storeRoute = (env["MYFIS_ROUTE"] ?? "").hasPrefix("store")
        if storeRoute || startsInSearch { return .store }
        switch env["MYFIS_TAB"] {
        case "benefit": return .benefit
        case "store": return .store
        case "my": return .my
        default: return .home
        }
        #else
        .home
        #endif
    }

    /// 웨이트 세트의 시작 탭 — `SIMCTL_CHILD_MYFIS_WEIGHTTAB=cardio`
    static var initialWeightTab: WeightTab {
        #if DEBUG
        switch env["MYFIS_WEIGHTTAB"] {
        case "cardio": .cardio
        case "ranking": .ranking
        case "group": .group
        default: .weight
        }
        #else
        .weight
        #endif
    }

    /// 웨이트 탭(W-01) 상태 — `SIMCTL_CHILD_MYFIS_WEIGHT=warmup` · `=reorder`.
    /// 웜업을 펼친 줄과 순서 모드는 눌러야 나오는데 시뮬레이터에는 누를 수단이 없다
    static var weightWarmupOpen: Bool {
        #if DEBUG
        env["MYFIS_WEIGHT"] == "warmup"
        #else
        false
        #endif
    }

    /// 위와 같은 훅의 다른 값 — 순서 변경 모드로 시작한다
    static var weightReordering: Bool {
        #if DEBUG
        env["MYFIS_WEIGHT"] == "reorder"
        #else
        false
        #endif
    }

    /// 유산소 미션 갈래 — `SIMCTL_CHILD_MYFIS_CARDIOTAB=monthly`.
    /// 갈래 줄을 누를 수단이 없어 주간·월간 칸을 볼 방법이 이것뿐이다
    static var initialCardioTab: CardioMissionTab {
        #if DEBUG
        switch env["MYFIS_CARDIOTAB"] {
        case "weekly": .weekly
        case "monthly": .monthly
        default: .daily
        }
        #else
        .daily
        #endif
    }

    /// 모임 개설(G-03) 을 채운 채로 — `SIMCTL_CHILD_MYFIS_GROUP_CREATE=filled`.
    /// 시뮬레이터에는 **글자를 칠 수단이 없어** 채운 뒤 모습(`모이는 때` 칸 · 활성 버튼)을
    /// 볼 방법이 이것뿐이다. `expanded` 면 갈래 칩까지 펼친다
    static var groupCreateFill: (name: String, category: GroupCategory, expanded: Bool)? {
        #if DEBUG
        switch env["MYFIS_GROUP_CREATE"] {
        case "filled", "region": ("아침 러닝 크루", .running, false)
        case "expanded": ("아침 러닝 크루", .running, true)
        default: nil
        }
        #else
        nil
        #endif
    }

    /// 활동 지역까지 고른 채로 — `SIMCTL_CHILD_MYFIS_GROUP_CREATE=region`.
    /// 범위 슬라이더와 미리보기 판은 지역을 골라야 뜬다
    static var groupCreateRegion: String? {
        #if DEBUG
        env["MYFIS_GROUP_CREATE"] == "region" ? "치평동" : nil
        #else
        nil
        #endif
    }

    /// 모임 소개(§6.32) 의 AI 도움받기를 켠 채로 — `SIMCTL_CHILD_MYFIS_GROUP_AI=on`.
    /// 시뮬레이터에서 스위치를 못 눌러 켠 모습(스켈레톤)을 볼 방법이 이것뿐이다
    static var groupIntroAI: Bool {
        #if DEBUG
        env["MYFIS_GROUP_AI"] == "on"
        #else
        false
        #endif
    }

    /// 모임 목록 칩 — `SIMCTL_CHILD_MYFIS_GROUP_SORT=popular`.
    /// 칩을 누를 수단이 없어 `인기`·`요즘 뜨는` 목록을 볼 방법이 이것뿐이다
    static var initialGroupSort: GroupSort {
        #if DEBUG
        switch env["MYFIS_GROUP_SORT"] {
        case "popular": .popular
        case "rising": .rising
        case "thisWeek": .thisWeek
        default: .none
        }
        #else
        .none
        #endif
    }

    static var initialTabSet: TabSet {
        #if DEBUG
        env["MYFIS_TABSET"] == "weight" ? .weight : .base
        #else
        .base
        #endif
    }

    /// 기구 찾기(M-08) 바닥 시트를 펼친 채로 — `SIMCTL_CHILD_MYFIS_SHEET=expanded`.
    /// 시뮬레이터에서는 끌 수단이 없어 펼친 모습을 볼 방법이 이것뿐이다
    static var sheetExpanded: Bool {
        #if DEBUG
        env["MYFIS_SHEET"] == "expanded"
        #else
        false
        #endif
    }

    /// 홈처럼 긴 화면의 아래쪽을 보려면 `SIMCTL_CHILD_MYFIS_HOME_SCROLL=bottom`
    static var homeScrollAnchor: UnitPoint {
        #if DEBUG
        env["MYFIS_HOME_SCROLL"] == "bottom" ? .bottom : .top
        #else
        .top
        #endif
    }

    /// 랜딩에 띄울 활동 — `SIMCTL_CHILD_MYFIS_ACTIVITY=ladder` (기본은 뽑기)
    private static var activityAction: BenefitAction {
        // 아이콘 이름이 아니라 **갈래 이름**으로 찾는다 — 행 아이콘은 원색 벌로 갈릴 수 있다
        let name = env["MYFIS_ACTIVITY"] ?? "luck"
        return BenefitPlaceholder.actions.first { "\($0.kind)" == name }
            ?? BenefitPlaceholder.actions[6]
    }

    /// 시뮬레이터에는 버튼을 누를 수단이 없다. 연출을 보려면 `SIMCTL_CHILD_MYFIS_AUTOPLAY=2`
    static func scheduleAutoPlay(_ play: @escaping () -> Void) {
        #if DEBUG
        guard let delay = env["MYFIS_AUTOPLAY"].flatMap(Double.init) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: play)
        #endif
    }

    /// 검색 모드로 시작할지 — 검색은 잎이 아니라 **스토어의 모드**라 라우트가 아니다 (§6.9)
    static var startsInSearch: Bool {
        #if DEBUG
        env["MYFIS_SEARCH"] != nil
        #else
        false
        #endif
    }

    /// 시뮬레이터에는 키보드를 칠 수단이 없다. 검색 결과를 보려면
    /// `SIMCTL_CHILD_MYFIS_SEARCH=음료` (스토어 탭이 검색 모드로 열린다)
    static var initialSearchQuery: String {
        #if DEBUG
        env["MYFIS_SEARCH"] ?? ""
        #else
        ""
        #endif
    }

    /// 스스로 검색을 연다 — `SIMCTL_CHILD_MYFIS_AUTOSEARCH=2`.
    /// 시뮬레이터에는 아이콘을 누를 수단이 없어 **들어오는 중간 프레임**을 볼 방법이 이것뿐이다.
    /// `MYFIS_SLOWMO` 와 같이 쓴다
    static func scheduleAutoSearch(_ open: @escaping () -> Void) {
        #if DEBUG
        guard let delay = env["MYFIS_AUTOSEARCH"].flatMap(Double.init) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: open)
        #endif
    }

    /// 창 전체 애니메이션을 늦춘다. 전환 중간을 스크린샷으로 봐야 할 때만 쓴다.
    ///
    /// ⚠️ **`withAnimation` 은 안 늦는다** (2026-09-04 확인) — `layer.speed` 는 CoreAnimation 만 탄다.
    /// 우리가 건 전환을 늦추려면 `MYFIS_MOTION`(§7 `MyFisMotion.scale`) 을 쓴다
    static func applySlowMotionIfNeeded() {
        #if DEBUG
        guard let value = env["MYFIS_SLOWMO"], let speed = Float(value) else { return }
        for scene in UIApplication.shared.connectedScenes {
            guard let scene = scene as? UIWindowScene else { continue }
            for window in scene.windows { window.layer.speed = speed }
        }
        #endif
    }

    /// 스스로 잎을 열고 되돌아온다.
    ///
    /// `Task` 가 아니라 `DispatchQueue` 로 건다 — 잎이 셸을 덮으면 `.task` 는 취소된다 (확인함).
    static func scheduleAutoNavigation(
        open: @escaping (Route) -> Void,
        back: @escaping () -> Void
    ) {
        #if DEBUG
        guard let route = route(env["MYFIS_AUTOPUSH"]) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { open(route) }
        if let pop = Double(env["MYFIS_AUTOPOP"] ?? "0"), pop > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2 + pop) { back() }
        }
        #endif
    }
}
