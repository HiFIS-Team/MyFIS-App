import SwiftUI

/// SPEC.md C-01 유산소 탭 (DESIGN.md §6.28).
///
/// **보러 오는 건 숫자다.** 기기가 비었는지는 고개만 들면 보인다 —
/// 그래서 맨 위가 `이번 주 누적`이고, 기기 현황은 **한 줄**이다.
///
/// ⚠️ 원래 명세는 `유산소 시작`(기기 목록 + 스캔)이었는데 **탭 하나를 차지할 무게가
/// 아니었다.** 웨이트 탭은 AI 주간 루틴 세션인데 여기가 기계 목록이면 둘의 무게가 안 맞는다.
/// 기록(C-05)을 마이 메뉴에서 이 탭으로 끌어올렸다.
struct CardioScreen: View {
    /// 지점 지도(M-08) — `카디오존 보기`가 여기로 간다
    var onBranch: () -> Void = {}
    /// C-05 유산소 기록
    var onHistory: () -> Void = {}
    /// C-02 기기 NFC 스캔
    var onScan: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: MyFisSpacing.sectionGap) {
                    WeekSummary(week: CardioPlaceholder.week)
                    AvailableRow(counts: CardioPlaceholder.available, onTap: onBranch)
                    RecentSessions(rows: CardioPlaceholder.recent, onMore: onHistory)
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.lg)
                .padding(.bottom, MyFisSpacing.xxxl)
            }

            // ④ **화면당 주요 액션은 이 하나뿐**이다 (§2 원칙 5).
            // 엄지가 닿는 아래에 못 박는다 (원칙 2) — 스크롤을 따라 올라가지 않는다
            MyFisPrimaryButton(title: "기기 스캔하기", action: onScan)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// **아이콘 줄이다** — 탭 화면에는 글자 제목을 두지 않는다 (§6.9).
    ///
    /// 지점 이름을 둔 건 제목이 아니라 **값**이라서다 — 빈 기기 수가 어느 지점 것인지
    /// 밝히지 않으면 아래 한 줄을 믿을 수 없다.
    private var header: some View {
        HStack(spacing: 0) {
            Button(action: onBranch) {
                HStack(spacing: MyFisSpacing.xs) {
                    Image("ic_header_branch")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(MyFisColor.textSecondary)
                    Text(CardioPlaceholder.branch)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textSecondary)
                }
                .padding(.horizontal, MyFisSpacing.sm)
                .frame(height: MyFisSize.buttonSmall)
                .contentShape(Rectangle())
            }
            .buttonStyle(.myFisTap)

            Spacer(minLength: 0)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }
}

// MARK: - ① 이번 주 누적

/// 이 화면의 주인공. **숫자가 제일 크다** (§2 원칙 1).
///
/// ⚠️ 진행률 고리를 안 붙인다 — **주간 목표가 아직 없다.**
/// 없는 채로 눈금만 두면 **채울 수 없는 눈금**이 된다 (SPEC C-01).
private struct WeekSummary: View {
    let week: CardioWeek

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("이번 주")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)

            HStack(alignment: .lastTextBaseline, spacing: MyFisSpacing.sm) {
                Text(week.distance)
                    .font(MyFisFont.metricLg)
                    .foregroundStyle(MyFisColor.accent)
                Text("km")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
            .padding(.top, MyFisSpacing.xs)

            // 지난주가 없으면 아예 뺀다. `+0.0` 은 정보가 아니라 잡음이다
            if let delta = week.delta {
                Text(delta)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
                    .padding(.top, MyFisSpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - ② 지금 비어 있어요

/// **한 줄이다.** 번호 칩을 늘어놓으면 화면은 차는데 어디 있는지는 여전히 모른다 —
/// `런닝머신 3번`이 어느 자리인지 아는 사람은 이미 그 헬스장을 아는 사람이다.
/// 숫자만 두고 **위치는 지도(M-08)에 맡긴다.**
private struct AvailableRow: View {
    let counts: [CardioCount]
    let onTap: () -> Void

    var body: some View {
        MyFisCard {
            Text("지금 비어 있어요")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)

            HStack(spacing: MyFisSpacing.md) {
                ForEach(counts) { count in
                    HStack(alignment: .lastTextBaseline, spacing: MyFisSpacing.xs) {
                        Text(count.name)
                            .font(MyFisFont.body)
                            .foregroundStyle(MyFisColor.textPrimary)
                        Text("\(count.free)")
                            .font(MyFisFont.metricMd)
                            .foregroundStyle(MyFisColor.textPrimary)
                    }
                }
            }
            .padding(.top, MyFisSpacing.sm)

            // Ghost 다. Primary 처럼 보이면 화면에 주요 액션이 둘이 된다 (§2 원칙 5)
            Button(action: onTap) {
                HStack(spacing: MyFisSpacing.xs) {
                    Text("카디오존 보기")
                    // 오른쪽 꺾쇠는 **아래 꺾쇠를 돌려 쓴다** — 집 안에서 쓰는 방식이다
                    Image("ic_chevron_down")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(-90))
                }
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: MyFisSize.minTouchTarget, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.myFisTap)
            .padding(.top, MyFisSpacing.xs)
        }
    }
}

// MARK: - ③ 최근 기록

/// 최근 셋만. 전부 보려면 C-05 로 간다 — **여기가 그 화면의 본진 입구**다
private struct RecentSessions: View {
    let rows: [CardioSessionRow]
    let onMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Text("최근 기록")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)

                Spacer(minLength: 0)

                Button(action: onMore) {
                    Text("전체 보기")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.myFisTap)
            }

            ForEach(rows) { row in
                HStack(spacing: MyFisSpacing.md) {
                    Text(row.date)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .frame(width: 42, alignment: .leading)

                    Text(row.machine)
                        .font(MyFisFont.body)
                        .foregroundStyle(MyFisColor.textPrimary)

                    Spacer(minLength: MyFisSpacing.sm)

                    // 거리와 시간은 **자리를 맞춘다.** 줄마다 흔들리면 훑어 읽지 못한다
                    Text(row.amount)
                        .font(MyFisFont.body)
                        .monospacedDigit()
                        .foregroundStyle(MyFisColor.textPrimary)
                    Text(row.duration)
                        .font(MyFisFont.bodySm)
                        .monospacedDigit()
                        .foregroundStyle(MyFisColor.textTertiary)
                }
                .frame(height: MyFisSize.listRowMin)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 보여 주기용 값

struct CardioWeek {
    let distance: String
    /// 지난주 대비. 지난주가 없으면 `nil`
    let delta: String?
}

struct CardioCount: Identifiable {
    let name: String
    let free: Int
    var id: String { name }
}

struct CardioSessionRow: Identifiable {
    let date: String
    let machine: String
    let amount: String
    let duration: String
    var id: String { date + machine }
}

/// TODO: 서버가 붙으면 갈아끼운다 (C-01). `천국의 계단` 이름은 **지점마다 다르다**
enum CardioPlaceholder {
    static let branch = "MyFIS 강남점"

    static let week = CardioWeek(distance: "12.4", delta: "지난주보다 +2.1km")

    static let available = [
        CardioCount(name: "런닝머신", free: 4),
        CardioCount(name: "천국의 계단", free: 2),
    ]

    static let recent = [
        CardioSessionRow(date: "8/26", machine: "런닝머신", amount: "3.2km", duration: "24분"),
        CardioSessionRow(date: "8/24", machine: "천국의 계단", amount: "1.1km", duration: "18분"),
        CardioSessionRow(date: "8/22", machine: "런닝머신", amount: "4.0km", duration: "31분"),
    ]
}
