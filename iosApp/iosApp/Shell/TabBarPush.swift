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
