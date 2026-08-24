import SwiftUI

/// SPEC.md H-01 홈.
///
/// 헤더 바로 밑에 **이번 주 캘린더**가 있고, 그 아래가 고른 날의 내용이다.
/// 아직 카드가 없어 자리값만 둔다.
struct HomeScreen: View {
    private let today = Date()
    @State private var selected = Date()

    var body: some View {
        VStack(spacing: 0) {
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
