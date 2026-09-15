import SwiftUI

/// DESIGN.md §5.1 간격 — 4pt 베이스
enum MyFisSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let huge: CGFloat = 40
    static let giant: CGFloat = 56

    /// 화면 좌우 여백
    static let screenHorizontal: CGFloat = 20
    /// 카드 내부 패딩
    static let cardPadding: CGFloat = 16
    /// 카드 사이 간격
    static let cardGap: CGFloat = 12
    /// 섹션 사이 간격
    static let sectionGap: CGFloat = 32
}

/// DESIGN.md §5.2 라운딩
enum MyFisRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    /// 아이콘 판 (§6.23 혜택 행) — `56` 판에 맞춘 값이다. 다른 크기에 그대로 쓰지 않는다
    static let tile: CGFloat = 18
    /// 그 `18 / 56`. 판 크기가 다르면 이 비율로 다시 뽑는다 (§6.26 · 2026-09-04)
    static let tileRatio: CGFloat = tile / MyFisSize.listRowMin
    static let full: CGFloat = 999
}

/// DESIGN.md §5.3 터치 타겟 / §6.1 버튼 높이
enum MyFisSize {
    static let minTouchTarget: CGFloat = 44
    static let buttonPrimary: CGFloat = 52
    static let buttonSecondary: CGFloat = 44
    static let inputHeight: CGFloat = 52
    /// 큰 찾기 줄 (M-08) — 입력 필드보다 크다. **화면에서 제일 먼저 눈에 들어와야** 한다
    static let searchBar: CGFloat = 64
    static let listRowMin: CGFloat = 56
    static let progressHeight: CGFloat = 8
    /// 카드 안 보조 버튼 (§6.1)
    static let buttonSmall: CGFloat = 36
    /// Small 의 **테두리형** 높이 (§6.1 · §6.38) 🟢 (2026-09-14) — 레퍼런스(버핏그라운드 MY)의 작은 테두리 버튼
    static let buttonOutlined: CGFloat = 32

    /// 알약 칩·뱃지 높이 (§5.2) — 마일리지 칩 · 연속 출석 · 펼쳐보기 · 도움 됐어요.
    ///
    /// **`buttonSmall` 과 같은 값이다.** 숫자를 새로 만든 게 아니라 이름을 준 것 —
    /// 칩과 Small 버튼은 나란히 서는 일이 있어 높이가 같아야 한다.
    ///
    /// ⚠️ 전에는 세로 여백(`6`·`7`)으로 높이를 만들었는데 그 값이 §5.1 스케일 밖이었다.
    /// 높이를 못 박으면 글꼴이나 아이콘이 바뀌어도 칩이 안 흔들린다 (2026-08-27)
    static let chip: CGFloat = buttonSmall

    /// 헤더 높이 (§6.9) — 두 플랫폼 같은 값
    static let header: CGFloat = 56
    /// 헤더 아이콘 (§6.9) — Android 24 / iOS 26
    static let headerIcon: CGFloat = 26

    // MARK: iOS 26 툴바 알약 — 스토어 머리 검색칸 폭 계산용 (§6.9, 2026-09-15 시뮬레이터 402pt 실측)
    //
    // **우리가 고른 값이 아니라 시스템 값을 잰 것이다.** 내비 바가 왼쪽 항목에 남는 폭을 주지 않아
    // 검색칸 폭을 직접 계산해야 해서 이름을 붙였다. iOS 가 바뀌면 다시 잰다

    /// 오른쪽 알약 — 장바구니 · 마이 (실측 103.7)
    static let toolbarPairPlatter: CGFloat = 104
    /// 알약과 알약 사이 — **12 보다 좁히면 오른쪽 알약이 `…` 로 접힌다** (실측: 사이 10 에서 `취소` 가 접힘, 12 부터 안 접힘).
    /// 크림 녹화의 사이도 약 12 다. ~~8~~ 은 제목 자리 검색창일 때 잰 값이었다
    static let toolbarPlatterGap: CGFloat = 12
    /// 화면 끝과 알약 사이 (실측 16)
    static let toolbarEdge: CGFloat = 16
    /// 검색칸 둘레에 알약이 덧대는 안쪽 여백 (실측 — 입력칸 258 에 알약 266, 한쪽 4).
    /// 0 으로 두니 왼쪽 알약이 오른쪽 알약에 **붙었다** (사이 8 이 사라짐)
    static let toolbarFieldInset: CGFloat = 4
}

/// DESIGN.md §7 모션 — 이징은 `cubic-bezier(0.2, 0, 0, 1)` (감속 위주).
///
/// 화면 전환(`slow`)은 **안드로이드 `pushSpec` 과 같은 값**이다 (320ms).
enum MyFisMotion {
    /// 눌림, 토글, 체크
    static let fast = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.12 * scale)
    /// 카드 확장, 페이드
    static let base = Animation.timingCurve(0.2, 0, 0, 1, duration: baseDuration)
    /// `base` 의 길이(초) — UIKit · CoreAnimation 에 넘길 때 (탭 세트 교체 때 탭 바 겹쳐 바꾸기)
    static let baseDuration: TimeInterval = 0.20 * scale
    /// 바텀시트, 화면 전환
    static let slow = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.32 * scale)

    /// 토스트가 **머무는 시간** (§6.35) — 들어오고 나가는 `base` 와 별개다.
    /// 한 줄을 읽고도 남을 만큼이면 된다. 길면 화면을 가리고, 짧으면 못 읽는다
    static let toastHold: Double = 2.0 * scale

    /// 전환을 늦춰 **중간 프레임**을 본다 — `SIMCTL_CHILD_MYFIS_MOTION=15` (디버그 빌드 전용).
    ///
    /// ⚠️ `MYFIS_SLOWMO` 로는 안 된다 (2026-09-04 확인) — 그건 `window.layer.speed` 라
    /// **창 전환(CoreAnimation)만** 늦춘다. SwiftUI 의 `withAnimation` 값 애니메이션은
    /// 제 타이머로 돌아서 영향을 안 받는다
    private static var scale: Double {
        #if DEBUG
        ProcessInfo.processInfo.environment["MYFIS_MOTION"].flatMap(Double.init) ?? 1
        #else
        1
        #endif
    }
}
