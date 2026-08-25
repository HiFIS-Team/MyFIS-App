import SwiftUI

/// 헤더에서 밀려 들어오는 화면들.
enum HeaderRoute: Hashable {
    case notifications
    /// S-08 스토어 마이 — 마이 탭(Y-01)과 다른 화면이다
    case storeMy
    /// S-02 상품 상세
    case storeItem(StoreItem)
    /// S-06 장바구니
    case storeCart
    // TODO: 지점 선택(M-01) · 회원권(M-06) 이 붙으면 여기에 추가한다.
}

/// 탭 하나의 뼈대 — 배경 + 내용.
///
/// **헤더는 여기 없다.** 화면마다 헤더가 달라서 각 화면이 직접 들고 있다 (DESIGN.md §6.9) —
/// 홈은 지점·멤버십·알림, 스토어는 검색·장바구니·마이.
///
/// 잎 화면도 여기서 열지 않는다. 셸 위에 통째로 덮이므로 [AppShell] 이 들고 있다.
struct TabScreen<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()
            VStack(spacing: 0) {
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
        switch ProcessInfo.processInfo.environment["MYFIS_ROUTE"] {
        case "notifications": .notifications
        case "store_my": .storeMy
        case "store_item": .storeItem(StorePlaceholder.items[0])
        case "store_cart": .storeCart
        default: nil
        }
        #else
        nil
        #endif
    }
}
