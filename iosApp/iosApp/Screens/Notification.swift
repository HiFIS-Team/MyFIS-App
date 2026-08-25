import Foundation

/// 알림 한 건. SPEC.md §5 H-02.
///
/// TODO(서버): 알림 API 가 아직 없다. 화면을 먼저 세우려고 자리값을 둔다.
/// 붙을 자리는 목록 조회 하나뿐이고, 그때 `placeholder` 만 지우면 된다.
struct MyFisNotification: Identifiable, Hashable {
    let id: Int
    let kind: Kind
    let title: String
    let body: String
    /// TODO(서버): 서버가 주는 시각으로 상대 시간을 계산한다. 지금은 문자열.
    let time: String
    let isUnread: Bool
    /// 같은 종류가 여러 건 묶였을 때만. 한 건이면 `nil`
    var count: Int?

    /// 알림 종류. SPEC.md §5 H-02 "알림 종류" 표와 1:1 이다.
    enum Kind: Hashable {
        case routine, membership, cardio, coupon, group, mileage, notice

        /// 행 아이콘.
        ///
        /// 하단 탭과 달리 **본문 안의 콘텐츠라 두 플랫폼이 같은 벡터를 쓴다** (DESIGN.md §6.9).
        /// SF Symbols 를 섞으면 한 리스트 안에서 채움/아웃라인 톤이 어긋난다.
        var icon: String {
            switch self {
            case .routine: "ic_tab_weight"
            case .membership: "ic_header_membership"
            case .cardio: "ic_tab_cardio"
            case .coupon: "ic_tab_store"
            case .group: "ic_tab_group"
            case .mileage: "ic_mileage_fill"
            case .notice: "ic_header_notification"
            }
        }

        /// 눌렀을 때 갈 화면. TODO: 해당 화면이 붙으면 연결한다.
        var destination: String {
            switch self {
            case .routine: "W-01"
            case .membership: "M-06"
            case .cardio: "C-04"
            case .coupon: "S-04"
            case .group: "G-02"
            case .mileage: "P-01"
            case .notice: "H-04"
            }
        }
    }
}

extension MyFisNotification {
    static let placeholder: [MyFisNotification] = [
        .init(id: 1, kind: .routine,
              title: "이번 주 루틴이 도착했어요",
              body: "월·수·금 3일 루틴 — 하체부터 시작합니다",
              time: "10분 전", isUnread: true),
        .init(id: 2, kind: .cardio,
              title: "유산소가 자동 종료됐어요",
              body: "러닝머신 3번 · 5분간 거리가 늘지 않아 세션을 닫았습니다",
              time: "1시간 전", isUnread: true),
        .init(id: 3, kind: .mileage,
              title: "마일리지 50 P 적립",
              body: "출석 체크 · 오늘까지 3일 연속",
              time: "3시간 전", isUnread: true),
        .init(id: 4, kind: .coupon,
              title: "교환권이 곧 만료돼요",
              body: "이온음료 교환권 · 내일 23:59까지",
              time: "어제", isUnread: false, count: 3),
        .init(id: 5, kind: .group,
              title: "새벽 러닝크루에 새 글이 올라왔어요",
              body: "내일 비 오면 실내 트랙으로 갈게요",
              time: "어제", isUnread: false),
        .init(id: 6, kind: .membership,
              title: "회원권이 7일 남았어요",
              body: "6개월 회원권 · 9월 3일 만료",
              time: "3일 전", isUnread: false),
        .init(id: 7, kind: .notice,
              title: "광복절 정상 운영합니다",
              body: "8월 15일 · 06:00 ~ 23:00",
              time: "5일 전", isUnread: false),
    ]

    /// 시뮬레이터에는 빈 상태를 만들 방법이 없다. 스크린샷 확인용 디버그 훅.
    ///
    ///     xcrun simctl launch booted com.myfis.app   # SIMCTL_CHILD_MYFIS_NOTIFICATIONS=empty
    static var initialForDebug: [MyFisNotification] {
        #if DEBUG
        ProcessInfo.processInfo.environment["MYFIS_NOTIFICATIONS"] == "empty" ? [] : placeholder
        #else
        placeholder
        #endif
    }
}
