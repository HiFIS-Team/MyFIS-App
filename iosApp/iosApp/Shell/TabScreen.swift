import SwiftUI

/// 헤더에서 밀려 들어오는 화면들.
enum HeaderRoute: Hashable {
    case notifications
    // TODO: 지점 선택(M-01) · 회원권(M-06) 이 붙으면 여기에 추가한다.
}

/// 탭 하나의 뼈대 — 배경 + 헤더 + 내용.
///
/// 잎 화면은 여기서 열지 않는다. 셸 위에 통째로 덮이므로 [AppShell] 이 들고 있다.
struct TabScreen<Content: View>: View {
    var onNotification: () -> Void = {}
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()
            VStack(spacing: 0) {
                AppHeader(onNotification: onNotification)
                content
            }
        }
    }
}

extension Optional where Wrapped == HeaderRoute {
    /// 시뮬레이터에는 탭을 자동화할 수단이 없다. 덮인 화면을 스크린샷으로 확인할 때
    /// `SIMCTL_CHILD_MYFIS_ROUTE=notifications` 로 앱을 띄운다.
    ///
    /// 디버그 빌드에서만 동작한다.
    static var initialForDebug: HeaderRoute? {
        #if DEBUG
        ProcessInfo.processInfo.environment["MYFIS_ROUTE"] == "notifications" ? .notifications : nil
        #else
        nil
        #endif
    }
}
