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

    @State private var selected = Date()
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(onNotification: onNotification)
            HomeCalendar(selected: $selected, expanded: expanded)
                .padding(.top, MyFisSpacing.sm)
            CalendarBar(
                expanded: $expanded,
                streak: HomePlaceholder.attendanceStreak
            )
            .padding(.top, MyFisSpacing.xs)
            ShortcutRow(onDiet: onDiet, onCardio: onCardio)
                .padding(.top, MyFisSpacing.lg)
            // TODO: 회원권 카드 · 오늘 할 운동 · 마일리지가 붙으면 교체한다 (SPEC H-01).
            PlaceholderScreen(
                id: "H-01",
                title: "홈",
                description: "회원권 상태 · 오늘 할 운동 · 마일리지"
            )
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
                .padding(.horizontal, MyFisSpacing.sm)
                .padding(.vertical, MyFisSpacing.sm)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            HStack(spacing: MyFisSpacing.xs) {
                Image("ic_quest_attend")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(MyFisColor.textTertiary)
                Text("연속 출석")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
                Text("\(streak)일")
                    .font(MyFisFont.titleSm.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
            }
            .padding(.horizontal, MyFisSpacing.sm)
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }
}

enum HomePlaceholder {
    /// TODO(서버): 출석 기록이 붙으면 계산한다
    static let attendanceStreak = 12
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
