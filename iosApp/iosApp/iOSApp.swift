import SwiftUI
import UIKit

@main
struct iOSApp: App {
    init() {
        MyFisFont.register()
        // 잎이 들어올 때 탭 바를 화면과 함께 밀어낸다 — 크림 같은 UIKit 앱과 같은 동작 (§7.1)
        UIViewController.myFisSyncTabBarWithNavigation()
        // 시스템 내비 바 제목도 우리 글꼴 — `title.sm` (§4.2 · §7.1). 색은 시스템에 맡긴다 (흰 바탕 잎에서 어두워진다)
        if let font = UIFont(name: "PretendardStd-SemiBold", size: 17) {
            UINavigationBar.appearance().titleTextAttributes = [.font: font]
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRoot()
                // 라이트 모드를 지원하지 않는다 (DESIGN.md §9 의도된 이탈 #1)
                .preferredColorScheme(.dark)
        }
    }
}
