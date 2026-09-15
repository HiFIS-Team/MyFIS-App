import SwiftUI
import UIKit

@main
struct iOSApp: App {
    init() {
        MyFisFont.register()
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
