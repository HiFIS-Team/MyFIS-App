import SwiftUI

@main
struct iOSApp: App {
    init() {
        MyFisFont.register()
    }

    var body: some Scene {
        WindowGroup {
            AppShell()
                // 라이트 모드를 지원하지 않는다 (DESIGN.md §9 의도된 이탈 #1)
                .preferredColorScheme(.dark)
        }
    }
}
