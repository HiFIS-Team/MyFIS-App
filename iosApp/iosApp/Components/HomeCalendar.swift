import SwiftUI

/// DESIGN.md §6.11 홈 캘린더 — 헤더 바로 밑.
///
/// 평소에는 **이번 주 한 줄**, `펼쳐보기` 를 누르면 **그 달 전체**로 늘어난다.
/// 선택은 하단 탭과 같은 규칙이다 — **라임을 쓰지 않는다.**
/// 상시 떠 있는 것에 액센트 예산(한 화면 2곳)을 쓰지 않는다 (§6.7).
///
/// 접힌 줄의 알약은 칸을 따라 **흐른다** (`matchedGeometryEffect`).
struct HomeCalendar: View {
    @Binding var selected: Date
    /// 펼쳤을 때 보이는 달 (그 달의 아무 날)
    @Binding var month: Date
    let expanded: Bool
    /// 출석한 날인지 — `Set<Date>` 는 시분초 때문에 그대로 못 쓴다
    var isAttended: (Date) -> Bool = { _ in false }

    /// 칸이 터치 타겟(44)보다 커야 하므로 알약 높이가 곧 행 높이다
    private let pillHeight: CGFloat = 68
    private let pillWidth: CGFloat = 44
    private let markSize: CGFloat = 26
    /// 출석 도장이 날짜를 감싸는 크기
    private let stampSize: CGFloat = 40

    @Namespace private var pill

    var body: some View {
        VStack(spacing: 0) {
            if expanded {
                monthHeader
                weekdayHeader
                ForEach(Array(MyFisCalendar.monthWeeks(of: month).enumerated()), id: \.offset) { _, week in
                    monthRow(week)
                }
            } else {
                weekStrip
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        // 줄 수가 바뀌는 것을 높이 애니메이션으로 잇는다 — 펼침이 툭 끊기면 안 된다
        // 접힘/펼침은 `slow`(320ms) — `base` 는 달이 툭 튀어나오는 느낌이었다
        .animation(MyFisMotion.slow, value: expanded)
    }

    // MARK: - 접힌 줄

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(MyFisCalendar.week(of: selected), id: \.self) { day in
                cell(day)
            }
        }
    }

    private func cell(_ day: Date) -> some View {
        let isSelected = MyFisCalendar.isSameDay(day, selected)

        return VStack(spacing: MyFisSpacing.xs) {
            Text(MyFisCalendar.weekdayLabel(day))
                .font(MyFisFont.caption)
                .foregroundStyle(
                    isSelected
                        ? MyFisColor.bgBase
                        : MyFisCalendar.weekendColor(day) ?? MyFisColor.textTertiary
                )
                .frame(width: markSize, height: markSize)
                .background {
                    if isSelected {
                        Circle().fill(MyFisColor.textPrimary)
                    }
                }
            Text(MyFisCalendar.dayNumber(day))
                // 날짜는 자릿수가 바뀌어도 칸 안에서 흔들리면 안 된다 (DESIGN §4.1)
                .font(MyFisFont.titleSm.monospacedDigit())
                .foregroundStyle(
                    isSelected
                        ? MyFisColor.textPrimary
                        : MyFisCalendar.weekendColor(day) ?? MyFisColor.textSecondary
                )
                .frame(width: stampSize, height: stampSize)
                // 도장은 **숫자 위**에 온다 — 달력에 찍은 자국이라 겹치는 게 맞다
                .overlay { stamp(day) }
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
            guard !MyFisCalendar.isSameDay(day, selected) else { return }
            withAnimation(MyFisMotion.base) { selected = day }
        }
    }

    /// 출석 도장 — 우리 로고 도장 그대로다.
    ///
    /// **숫자 위에 겹쳐 찍는다.** 종이 달력에 도장을 찍은 자국이라 겹치는 게 의도다
    /// (며칠인지는 칸 위치로도 읽힌다). 색이 있는 그림이라 tint 하지 않는다.
    @ViewBuilder
    private func stamp(_ day: Date) -> some View {
        if isAttended(day) {
            Image("ic_stamp")
                .resizable()
                .frame(width: stampSize, height: stampSize)
                .rotationEffect(.degrees(MyFisCalendar.stampAngle(day)))
        }
    }

    // MARK: - 펼친 달

    /// 펼친 상태의 달 머리글 — `2026년 8월` 과 앞뒤 달로 가는 화살표
    private var monthHeader: some View {
        HStack(spacing: 0) {
            Text(MyFisCalendar.monthTitle(month))
                .font(MyFisFont.titleMd.monospacedDigit())
                .foregroundStyle(MyFisColor.textPrimary)
            Spacer(minLength: 0)
            // 화살표는 아래쪽 화살표 한 벌을 돌려 쓴다 (§6.11)
            monthArrow(degrees: 90, label: "이전 달", step: -1)
            monthArrow(degrees: -90, label: "다음 달", step: 1)
        }
        .padding(.trailing, -MyFisSpacing.sm)
        .padding(.bottom, MyFisSpacing.md)
    }

    private func monthArrow(degrees: Double, label: String, step: Int) -> some View {
        Button {
            guard let next = MyFisCalendar.calendar.date(byAdding: .month, value: step, to: month)
            else { return }
            month = next
        } label: {
            Image("ic_chevron_down")
                .resizable()
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(degrees))
                .foregroundStyle(MyFisColor.textSecondary)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
        .accessibilityLabel(label)
    }

    /// 칸마다 요일을 반복하면 달력이 시끄럽다 — 머리글 한 줄로 뺀다
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(MyFisCalendar.weekdayLabels, id: \.self) { label in
                Text(label)
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisCalendar.weekendColor(label: label) ?? MyFisColor.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, MyFisSpacing.xs)
    }

    private func monthRow(_ week: [Date?]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                Group {
                    if let day {
                        monthDay(day)
                    } else {
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
        }
    }

    private func monthDay(_ day: Date) -> some View {
        let isSelected = MyFisCalendar.isSameDay(day, selected)

        return VStack(spacing: 0) {
            ZStack {
                Text(MyFisCalendar.dayNumber(day))
                    .font(MyFisFont.bodySm.monospacedDigit())
                    .foregroundStyle(
                        isSelected
                            ? MyFisColor.textPrimary
                            : MyFisCalendar.weekendColor(day) ?? MyFisColor.textSecondary
                    )
                // 도장은 **숫자 위**에 온다 — 달력에 찍은 자국이라 겹치는 게 맞다
                stamp(day)
            }
            .frame(width: stampSize, height: stampSize)

            // 고른 날은 **동그라미 대신 밑에 점**이다. 도장과 겹치지 않고, 달력이 조용해진다
            Circle()
                .fill(isSelected ? MyFisColor.textPrimary : .clear)
                .frame(width: 5, height: 5)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isSelected else { return }
            withAnimation(MyFisMotion.base) { selected = day }
        }
    }
}

/// 홈 캘린더가 쓰는 날짜 계산. **주는 일요일에 시작한다** (한국 달력 관행).
///
/// 기기 지역 설정을 따르지 않고 우리가 고정한다 — 기준이 기기마다 다르면 안 된다.
enum MyFisCalendar {
    static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1 // 일요일 — 한국 달력 관행
        c.locale = Locale(identifier: "ko_KR")
        return c
    }()

    /// 기기 로케일을 따르지 않고 우리가 정한다 — 한국어 전용 앱이고,
    /// 요일 한 글자는 폭이 일정해야 칸이 흔들리지 않는다.
    static let weekdayLabels = ["일", "월", "화", "수", "목", "금", "토"]

    /// [date] 가 속한 주를 일요일부터 7일 반환한다.
    static func week(of date: Date) -> [Date] {
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    /// [date] 가 속한 **달**을 주 단위로 자른다. 앞뒤 빈 칸은 `nil` 이다.
    ///
    /// 옆 달 날짜를 흐리게 채우지 않는다 — 이 달 안에서만 고르게 한다.
    static func monthWeeks(of date: Date) -> [[Date?]] {
        guard let interval = calendar.dateInterval(of: .month, for: date),
              let count = calendar.range(of: .day, in: .month, for: date)?.count
        else { return [] }

        let first = interval.start
        let lead = (calendar.component(.weekday, from: first) - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: lead)
        days += (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: first) }
        if days.count % 7 != 0 {
            days += Array(repeating: nil, count: 7 - days.count % 7)
        }
        return stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<($0 + 7)]) }
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    static func dayNumber(_ date: Date) -> String {
        String(calendar.component(.day, from: date))
    }

    /// `2026년 8월`
    static func monthTitle(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return "\(parts.year ?? 0)년 \(parts.month ?? 0)월"
    }

    static func weekdayLabel(_ date: Date) -> String {
        weekdayLabels[calendar.component(.weekday, from: date) - 1]
    }

    /// 토요일 파랑 · 일요일 빨강 — 한국 달력 관행 (DESIGN.md §3.1).
    /// 고른 날은 흰 알약/원이 더 센 신호라 그쪽을 따른다.
    static func weekendColor(_ date: Date) -> Color? {
        switch calendar.component(.weekday, from: date) {
        case 1: MyFisColor.weekendSunday
        case 7: MyFisColor.weekendSaturday
        default: nil
        }
    }

    /// 진짜 도장은 삐뚤게 찍힌다. 날짜에서 각도를 뽑아 **-10°~+10°** 로 기울인다.
    ///
    /// 무작위가 아니라 **날짜에서 계산**한다 — 다시 그릴 때마다 각도가 바뀌면 화면이 들썩인다.
    /// 두 플랫폼이 같은 식을 쓰므로 같은 날은 같은 각도다.
    static func stampAngle(_ date: Date) -> Double {
        let parts = calendar.dateComponents([.day, .month], from: date)
        let value = ((parts.day ?? 0) * 37 + (parts.month ?? 0) * 13) % 21 - 10
        return Double(value)
    }

    static func weekendColor(label: String) -> Color? {
        switch label {
        case "일": MyFisColor.weekendSunday
        case "토": MyFisColor.weekendSaturday
        default: nil
        }
    }
}
