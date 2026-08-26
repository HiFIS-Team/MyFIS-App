import SwiftUI

/// 잎 화면 — 셸(탭 + 하단 바)을 **통째로 덮는** 페이지.
///
/// 안드로이드 `Route`(= `NavHost` 에서 `SHELL` 과 형제인 라우트)와 1:1 이다.
/// 탭 안에서 밀리는 화면이 아니라 **셸 위에 얹히는** 화면이라는 뜻이다 (DESIGN.md §7.1).
enum Route: Hashable {
    /// H-02 알림함
    case notifications
    /// S-08 스토어 마이 — 마이 탭(Y-01)과 다른 화면이다
    case storeMy
    /// S-06 장바구니
    case storeCart
    /// P-08 체중 기록
    case weightLog
    /// S-02 상품 상세
    case storeItem(StoreItem)
    // TODO: 지점 선택(M-01) · 회원권(M-06) 이 붙으면 추가한다.

    /// 잎 화면의 제목. 헤더가 이 값을 쓴다 — 화면마다 따로 적지 않는다
    var title: String {
        switch self {
        case .notifications: "알림"
        case .storeMy: "내 교환"
        case .storeCart: "장바구니"
        case .weightLog: "체중 기록"
        case .storeItem(let item): item.name
        }
    }
}
