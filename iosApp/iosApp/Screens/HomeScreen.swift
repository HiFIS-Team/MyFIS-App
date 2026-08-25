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
            AppHeader(onNotification: onNotification)
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
            // TODO: 회원권 카드(②) · 마일리지가 아래에 붙는다 (SPEC H-01).
            Spacer(minLength: 0)
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
