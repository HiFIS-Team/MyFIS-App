import SwiftUI

@main
struct iOSApp: App {
    init() {
        MyFisFont.register()
        // 탭 바 비선택 색은 건드리지 않는다.
        // iOS 26 Liquid Glass 탭 바는 UITabBar.appearance() / UITabBarAppearance 를
        // 무시한다 (둘 다 시도해서 확인). 선택 색만 SwiftUI .tint() 로 먹는다.
        // → DESIGN.md §6.7 플랫폼 제약 참고
    }

    var body: some Scene {
        WindowGroup {
            AppShell()
                // 라이트 모드를 지원하지 않는다 (DESIGN.md §9 의도된 이탈 #1)
                .preferredColorScheme(.dark)
        }
    }
}
