import SwiftUI

/// DESIGN.md §6.11 주간 캘린더 — 홈 헤더 바로 밑.
///
/// 이번 주 **월~일 7칸**을 한 줄로 보여주고 하루를 고른다.
/// 선택은 하단 탭과 같은 규칙이다 — **라임을 쓰지 않는다.**
/// 상시 떠 있는 것에 액센트 예산(한 화면 2곳)을 쓰지 않는다 (§6.7).
///
/// 선택 알약은 칸을 따라 **흐른다** (`matchedGeometryEffect`).
/// 칸마다 배경을 껐다 켜면 선택이 순간이동해 보인다.
struct WeekCalendar: View {
    let week: [Date]
    @Binding var selected: Date
    var onSelect: (Date) -> Void = { _ in }

    /// 칸이 터치 타겟(44)보다 커야 하므로 알약 높이가 곧 행 높이다
    private let pillHeight: CGFloat = 68
    private let pillWidth: CGFloat = 44
    private let markSize: CGFloat = 26

    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(week, id: \.self) { day in
                cell(day)
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }

    private func cell(_ day: Date) -> some View {
        let isSelected = MyFisCalendar.isSameDay(day, selected)

        return VStack(spacing: MyFisSpacing.xs) {
            Text(MyFisCalendar.weekdayLabel(day))
                .font(MyFisFont.caption)
                .foregroundStyle(isSelected ? MyFisColor.bgBase : MyFisColor.textTertiary)
                .frame(width: markSize, height: markSize)
                .background {
                    if isSelected {
                        Circle().fill(MyFisColor.textPrimary)
                    }
                }
            Text(MyFisCalendar.dayNumber(day))
                // 날짜는 자릿수가 바뀌어도 칸 안에서 흔들리면 안 된다 (DESIGN §4.1)
                .font(MyFisFont.titleSm.monospacedDigit())
                .foregroundStyle(isSelected ? MyFisColor.textPrimary : MyFisColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: pillHeight)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: pillHeight / 2, style: .continuous)
                    .fill(MyFisColor.surface2)
                    .frame(width: pillWidth)
                    .matchedGeometryEffect(id: "weekPill", in: pill)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isSelected else { return }
            withAnimation(MyFisMotion.base) { selected = day }
            onSelect(day)
        }
    }
}

/// 주간 캘린더가 쓰는 날짜 계산. **주는 월요일에 시작한다.**
///
/// 기기 지역 설정이 일요일 시작이어도 우리 주는 월요일부터다 —
/// 루틴이 주 단위로 오고, 그 주의 기준이 흔들리면 안 된다.
enum MyFisCalendar {
    static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2 // 월요일
        c.locale = Locale(identifier: "ko_KR")
        return c
    }()

    /// [date] 가 속한 주를 월요일부터 7일 반환한다.
    static func week(of date: Date) -> [Date] {
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    static func dayNumber(_ date: Date) -> String {
        String(calendar.component(.day, from: date))
    }

    /// 기기 로케일을 따르지 않고 우리가 정한다 — 한국어 전용 앱이고,
    /// 요일 한 글자는 폭이 일정해야 칸이 흔들리지 않는다.
    static func weekdayLabel(_ date: Date) -> String {
        let labels = ["일", "월", "화", "수", "목", "금", "토"]
        return labels[calendar.component(.weekday, from: date) - 1]
    }
}
