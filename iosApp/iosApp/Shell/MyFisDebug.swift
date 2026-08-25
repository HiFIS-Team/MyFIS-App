import SwiftUI
import UIKit

/// 시뮬레이터 확인용 훅 — **디버그 빌드에서만 동작한다.**
///
/// 시뮬레이터에는 화면을 누를 수단이 없어서, 상태를 환경변수로 재현한다.
/// 이 훅은 **상주시킨다** — 필요할 때마다 넣었다 빼면 그 자체로 시간이 든다 (2026-08-25 교훈).
///
/// ```
/// SIMCTL_CHILD_MYFIS_ROUTE=notifications      잎 화면을 띄운 채로 시작
/// SIMCTL_CHILD_MYFIS_TAB=store                스토어 탭에서 시작
/// SIMCTL_CHILD_MYFIS_TABSET=weight            웨이트 세트에서 시작
/// SIMCTL_CHILD_MYFIS_HOME_SCROLL=bottom       홈을 아래로 스크롤한 채 시작
/// SIMCTL_CHILD_MYFIS_SLOWMO=0.1               창 애니메이션을 0.1배로 (전환 프레임 확인)
/// SIMCTL_CHILD_MYFIS_AUTOPUSH=notifications   2초 뒤 잎을 스스로 연다
/// SIMCTL_CHILD_MYFIS_AUTOPOP=6                연 뒤 6초 뒤에 되돌아온다
/// ```
enum MyFisDebug {
    private static var env: [String: String] { ProcessInfo.processInfo.environment }

    private static func route(_ name: String?) -> Route? {
        switch name {
        case "notifications": .notifications
        case "store_my": .storeMy
        case "store_cart": .storeCart
        case "store_search": .storeSearch
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
        return env["MYFIS_TAB"] == "store" || storeRoute ? .store : .home
        #else
        .home
        #endif
    }

    static var initialTabSet: TabSet {
        #if DEBUG
        env["MYFIS_TABSET"] == "weight" ? .weight : .base
        #else
        .base
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

    /// 창 전체 애니메이션을 늦춘다. 전환 중간을 스크린샷으로 봐야 할 때만 쓴다.
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
