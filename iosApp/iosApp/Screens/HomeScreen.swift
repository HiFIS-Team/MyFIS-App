import SwiftUI

/// SPEC.md H-01 홈.
///
/// 헤더 바로 밑에 **이번 주 캘린더**가 있고, 그 아래가 고른 날의 내용이다.
/// 아직 카드가 없어 자리값만 둔다.
///
/// **헤더는 셸이 아니라 화면이 들고 있다.** 지점·멤버십·알림 헤더는 홈에서만 쓴다 —
/// 스토어는 검색·장바구니·마이를 쓴다 (DESIGN.md §6.9).
struct HomeScreen: View {
    var onNotification: () -> Void = {}

    private let today = Date()
    @State private var selected = Date()

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(onNotification: onNotification)
            WeekCalendar(week: MyFisCalendar.week(of: today), selected: $selected)
                .padding(.top, MyFisSpacing.sm)
            // TODO: 회원권 카드 · 오늘 할 운동 · 마일리지가 붙으면 교체한다 (SPEC H-01).
            PlaceholderScreen(
                id: "H-01",
                title: "홈",
                description: "회원권 상태 · 오늘 할 운동 · 마일리지"
            )
        }
    }
}
