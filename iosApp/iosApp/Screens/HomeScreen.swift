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
    var onDiet: () -> Void = {}
    var onCardio: () -> Void = {}
    var onWeight: () -> Void = {}

    @State private var selected = Date()
    @State private var expanded = false
    /// 펼쳤을 때 보고 있는 달. 고른 날과 따로 둔다 — 지난 달을 넘겨봐도 고른 날은 그대로다
    @State private var month = Date()

    var body: some View {
        VStack(spacing: 0) {
            // 헤더는 고정, 그 아래만 스크롤한다 (스토어와 같은 구조)
            AppHeader(onNotification: onNotification)
            ScrollView {
                VStack(spacing: 0) {
            HomeCalendar(
                selected: $selected,
                month: $month,
                expanded: expanded,
                isAttended: HomePlaceholder.isAttended
            )
                .padding(.top, MyFisSpacing.sm)
            CalendarBar(
                expanded: $expanded,
                streak: HomePlaceholder.attendanceStreak
            )
            .padding(.top, MyFisSpacing.xs)
            ShortcutRow(onDiet: onDiet, onCardio: onCardio)
                .padding(.top, MyFisSpacing.lg)
            TodayRoutineSection(
                routine: HomePlaceholder.todayRoutine,
                onStart: onWeight
            )
            .padding(.top, MyFisSpacing.sectionGap)
            CongestionSection(congestion: HomePlaceholder.congestion)
                .padding(.top, MyFisSpacing.sectionGap)
            // TODO: 마일리지 + 찜 한 줄, 조건부 줄(회원권 D-7 · 미수령 교환권)이 아래에 붙는다 (SPEC H-01).
                }
                .padding(.bottom, MyFisSpacing.xxxl)
            }
        }
    }
}

/// 캘린더 아래 한 줄 — 왼쪽 `펼쳐보기`, 오른쪽 `연속 출석`.
///
/// 펼치기는 **화살표가 뒤집히며** 캘린더가 그 달로 늘어난다 (§6.11).
/// 연속 출석은 이 화면에서 **자랑거리**라 숫자만 흰색으로 세운다.
private struct CalendarBar: View {
    @Binding var expanded: Bool
    let streak: Int

    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(MyFisMotion.slow) { expanded.toggle() }
            } label: {
                HStack(spacing: 2) {
                    Text(expanded ? "접기" : "펼쳐보기")
                        .font(MyFisFont.bodySm)
                    Image("ic_chevron_down")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .foregroundStyle(MyFisColor.textSecondary)
                // 오른쪽 뱃지와 세로 중심을 맞춘다 (패딩이 다르면 한쪽이 떠 보인다)
                .padding(.horizontal, MyFisSpacing.sm)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            // 도장을 모은 결과라 **도장 자체를 뱃지에 넣는다.** 체크 아이콘보다 무슨 숫자인지가 분명해진다
            HStack(spacing: MyFisSpacing.xs) {
                // 달력 안에서는 기울여 찍지만, 뱃지에서는 **반듯하게** 둔다 — 여기선 기호에 가깝다
                Image("ic_stamp")
                    .resizable()
                    .frame(width: 22, height: 22)
                Text("연속 출석")
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textTertiary)
                HStack(alignment: .bottom, spacing: 1) {
                    Text("\(streak)")
                        .font(MyFisFont.titleMd.monospacedDigit())
                        .foregroundStyle(MyFisColor.textPrimary)
                    Text("일")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textSecondary)
                        .padding(.bottom, 2)
                }
            }
            .padding(.leading, MyFisSpacing.sm)
            .padding(.trailing, MyFisSpacing.md)
            .padding(.vertical, 6)
            .background(MyFisColor.surface1, in: Capsule())
            .padding(.horizontal, MyFisSpacing.sm)
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }
}

/// TODO(서버): `WeeklyRoutine` · `RoutineDay` 가 붙으면 지운다 (SPEC W-01)
struct TodayRoutine {
    let name: String
    let week: String
    let day: Int
    let focus: String
    let exerciseCount: Int
    let firstExercise: String
    let doneDays: Int
    let totalDays: Int
}

enum HomePlaceholder {
    /// TODO(서버): 출석 기록이 붙으면 계산한다
    static let attendanceStreak = 12

    /// TODO(서버): 혼잡도 API 가 붙으면 지운다
    static var congestion: BranchCongestion {
        BranchCongestion(
            branch: "강남점",
            capacity: 80,
            updatedLabel: "방금 업데이트",
            // 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
            hourly: [12, 26, 34, 24, 38, 30, 26, 20, 16, 18, 22, 34, 56, 68, 62, 44, 28, 14],
            startHour: 6,
            nowHour: MyFisCalendar.calendar.component(.hour, from: Date())
        )
    }

    /// TODO(서버): 주간 루틴 API 가 붙으면 지운다
    static let todayRoutine = TodayRoutine(
        name: "체지방 감량 4주 루틴",
        week: "8월 4주차",
        day: 3,
        focus: "가슴 · 삼두",
        exerciseCount: 5,
        firstExercise: "벤치프레스",
        doneDays: 2,
        totalDays: 5
    )

    /// TODO(서버): 출석 API 가 붙으면 지운다.
    ///
    /// 연속 12일(= 위 자리값)과 앞선 며칠. 숫자와 달력이 서로 다른 말을 하면 안 된다.
    static func isAttended(_ day: Date) -> Bool {
        let calendar = MyFisCalendar.calendar
        guard let diff = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: day),
            to: calendar.startOfDay(for: Date())
        ).day else { return false }
        return (0..<attendanceStreak).contains(diff) || [16, 17, 20, 21].contains(diff)
    }
}

/// 홈 바로가기 두 장 (DESIGN.md §6.13).
///
/// 캘린더 바로 밑 — 고른 날에 **오늘 할 일**로 바로 들어가는 길이다.
/// 두 장으로 고정한다. 늘어나면 홈이 링크 모음이 된다.
private struct ShortcutRow: View {
    let onDiet: () -> Void
    let onCardio: () -> Void

    var body: some View {
        HStack(spacing: MyFisSpacing.cardGap) {
            ShortcutCard(
                icon: "ic_home_diet",
                title: "AI 식단 분석",
                subtitle: "사진으로 기록",
                action: onDiet
            )
            ShortcutCard(
                icon: "ic_tab_cardio",
                title: "유산소",
                subtitle: "스캔하고 시작",
                action: onCardio
            )
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }
}

private struct ShortcutCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MyFisSpacing.md) {
                Image(icon)
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(MyFisColor.textPrimary)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(MyFisSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                MyFisColor.surface1,
                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

/// 오늘의 루틴 (DESIGN.md §6.14) — 홈에서 **오늘 뭘 하는지** 한 장으로 보여주고 웨이트로 보낸다.
///
/// 루틴은 AI가 짜서 보낸다. 사용자가 만들거나 고르지 않으므로
/// 섹션에 `새 루틴` 같은 액션을 두지 않는다 — 목록이 아니라 오늘 한 장이다.
private struct TodayRoutineSection: View {
    let routine: TodayRoutine
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            Text("오늘의 루틴")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            RoutineCard(routine: routine, onStart: onStart)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }
}

private struct RoutineCard: View {
    let routine: TodayRoutine
    let onStart: () -> Void

    var body: some View {
        // 카드 전체가 웨이트로 가는 길이다. 아래 [웨이트 하러 가기] 는 그 길을 보여주는 표시다
        Button(action: onStart) {
            VStack(alignment: .leading, spacing: MyFisSpacing.lg) {
                HStack(spacing: MyFisSpacing.sm) {
                    Text(routine.name)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(routine.week)
                        .font(MyFisFont.caption)
                        .foregroundStyle(MyFisColor.textTertiary)
                }

                HStack(spacing: MyFisSpacing.md) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: MyFisSpacing.sm) {
                            Text("Day \(routine.day)")
                                .font(MyFisFont.titleSm.monospacedDigit())
                                .foregroundStyle(MyFisColor.textPrimary)
                            Text(routine.focus)
                                .font(MyFisFont.body)
                                .foregroundStyle(MyFisColor.textSecondary)
                                .lineLimit(1)
                        }
                        HStack(spacing: 0) {
                            Text("\(routine.exerciseCount)개")
                                .font(MyFisFont.bodySm.monospacedDigit())
                            // 구분은 점이 아니라 **세로선**이다 (§6.12 상품 메타와 같은 규칙)
                            Rectangle()
                                .fill(MyFisColor.borderStrong)
                                .frame(width: 1, height: 10)
                                .padding(.horizontal, MyFisSpacing.sm)
                            Text("\(routine.firstExercise) 외")
                                .font(MyFisFont.bodySm)
                                .lineLimit(1)
                        }
                        .foregroundStyle(MyFisColor.textTertiary)
                    }
                    Spacer(minLength: 0)
                    WeekProgressRing(done: routine.doneDays, total: routine.totalDays)
                }

                HStack(spacing: 2) {
                    Text("웨이트 하러 가기")
                        .font(MyFisFont.titleSm)
                    // 오른쪽 화살표는 따로 두지 않고 아래 화살표를 돌려 쓴다 (같은 획, 같은 굵기)
                    Image("ic_chevron_down")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .rotationEffect(.degrees(-90))
                }
                .foregroundStyle(MyFisColor.accent)
            }
            .padding(MyFisSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                MyFisColor.surface1,
                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

/// 이번 주 진행률 링.
///
/// 액센트는 이 카드에서 **[웨이트 하러 가기] 하나만** 쓴다 (§2 원칙 3).
/// 링까지 라임이면 어디를 눌러야 하는지가 흐려진다.
private struct WeekProgressRing: View {
    let done: Int
    let total: Int

    private var ratio: Double { total <= 0 ? 0 : Double(done) / Double(total) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(MyFisColor.borderSubtle, lineWidth: RoutineRing.stroke)
            Circle()
                .trim(from: 0, to: ratio)
                .stroke(
                    MyFisColor.textPrimary,
                    style: StrokeStyle(lineWidth: RoutineRing.stroke, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // 12시부터 시계방향
            Text("\(done)/\(total)")
                .font(MyFisFont.label.monospacedDigit())
                .foregroundStyle(MyFisColor.textPrimary)
        }
        .frame(width: RoutineRing.size, height: RoutineRing.size)
        .padding(RoutineRing.stroke / 2) // 선 굵기만큼 안쪽으로 — 안드로이드와 지름을 맞춘다
    }
}

private enum RoutineRing {
    static let size: CGFloat = 52
    static let stroke: CGFloat = 4
}

/// 혼잡 단계. 신호등 순서라 설명 없이 읽힌다
enum CongestionLevel {
    case low, medium, high

    var label: String {
        switch self {
        case .low: "한산"
        case .medium: "보통"
        case .high: "혼잡"
        }
    }

    /// 판단을 먼저 준다 — 숫자보다 이게 먼저 읽혀야 한다
    var headline: String {
        switch self {
        case .low: "지금 한산해요"
        case .medium: "지금 딱 좋아요"
        case .high: "지금 붐벼요"
        }
    }

    var color: Color {
        switch self {
        case .low: MyFisColor.success
        case .medium: MyFisColor.warning
        case .high: MyFisColor.danger
        }
    }
}

/// TODO(서버): 출입 스캔 기반 실시간 인원 API 가 붙으면 지운다
struct BranchCongestion {
    let branch: String
    let capacity: Int
    let updatedLabel: String
    /// 오늘 시간대별 인원. `startHour` 부터 1시간 간격
    let hourly: [Int]
    let startHour: Int
    let nowHour: Int

    /// 영업 시간 밖이면 양 끝으로 붙인다 (새벽에 열어도 그래프가 깨지지 않게)
    var nowIndex: Int { min(max(nowHour - startHour, 0), hourly.count - 1) }

    /// 지금 인원은 그래프와 **같은 값**을 쓴다. 둘이 다르면 어느 쪽도 못 믿는다
    var people: Int { hourly[nowIndex] }

    var ratio: Double { min(max(Double(people) / Double(capacity), 0), 1) }

    var level: CongestionLevel {
        switch ratio {
        case ..<0.4: .low
        case ..<0.75: .medium
        default: .high
        }
    }

    /// 앞으로 몇 시간 안에 가장 한산한 때 — 이 카드가 실제로 하는 일.
    ///
    /// **하루 전체에서 고르지 않는다.** 그러면 늘 문 닫기 직전을 찍는데, 그건 갈 수 있는 시간이 아니다.
    var hint: String {
        let last = hourly.count - 2
        guard nowIndex + 1 <= min(nowIndex + Self.hintHours, last) else { return "오늘은 곧 문을 닫아요" }
        let window = (nowIndex + 1)...min(nowIndex + Self.hintHours, last)
        guard let best = window.min(by: { hourly[$0] < hourly[$1] }) else { return "오늘은 곧 문을 닫아요" }
        if hourly[best] >= people { return "지금이 한동안 제일 한산해요" }
        return "\(Self.clockLabel(startHour + best))쯤 가장 한산해요"
    }

    /// 몇 시간 앞까지 추천할지. 이보다 멀면 "그때 가야지" 가 아니라 그냥 정보다
    private static let hintHours = 6

    /// `14` → `오후 2시`
    private static func clockLabel(_ hour: Int) -> String {
        switch hour {
        case ..<12: "오전 \(hour)시"
        case 12: "낮 12시"
        default: "오후 \(hour - 12)시"
        }
    }
}

/// 실시간 혼잡도 (DESIGN.md §6.15).
///
/// 홈이 답해야 하는 질문은 **"지금 갈까?"** 다. 여기에 정면으로 답하는 카드다.
/// 숫자를 세우고, 색은 시맨틱(상태)으로 낸다 — 라임 예산과 무관하다 (§3.2).
private struct CongestionSection: View {
    let congestion: BranchCongestion

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            Text("실시간 혼잡도")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            CongestionCard(congestion: congestion)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }
}

private struct CongestionCard: View {
    let congestion: BranchCongestion

    var body: some View {
        // TODO: 시간대별 혼잡도 상세(🔵)가 생기면 카드를 누를 수 있게 한다
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Text(congestion.branch)
                    .font(MyFisFont.bodySm)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(congestion.updatedLabel)
                    .font(MyFisFont.caption)
            }
            .foregroundStyle(MyFisColor.textTertiary)
            .padding(.bottom, MyFisSpacing.xs)

            // **판단을 먼저 준다.** 숫자는 그 판단의 근거로 밑에 깐다
            HStack(spacing: MyFisSpacing.sm) {
                Text(congestion.level.headline)
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.textPrimary)
                // 상태는 **색과 글자 둘 다**로 낸다. 색만으로 구분하면 색각 이상에서 읽히지 않는다
                Text(congestion.level.label)
                    .font(MyFisFont.label)
                    .foregroundStyle(congestion.level.color)
                    .padding(.horizontal, MyFisSpacing.sm)
                    .padding(.vertical, 2)
                    .background(congestion.level.color.opacity(0.14), in: Capsule())
            }

            Text("\(congestion.people) / \(congestion.capacity)명")
                .font(MyFisFont.bodySm.monospacedDigit())
                .foregroundStyle(MyFisColor.textTertiary)

            HourlyChart(congestion: congestion, color: congestion.level.color)
                .padding(.top, MyFisSpacing.lg)

            Text(congestion.hint)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
                .padding(.top, MyFisSpacing.md)
        }
        .padding(MyFisSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            MyFisColor.surface1,
            in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        )
    }
}

/// 오늘 시간대별 혼잡 막대.
///
/// 지금 몇 명인지보다 **"언제 가면 한산한지"** 가 실제로 쓰는 정보다.
/// 지금 막대만 상태색이고 나머지는 흐린 회색 — 그래야 지금이 어디쯤인지 한눈에 뜬다.
private struct HourlyChart: View {
    let congestion: BranchCongestion
    let color: Color

    private var peak: Double { Double(max(congestion.hourly.max() ?? 1, 1)) }

    var body: some View {
        VStack(spacing: MyFisSpacing.sm) {
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array(congestion.hourly.enumerated()), id: \.offset) { index, people in
                    Capsule()
                        .fill(index == congestion.nowIndex ? color : MyFisColor.surface3)
                        .frame(maxWidth: .infinity)
                        // 가장 한산한 시간도 막대가 보여야 한다 (0 이면 빈칸으로 읽힌다)
                        .frame(height: Self.height * min(max(Double(people) / peak, 0.12), 1))
                }
            }
            .frame(height: Self.height, alignment: .bottom)

            HStack(spacing: 3) {
                ForEach(congestion.hourly.indices, id: \.self) { index in
                    label(at: index)
                        // `지금` 은 한 칸(≈14pt)보다 넓다. 칸을 넘겨서라도 온전히 보이게 한다
                        .fixedSize()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    private func label(at index: Int) -> some View {
        let hour = congestion.startHour + index
        // 눈금은 3시간마다. 전부 적으면 숫자가 붙어 읽히지 않는다.
        // `지금` 은 옆 칸까지 넘어오므로 양옆 눈금은 지운다 (겹쳐 찍힌다)
        let tick = hour % 3 == 0 && abs(index - congestion.nowIndex) > 1

        if index == congestion.nowIndex {
            Text("지금")
                .font(MyFisFont.caption)
                .foregroundStyle(MyFisColor.textPrimary)
        } else if tick {
            Text("\(hour)")
                .font(MyFisFont.caption.monospacedDigit())
                .foregroundStyle(MyFisColor.textTertiary)
        } else {
            Color.clear.frame(width: 0, height: 0)
        }
    }

    private static let height: CGFloat = 64
}
