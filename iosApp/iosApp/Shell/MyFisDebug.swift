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
/// SIMCTL_CHILD_MYFIS_WEIGHT=warmup            웨이트 탭 상태 (week 요일 띠 · warmup 웜업 펼침 · reorder 순서 모드 · picker 고르는 목록)
/// SIMCTL_CHILD_MYFIS_GROUP_CREATE=filled      모임 개설(G-03)을 채운 채로 (filled · expanded · region)
/// SIMCTL_CHILD_MYFIS_GROUP_AI=on              모임 소개(G-03 2단계)의 AI 도움받기를 켠 채로
/// SIMCTL_CHILD_MYFIS_GROUP_SORT=popular       모임 목록 칩 (popular · rising · thisWeek · order 차례 목록 펼침)
/// SIMCTL_CHILD_MYFIS_HOME_SCROLL=bottom       홈을 아래로 스크롤한 채 시작
/// SIMCTL_CHILD_MYFIS_STORE_CATEGORY=drink     스토어를 이 갈래로 시작 (all · drink · caffeine · protein · goods)
/// SIMCTL_CHILD_MYFIS_SEARCH=음료               상품 검색 잎(MYFIS_ROUTE=store_search)을 이 검색어로 시작
/// SIMCTL_CHILD_MYFIS_GROUP_SEARCH=러닝        모임 검색 잎(MYFIS_ROUTE=group_search)을 이 검색어로 시작
/// SIMCTL_CHILD_MYFIS_RECENTS=음료,타월          최근 검색을 이 목록으로 채운 채 시작
/// SIMCTL_CHILD_MYFIS_TOAST=모임을 만들었어요   토스트를 띄운 채로 시작 (MYFIS_MOTION 으로 늘려서 본다)
/// SIMCTL_CHILD_MYFIS_MOTION=15                우리 전환을 15배 느리게 (중간 프레임 확인)
/// SIMCTL_CHILD_MYFIS_SLOWMO=0.1               **창** 애니메이션만 0.1배 (잎 밀어넣기 등)
/// SIMCTL_CHILD_MYFIS_AUTOPUSH=notifications   2초 뒤 잎을 스스로 연다
/// SIMCTL_CHILD_MYFIS_AUTOPOP=6                연 뒤 6초 뒤에 되돌아온다
/// SIMCTL_CHILD_MYFIS_ACTIVITY=ladder          활동 랜딩(MYFIS_ROUTE=activity)에 띄울 활동
/// SIMCTL_CHILD_MYFIS_AUTOPLAY=2               2초 뒤 그 활동의 연출을 스스로 재생한다
/// SIMCTL_CHILD_MYFIS_SHEET=expanded           기구 찾기(M-08) 바닥 시트를 펼친 채로 시작
/// SIMCTL_CHILD_MYFIS_AUTOTAB=store            2초 뒤 이 탭으로 옮긴다 (benefit · store · my) — 헤더와 본문이 같이 바뀌는지 찍는다
/// ```
enum MyFisDebug {
    private static var env: [String: String] { ProcessInfo.processInfo.environment }

    private static func route(_ name: String?) -> Route? {
        switch name {
        case "notifications": .notifications
        case "store_my": .storeMy
        case "store_cart": .storeCart
        case "store_search": .storeSearch
        case "group_search": .groupSearch
        case "weight_log": .weightLog
        case "workout_detail": .workoutDetail(RoutinePlaceholder.exercises[0])
        case "workout_session": .workoutSession
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
        if storeRoute { return .store }
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

    /// 위와 같은 훅의 다른 값 — 요일 띠를 펼친 채로 시작한다
    static var weightWeekOpen: Bool {
        #if DEBUG
        env["MYFIS_WEIGHT"] == "week"
        #else
        false
        #endif
    }

    /// 위와 같은 훅의 다른 값 — `운동 시간` 고르는 목록을 연 채로 시작한다
    static var weightPickerOpen: Bool {
        #if DEBUG
        env["MYFIS_WEIGHT"] == "picker"
        #else
        false
        #endif
    }

    /// 모임 목록의 **차례 고르는 목록**을 연 채로 시작한다 — `SIMCTL_CHILD_MYFIS_GROUP_SORT=order`
    static var groupOrderOpen: Bool {
        #if DEBUG
        env["MYFIS_GROUP_SORT"] == "order"
        #else
        false
        #endif
    }

    /// 웨이트 탭(W-01) 상태 — `SIMCTL_CHILD_MYFIS_WEIGHT=week` · `=warmup` · `=reorder`.
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

    /// 홈처럼 긴 화면의 아래쪽을 보려면 `SIMCTL_CHILD_MYFIS_HOME_SCROLL=bottom` (가운데는 `center`)
    static var homeScrollAnchor: UnitPoint {
        #if DEBUG
        switch env["MYFIS_HOME_SCROLL"] {
        case "bottom": .bottom
        case "center": .center
        default: .top
        }
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

    /// 스토어 시작 갈래 — `SIMCTL_CHILD_MYFIS_STORE_CATEGORY=drink`.
    /// 시뮬레이터에는 칩을 누를 수단이 없어 **고른 상태**를 볼 방법이 이것뿐이다
    static var initialStoreCategory: StoreCategory {
        #if DEBUG
        StoreCategory(rawValue: env["MYFIS_STORE_CATEGORY"] ?? "") ?? .all
        #else
        .all
        #endif
    }

    /// 시뮬레이터에는 키보드를 칠 수단이 없다 — 검색 잎을 이 검색어로 열어 준다.
    /// `SIMCTL_CHILD_MYFIS_ROUTE=store_search MYFIS_SEARCH=음료` (비우면 최근/추천)
    static var searchQuery: String {
        #if DEBUG
        env["MYFIS_SEARCH"] ?? ""
        #else
        ""
        #endif
    }

    /// 최근 검색을 채운 채 시작한다 — `SIMCTL_CHILD_MYFIS_RECENTS=음료,타월`.
    /// 시뮬레이터에는 검색어를 칠 수단이 없어 **최근 검색 모양**을 볼 방법이 이것뿐이다
    static var initialRecents: [String] {
        #if DEBUG
        (env["MYFIS_RECENTS"] ?? "").split(separator: ",").map(String.init)
        #else
        []
        #endif
    }

    /// `SIMCTL_CHILD_MYFIS_ROUTE=group_search MYFIS_GROUP_SEARCH=러닝`
    /// 머리 오른쪽 끝 버튼을 **진짜로 누른다** — `MYFIS_NAV_TAP=2,5` (초). 시스템 검색 버튼 · 닫기가 코드로 켤 때와 같은지 본다
    static func scheduleNavTap() {
        #if DEBUG
        guard let value = env["MYFIS_NAV_TAP"] else { return }
        for seconds in value.split(separator: ",").compactMap({ Double($0) }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { tapNavTrailing() }
        }
        #endif
    }

    #if DEBUG
    private static func tapNavTrailing() {
        guard let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows).first(where: \.isKeyWindow) else { return }
        var controls: [UIControl] = []
        func walk(_ view: UIView) {
            if let control = view as? UIControl, !control.isHidden, control.alpha > 0.01 {
                let frame = control.convert(control.bounds, to: window)
                if frame.minY < 130, frame.width < 120, frame.width > 10 { controls.append(control) }
            }
            view.subviews.forEach(walk)
        }
        walk(window)
        let sorted = controls.sorted { $0.convert($0.bounds, to: window).maxX < $1.convert($1.bounds, to: window).maxX }
        let summary = sorted.map { "\(type(of: $0))[\($0.accessibilityLabel ?? "-")]@\(Int($0.convert($0.bounds, to: window).midX))" }
        fputs("[navtap] 컨트롤 \(summary)\n", stderr)
        guard let target = sorted.last else { return }
        target.sendActions(for: .primaryActionTriggered)
        target.sendActions(for: .touchUpInside)
    }
    #endif

    /// 모임 머리 검색을 2초 뒤 켜고, 초를 주면 그만큼 뒤 끈다 — `MYFIS_GROUP_SEARCH_AUTO=5`
    static func scheduleGroupSearch(open: @escaping () -> Void, cancel: @escaping () -> Void) {
        #if DEBUG
        guard let value = env["MYFIS_GROUP_SEARCH_AUTO"] else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: open)
        if let seconds = Double(value), seconds > 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: cancel)
        }
        #endif
    }

    /// 스토어 머리 검색을 **켠 채로** 띄운다 — `MYFIS_STORE_SEARCH=1` (2026-09-15). 검색어는 `MYFIS_SEARCH`
    static var storeSearchOpen: Bool {
        #if DEBUG
        env["MYFIS_STORE_SEARCH"] == "1"
        #else
        false
        #endif
    }

    /// 스토어 머리 검색을 2초 뒤 켜고, 초를 주면 그만큼 뒤 `취소` 한다 — `MYFIS_STORE_SEARCH_AUTO=4.5`.
    /// 켜고 끄는 전환(오른쪽 알약이 `취소` 로 녹아 바뀌는 것)을 녹화하려고 둔다. 누르는 것과 같은 선택값을 바꾼다
    static func scheduleStoreSearch(open: @escaping () -> Void, cancel: @escaping () -> Void) {
        #if DEBUG
        guard let value = env["MYFIS_STORE_SEARCH_AUTO"] else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: open)
        if let seconds = Double(value), seconds > 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: cancel)
        }
        #endif
    }

    /// 모임 머리 검색을 **이 검색어로** 켠다 — `MYFIS_GROUP_SEARCH_AUTO` 와 같이 줄 때만 (`MYFIS_GROUP_SEARCH=러닝`)
    static var groupHeaderQuery: String {
        #if DEBUG
        env["MYFIS_GROUP_SEARCH_AUTO"] == nil ? "" : groupSearchQuery
        #else
        ""
        #endif
    }

    static var groupSearchQuery: String {
        #if DEBUG
        env["MYFIS_GROUP_SEARCH"] ?? ""
        #else
        ""
        #endif
    }

    /// 토스트를 띄운 채로 시작한다 — `SIMCTL_CHILD_MYFIS_TOAST=모임을 만들었어요`.
    /// 시뮬레이터에는 버튼을 누를 수단이 없어 **뜬 모습**을 볼 방법이 이것뿐이다.
    /// 머무는 시간도 `MYFIS_MOTION` 배율을 타므로 같이 쓰면 넉넉히 찍을 수 있다
    static var initialToast: String? {
        #if DEBUG
        env["MYFIS_TOAST"]
        #else
        nil
        #endif
    }

    /// 토스트 종류 — `SIMCTL_CHILD_MYFIS_TOAST_KIND=warn` (done · warn · fail · info)
    static var initialToastKind: ToastKind {
        #if DEBUG
        switch env["MYFIS_TOAST_KIND"] {
        case "warn": .warn
        case "fail": .fail
        case "info": .info
        default: .done
        }
        #else
        .done
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

    /// 2초 뒤 기본 세트의 이 탭으로 옮긴다 — `SIMCTL_CHILD_MYFIS_AUTOTAB=store`.
    /// 시뮬레이터에서 탭을 누를 수단이 없어, 탭을 옮길 때 **헤더와 본문이 같이 바뀌는지** 찍으려고 둔다 (2026-09-15)
    /// 쉼표로 여러 개를 주면 1.5초 간격으로 차례로 옮긴다 — `store,home,store` (처음 여는 탭과 다시 여는 탭을 같이 본다)
    static func scheduleAutoTab(select: @escaping (BaseTab) -> Void) {
        #if DEBUG
        guard let value = env["MYFIS_AUTOTAB"] else { return }
        let tabs: [BaseTab] = value.split(separator: ",").compactMap {
            switch $0 {
            case "home": .home
            case "benefit": .benefit
            case "store": .store
            case "my": .my
            default: nil
            }
        }
        for (index, tab) in tabs.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2 + 1.5 * Double(index)) { select(tab) }
        }
        #endif
    }

    /// 2초 뒤부터 1.5초 간격으로 **탭 자리(0~4)를 누른 것처럼** 선택값을 바꾼다 — `SIMCTL_CHILD_MYFIS_AUTOSLOT=3,0,3`.
    /// `AUTOTAB` 과 달리 탭 바를 누를 때와 **같은 선택 바인딩**을 거친다 — 웨이트(3) · 이전(0)으로 세트가 바뀌는 것까지 본다 (2026-09-15)
    static func scheduleAutoSlot(select: @escaping (Int) -> Void) {
        #if DEBUG
        guard let value = env["MYFIS_AUTOSLOT"] else { return }
        let slots = value.split(separator: ",").compactMap { Int($0) }
        for (index, slot) in slots.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2 + 1.5 * Double(index)) { select(slot) }
        }
        #endif
    }

    /// 2초 뒤부터 1.5초 간격으로 **탭 바 버튼을 진짜로 누른다** — `SIMCTL_CHILD_MYFIS_AUTOTAP=1,0,3,0` (왼쪽부터 자리).
    /// `AUTOSLOT` 은 선택 바인딩만 바꿔 **UIKit 이 탭을 받는 길을 건너뛴다** — 누르면 UIKit 이 먼저 그 칸으로 옮기고
    /// SwiftUI 가 다른 칸으로 되돌리는지 봐야 해서 둔다 (2026-09-15). 손쓰기(VoiceOver)가 누르는 길 — `accessibilityActivate`.
    /// 이름이 아니라 **자리**로 찾는다 — 탭 바 버튼의 손쓰기 라벨이 비어 있다
    static func scheduleAutoTap() {
        #if DEBUG
        guard let value = env["MYFIS_AUTOTAP"] else { return }
        let slots = value.split(separator: ",").compactMap { Int($0) }
        for (index, slot) in slots.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2 + 1.5 * Double(index)) { tapTab(slot) }
        }
        #endif
    }

    #if DEBUG
    private static func tapTab(_ slot: Int) {
        guard let tabs = firstTabBarController() else {
            fputs("[tap] 탭 바 컨트롤러 없음\n", stderr)
            return
        }
        var found: [NSObject] = []
        collectElements(in: tabs.tabBar, into: &found)
        // 같은 버튼이 겹겹이 잡힌다 — 가운데 x 가 같으면 하나로 본다
        var buttons: [NSObject] = []
        for element in found.sorted(by: { $0.accessibilityFrame.midX < $1.accessibilityFrame.midX }) {
            if let last = buttons.last, abs(last.accessibilityFrame.midX - element.accessibilityFrame.midX) < 8 { continue }
            buttons.append(element)
        }
        let summary = buttons.map { "\($0.accessibilityLabel ?? "라벨없음")@\(Int($0.accessibilityFrame.midX))" }
        guard buttons.indices.contains(slot) else {
            fputs("[tap] \(slot) 없음 — 요소 \(summary)\n", stderr)
            return
        }
        let button = buttons[slot]
        let before = tabs.selectedIndex
        // 손쓰기 누르기는 VoiceOver 가 꺼져 있으면 `false` 로 끝났다 — 컨트롤이면 손을 뗄 때 보내는 동작을 직접 보낸다.
        // ⚠️ **한 번만** 보낸다 — 두 번 보내면 세트가 바뀐 뒤 같은 자리의 다른 탭(웨이트 → 모임)이 또 눌린다 (확인함)
        var chain: [String] = []
        var cls: AnyClass? = type(of: button)
        while let c = cls { chain.append(NSStringFromClass(c)); cls = class_getSuperclass(c) }
        let events: String
        if let control = button as? UIControl {
            events = "\(control.allControlEvents.rawValue)"
            control.sendActions(for: .primaryActionTriggered)
        } else {
            events = "컨트롤 아님 activate=\(button.accessibilityActivate())"
        }
        fputs("[tap] \(slot) → \(chain.prefix(4)) 이벤트 \(events) 선택 \(before)→\(tabs.selectedIndex)\n", stderr)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            fputs("[tap] \(slot) 0.05초 뒤 선택 \(tabs.selectedIndex)\n", stderr)
        }
        // 손쓰기 라벨 — 세트가 바뀐 뒤 이름이 따라왔는지 (VoiceOver 가 읽는 값)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var after: [NSObject] = []
            collectElements(in: tabs.tabBar, into: &after)
            let labels = after.sorted { $0.accessibilityFrame.midX < $1.accessibilityFrame.midX }
                .map { $0.accessibilityLabel ?? "라벨없음" }
            fputs("[tap] \(slot) 0.5초 뒤 라벨 \(labels)\n", stderr)
        }
    }

    /// 손쓰기 요소 중 **탭 바 폭보다 좁은 것** — 바 전체·배경을 뺀 버튼들
    private static func collectElements(in object: NSObject, into found: inout [NSObject]) {
        if object.isAccessibilityElement, object.accessibilityFrame.width > 0,
           object.accessibilityFrame.width < 200 {
            found.append(object)
        }
        let children: [NSObject] = ((object as? UIView)?.subviews ?? []) + ((object.accessibilityElements as? [NSObject]) ?? [])
        for child in children { collectElements(in: child, into: &found) }
    }

    private static func firstTabBarController() -> UITabBarController? {
        func search(_ controller: UIViewController?) -> UITabBarController? {
            guard let controller else { return nil }
            if let tabs = controller as? UITabBarController { return tabs }
            return controller.children.lazy.compactMap(search).first
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .lazy.compactMap { search($0.rootViewController) }.first
    }
    #endif

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
        // 진단 — 잎이 들어간 뒤 뷰 컨트롤러 나무 (`MYFIS_VCDUMP=1`)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { UINavigationController.myFisDumpControllers() }
        if let pop = Double(env["MYFIS_AUTOPOP"] ?? "0"), pop > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2 + pop) { back() }
        }
        #endif
    }
}
