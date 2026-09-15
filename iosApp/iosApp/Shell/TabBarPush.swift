import UIKit

/// 잎이 들어오고 나갈 때 하단 탭 바를 **전환 애니메이션에 태워** 숨기고 보인다 (DESIGN §7.1).
///
/// 🟢 (2026-09-15, 사용자 — *"왜 크림처럼 안되는데"*) — 네 번 재고 여기로 왔다
/// 1. SwiftUI `.toolbar(.hidden, for: .tabBar)` — 전환과 **따로** 켜고 꺼서 push 첫 프레임에 툭 사라지고
///    pop 이 끝난 뒤 툭 나타났다 (영상 30fps)
/// 2. 크림 같은 UIKit 앱이 쓰는 `hidesBottomBarWhenPushed` — **안 먹었다.** 내비게이션이 탭 바 컨트롤러 바로 밑에
///    있어야 동작하는데, SwiftUI 는 사이에 `TabHostingController` 를 한 겹 끼운다 (뷰 컨트롤러 나무를 찍어 확인)
/// 3. 내비게이션 push · set · pop 가로채기 — push 만 됐다. **pop 은 그 메서드들을 안 거친다** (로그)
/// 4. `viewWillAppear` 에서 스택 장수로 판단 — pop 도 안 됐다. **SwiftUI 는 뒤로 가는 전환이 끝날 때까지
///    빠지는 화면을 스택에 남겨 둔다** (로그: 시작 2장 → 끝 1장)
///
/// 그래서 **나타나는 화면이 원래 스택에 있던 것(`isMovingToParent == false`)이면 한 장 빠질 것으로 보고** 맞춘다.
/// 전환이 있으면 그 애니메이션에 태우고, 가장자리 쓸기를 **취소하면 되돌리고**, 끝나면 최종 스택으로 한 번 더 맞춘다.
/// 탭 바 컨트롤러 밑 스택이 아니면 아무 일도 하지 않는다
extension UIViewController {
    /// 앱이 뜰 때 한 번 부른다 (`iOSApp.init`)
    static func myFisSyncTabBarWithNavigation() {
        _ = swapOnce
    }

    private static let swapOnce: Void = {
        guard let a = class_getInstanceMethod(UIViewController.self, #selector(viewWillAppear(_:))),
              let b = class_getInstanceMethod(UIViewController.self, #selector(myFis_viewWillAppear(_:))) else { return }
        method_exchangeImplementations(a, b)
    }()

    /// 바꿔 끼웠으므로 `myFis_viewWillAppear` 를 부르면 **원래 구현**이 불린다
    @objc private func myFis_viewWillAppear(_ animated: Bool) {
        myFis_viewWillAppear(animated)
        (self as? UITabBarController ?? tabBarController)?.myFisGuardPassages()
        guard let navigation = parent as? UINavigationController,
              navigation.viewControllers.contains(where: { $0 === self }) else { return }

        let count = navigation.viewControllers.count
        // 되돌아가는 전환 — 빠지는 화면이 아직 스택에 있다. 한 장 빠진 뒤를 기준으로 본다
        let goingBack = transitionCoordinator != nil && !isMovingToParent
        let depthAfter = goingBack ? count - 1 : count
        syncTabBar(of: navigation, hide: depthAfter > 1, animated: animated)
    }

    private func syncTabBar(of navigation: UINavigationController, hide: Bool, animated: Bool) {
        guard #available(iOS 18.0, *), let tabs = navigation.tabBarController else { return }

        guard animated, let coordinator = transitionCoordinator else {
            if tabs.isTabBarHidden != hide { tabs.setTabBarHidden(hide, animated: false) }
            return
        }

        let before = tabs.isTabBarHidden
        coordinator.animate(alongsideTransition: { _ in
            if tabs.isTabBarHidden != hide { tabs.setTabBarHidden(hide, animated: false) }
        }, completion: { context in
            // 가장자리 쓸기를 중간에 놓아 취소되면 원래대로
            if context.isCancelled {
                tabs.setTabBarHidden(before, animated: false)
                return
            }
            // 한 번에 여러 장 빠진 경우 등 — 끝난 스택으로 한 번 더 맞춘다
            let settled = navigation.viewControllers.count > 1
            if tabs.isTabBarHidden != settled { tabs.setTabBarHidden(settled, animated: true) }
        })
    }
}

/// 탭 바의 **통로 칸**(웨이트 · 이전)을 누르면 UIKit 이 그 칸을 고르지 못하게 하고, 선택값은 셸이 바꾼다 (DESIGN §7.1).
///
/// 🟢 (2026-09-15, 사용자 — *"웨이트 눌렀을때도 헤더가 똑같은 속도로 나오면 좋겠는데"*)
/// 누르면 UIKit 이 먼저 통로 칸(3)으로 전환을 시작하고, SwiftUI 가 곧바로 세트를 바꿔 진짜 칸(1)으로 되돌렸다.
/// 전환이 중간에 끊겨 **페이지는 툭 바뀌고 헤더는 비었다가 0.1초 뒤 번지며** 떴다 (60fps, 실제 누르기 경로).
/// 누르지 않고 선택값만 바꾸면 다른 탭과 똑같이 겹쳐 바뀐다 — 그래서 통로는 UIKit 에서 막고 선택값만 바꾼다.
/// SwiftUI 의 탭 바 대리자(`TabViewCoordinator_Phone`)는 `tabBarController(_:shouldSelect:)` 에 답한다 — 그 앞에 끼어든다
extension UITabBarController {
    /// 이 칸을 셸이 가져가면 `true` — UIKit 은 고르지 않는다. `TabShell` 이 채운다
    nonisolated(unsafe) static var myFisTakeOverSelection: ((Int) -> Bool)?

    nonisolated(unsafe) private static var guardedClasses: Set<ObjectIdentifier> = []

    /// 셸의 탭 바 컨트롤러 — `myFisGuardPassages` 가 붙잡아 둔다
    nonisolated(unsafe) private weak static var shell: UITabBarController?

    /// 탭 이름을 **손쓰기 라벨**로 단다 🟢 (2026-09-15).
    /// `.tabItem` 이미지에 건 `accessibilityLabel` 은 탭 바 버튼에 안 옮겨져 **VoiceOver 가 탭 이름을 못 읽었다**.
    /// 글자 제목을 주면 아이콘 밑에 글씨가 생긴다 (§6.7 아이콘만) — 그래서 바 항목에 직접 단다. 안드로이드는 `contentDescription = tab.label`
    static func myFisLabelTabs(_ labels: [String]) {
        tabLabels = labels
        applyTabLabels()
    }

    /// 마지막으로 받은 탭 이름 — 컨트롤러를 붙잡기 전에 오면 붙잡을 때 단다
    nonisolated(unsafe) private static var tabLabels: [String] = []

    private static func applyTabLabels() {
        guard let items = shell?.tabBar.items else { return }
        for (item, label) in zip(items, tabLabels) where item.accessibilityLabel != label {
            item.accessibilityLabel = label
        }
    }

    /// 탭 바 내용을 **페이지와 같은 박자로 겹쳐 바꾼다** — 세트 교체 때만 부른다 (§7.1).
    /// 같은 트랜잭션에서 바뀌는 아이콘 · 선택 표시가 한 번에 갈리지 않고 흐려지며 넘어간다
    ///
    /// - 시작을 **페이지가 흐려지기 시작할 때까지 미룬다** — 그동안은 이전 모습(기본 세트 · 선택 표시 제자리)을 붙잡아 둔다.
    ///   안 미루니 아이콘이 0.08초 먼저 끝났다 (60fps: 아이콘 7.59~7.64초 · 페이지 7.67초~)
    /// - 곡선은 **시스템 탭 전환을 따른다** (가속-감속). 우리 감속 곡선은 변화가 앞에 몰려 페이지보다 먼저 끝나 보였다
    static func myFisCrossfadeTabBar(duration: TimeInterval) {
        guard let bar = shell?.tabBar else { return }
        let fade = CATransition()
        fade.type = .fade
        fade.duration = duration
        fade.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fade.beginTime = bar.layer.convertTime(CACurrentMediaTime(), from: nil) + systemTabFadeDelay
        fade.fillMode = .backwards
        bar.layer.add(fade, forKey: "myFisTabSet")
    }

    /// 탭을 고른 뒤 **시스템이 페이지를 흐리기 시작할 때까지** — 실측 (60fps, iOS 26.5 시뮬레이터):
    /// 탭 바 첫 변화 → 본문 첫 변화 0.05~0.07초 (혜택 · 홈 · 웨이트 · 이전 모두)
    private static let systemTabFadeDelay: CFTimeInterval = 0.06

    /// 대리자 클래스마다 한 번 끼운다 — 탭 바 컨트롤러나 그 밑 화면이 나타날 때마다 불러도 된다
    func myFisGuardPassages() {
        Self.shell = self
        Self.applyTabLabels()
        guard let delegate = delegate as? NSObject else { return }
        let cls: AnyClass = type(of: delegate)
        guard Self.guardedClasses.insert(ObjectIdentifier(cls)).inserted else { return }
        let selector = NSSelectorFromString("tabBarController:shouldSelectViewController:")
        guard let method = class_getInstanceMethod(cls, selector) else { return }

        typealias Ask = @convention(c) (AnyObject, Selector, UITabBarController, UIViewController) -> Bool
        let original = unsafeBitCast(method_getImplementation(method), to: Ask.self)
        let replacement: @convention(block) (AnyObject, UITabBarController, UIViewController) -> Bool = { me, tabs, controller in
            if let slot = tabs.viewControllers?.firstIndex(of: controller),
               UITabBarController.myFisTakeOverSelection?(slot) == true {
                return false
            }
            return original(me, selector, tabs, controller)
        }
        let implementation = imp_implementationWithBlock(replacement)
        // 부모 클래스에서 물려받은 구현이면 부모를 건드리지 않게 이 클래스에 더한다
        if !class_addMethod(cls, selector, implementation, method_getTypeEncoding(method)) {
            method_setImplementation(method, implementation)
        }
    }
}

#if DEBUG
extension UINavigationController {
    /// 진단 (2026-09-15) — 뷰 컨트롤러 나무를 찍는다. `MYFIS_VCDUMP=1` 일 때만
    static func myFisDumpControllers() {
        guard ProcessInfo.processInfo.environment["MYFIS_VCDUMP"] == "1" else { return }
        for scene in UIApplication.shared.connectedScenes {
            guard let scene = scene as? UIWindowScene else { continue }
            for window in scene.windows { dumpTree(window.rootViewController, depth: 0) }
        }
    }

    private static func dumpTree(_ controller: UIViewController?, depth: Int) {
        guard let controller else { return }
        var line = String(repeating: "  ", count: depth) + "\(type(of: controller))"
        if let nav = controller as? UINavigationController { line += " [내비 \(nav.viewControllers.count)장]" }
        if let tab = controller as? UITabBarController { line += " [탭 선택 \(tab.selectedIndex) · 바 숨김 \(tab.tabBar.isHidden)]" }
        fputs("[vc] \(line)\n", stderr)
        for child in controller.children { dumpTree(child, depth: depth + 1) }
    }
}
#endif
