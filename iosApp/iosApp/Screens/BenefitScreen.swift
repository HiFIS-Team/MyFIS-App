import SwiftUI

/// SPEC.md P-01 혜택 홈 (DESIGN.md §6.24).
///
/// 레퍼런스는 **카카오뱅크 혜택 탭**이다 — 제목 + 요약이 한 줄, 배너 하나,
/// 그 아래 **둥근 네모 아이콘 판 + `~하고` / `~받기`** 두 줄짜리 행 목록.
/// **구조만 가져오고 색은 우리 것을 쓴다** (§3.2) — 원본은 뱃지마다 색이 다르지만
/// 우리는 다크 + 라임 하나다.
///
/// 이 탭이 답하는 질문은 하나 — **"오늘 더 받을 수 있는 게 뭐지"**.
/// 잔액을 자랑하는 화면이 아니다 (그건 스토어 §6.12 가 한다).
struct BenefitScreen: View {
    /// TODO: P-02 적립 내역이 붙으면 연결한다
    var onHistory: () -> Void = {}
    var onAction: (BenefitAction) -> Void = { _ in }

    private var todo: [BenefitAction] { BenefitPlaceholder.actions.filter { !$0.done } }
    private var done: [BenefitAction] { BenefitPlaceholder.actions.filter(\.done) }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    InviteBanner()
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)

                    Section("바로 받아요", rows: todo, onTap: onAction)
                        .padding(.top, MyFisSpacing.sectionGap)

                    if !done.isEmpty {
                        Section("오늘 받았어요", rows: done, onTap: onAction)
                            .padding(.top, MyFisSpacing.sectionGap)
                    }
                }
                .padding(.bottom, MyFisSpacing.xxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// **아이콘 줄이다** — 다른 탭 헤더(§6.9)와 같은 골격.
    ///
    /// 글자 제목을 달지 않는다. 탭 화면에 제목을 두는 건 우리 규칙이 아니고,
    /// **마일리지 칩이 이미 "여기는 P를 모으는 곳"이라고 말한다** (스토어 띠 §6.12 와 같은 칩).
    private var header: some View {
        HStack(spacing: 0) {
            Button(action: onHistory) {
                MileageChip(balance: BenefitPlaceholder.balance)
            }
            .buttonStyle(.myFisTap)
            .padding(.leading, MyFisSpacing.sm)

            Spacer(minLength: MyFisSpacing.md)

            HeaderIcon("ic_header_history", "적립 내역", action: onHistory)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }
}

/// 제목 + 행 묶음. 행 사이에 선을 긋지 않는다 — 아이콘이 이미 줄을 나눈다
private struct Section: View {
    let title: String
    let rows: [BenefitAction]
    let onTap: (BenefitAction) -> Void

    init(_ title: String, rows: [BenefitAction], onTap: @escaping (BenefitAction) -> Void) {
        self.title = title
        self.rows = rows
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.sm)

            ForEach(rows) { row in
                ActionRow(action: row, onTap: { onTap(row) })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 적립 경로 한 줄 — 둥근 네모 아이콘 판 + `~하고` / `~받기`.
///
/// **제목이 행동, 부제가 보상이다.** 반대로 두면 다 똑같이 "P 받기"로 시작해 구분이 안 된다.
private struct ActionRow: View {
    let action: BenefitAction
    let onTap: () -> Void

    private var dimmed: Bool { action.done }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MyFisSpacing.lg) {
                // 색은 **갈래**를 말한다 (§3.1 카테고리 팔레트) — **아이콘에만** 칠한다.
                // 판은 색 없는 중립이다 — 열두 줄이 색 판이면 목록이 색 견본집처럼 읽힌다
                icon
                    .frame(width: MyFisSize.listRowMin, height: MyFisSize.listRowMin)
                    .background(
                        dimmed ? MyFisColor.surface1 : MyFisColor.surface2,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                    )
                    // 테두리 한 줄이 판을 **타일**로 만든다 — 없으면 배경에 녹는다
                    .overlay(
                        RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                            .strokeBorder(MyFisColor.borderSubtle, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: MyFisSpacing.sm) {
                        Text(action.title)
                            .font(MyFisFont.titleSm)
                            .foregroundStyle(dimmed ? MyFisColor.textTertiary : MyFisColor.textPrimary)
                        if let badge = action.badge, !dimmed {
                            Badge(badge)
                        }
                    }
                    Text(dimmed ? "오늘 받았어요" : action.reward)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }

    /// 행 아이콘은 **전부 원색 그림**이라 tint 를 걸지 않는다 — 한 색으로 누르면 실루엣이 된다.
    /// 받은 행에서는 색을 빼야 하는데 칠할 수가 없으니 **채도를 0 으로 내린다**
    private var icon: some View {
        Image(action.icon)
            .resizable()
            .frame(width: 28, height: 28)
            .saturation(dimmed ? 0 : 1)
            .opacity(dimmed ? 0.5 : 1)
    }
}

/// 행 뱃지 — **글자만 다르고 색은 하나다** (§3.2).
/// 레퍼런스는 노랑·빨강·파랑을 섞지만, 색이 셋이면 목록이 알림함처럼 종류별 색 목록으로 읽힌다
private struct Badge: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(MyFisFont.caption)
            .foregroundStyle(MyFisColor.textSecondary)
            .padding(.horizontal, MyFisSpacing.sm)
            .padding(.vertical, 2)
            .background(MyFisColor.surface3, in: Capsule())
    }
}

/// 배너 — **마일리지가 늘어나는 유일한 '내가 하는' 길**이라 맨 위에 둔다 (S-08 과 같은 판단).
private struct InviteBanner: View {
    var body: some View {
        // TODO: 초대 링크 공유가 붙으면 연결한다
        Button {} label: {
            HStack(spacing: MyFisSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("친구를 부르면")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                    Text("둘 다 1,000 P")
                        .font(MyFisFont.titleMd)
                        .foregroundStyle(MyFisColor.textPrimary)
                }
                Spacer(minLength: 0)
                Image("ic_mileage_fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(MyFisColor.surface3)
            }
            .padding(MyFisSpacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(
                MyFisColor.surface1,
                in: RoundedRectangle(cornerRadius: MyFisRadius.lg, style: .continuous)
            )
        }
        .buttonStyle(.myFisTap)
    }
}

/// 적립 활동 종류 — 목록에서 **색으로 구분한다** (§3.1 카테고리 팔레트).
///
/// **행마다 색이 다르다.** 아홉 줄이 같은 회색이면 목록이 덩어리로 보이고,
/// 색을 몇 개로 묶으면 "왜 이 둘만 같은 색이지"를 먼저 묻게 된다.
enum BenefitKind {
    case attend, routine, cardio, stretch, water, dice, luck, scratch, quiz, touch, sns, weight, diet

    var color: Color {
        switch self {
        case .attend: MyFisColor.categoryGold
        case .routine: MyFisColor.categoryLime
        case .cardio: MyFisColor.categoryBlue
        case .stretch: MyFisColor.categoryViolet
        case .water: MyFisColor.categoryCyan
        case .dice: MyFisColor.categoryOrange
        case .luck: MyFisColor.categoryTeal
        case .scratch: MyFisColor.categoryFuchsia
        case .quiz: MyFisColor.categoryIndigo
        case .touch: MyFisColor.categoryGreen
        case .sns: MyFisColor.categoryPink
        case .weight: MyFisColor.categoryCoral
        /// 아홉 번째만 무채색이다 — 색을 하나 더 만드는 대신 **이미 받은 자리**에 중립색을 뒀다.
        /// 어차피 받은 행은 톤을 낮춰 회색으로 그린다
        case .diet: MyFisColor.categoryGray
        }
    }

}

/// 적립 경로 한 줄 (SPEC P-01).
struct BenefitAction: Identifiable, Hashable {
    let id: Int
    let kind: BenefitKind
    let icon: String
    /// 행동 — `출석하고`
    let title: String
    /// 보상 — `+50 P 받기`
    let reward: String
    /// `이벤트` · `신규` · `인기`. 없으면 `nil`
    var badge: String?
    /// 오늘 이미 받았다
    var done: Bool = false
    /// 활동 랜딩(§6.25)에서 쓸 글리프. `nil` 이면 행과 같은 것을 쓴다.
    /// 행만 원색으로 갈아 끼울 때 쓴다 — 랜딩은 아직 두 톤 벌이다
    var introIcon: String?

    /// 랜딩에 띄울 글리프
    var glyph: String { introIcon ?? icon }
    /// 그 글리프를 **자기 색 그대로** 그릴지. 두 톤 벌로 되돌린 자리는 다시 칠해야 한다
    var glyphKeepsColor: Bool { introIcon == nil }
}

/// TODO(서버): 적립 단가·상태는 서버가 준다 (SPEC §8). 하드코딩하지 않는다
enum BenefitPlaceholder {
    static let balance = 1_240
    static let earnedThisMonth = 320

    static let actions: [BenefitAction] = [
        .init(id: 1, kind: .attend, icon: "ic_benefit_attend_color", title: "출석하고",
              reward: "+50 P 받기", introIcon: "ic_benefit_attend"),
        .init(id: 2, kind: .routine, icon: "ic_benefit_routine_color", title: "루틴 끝내고",
              reward: "+80 P 받기", introIcon: "ic_benefit_routine"),
        .init(id: 3, kind: .cardio, icon: "ic_benefit_cardio_color", title: "유산소 하고",
              reward: "10분마다 +10 P", introIcon: "ic_benefit_cardio"),
        .init(id: 4, kind: .stretch, icon: "ic_benefit_stretch_color", title: "스트레칭하고",
              reward: "+20 P 받기", introIcon: "ic_benefit_stretch"),
        .init(id: 5, kind: .water, icon: "ic_benefit_water_color", title: "물 마시고",
              reward: "8잔 채우면 +50 P", introIcon: "ic_benefit_water"),
        // 랜딩에도 이 그림을 그대로 쓴다 — 주사위는 두 톤 벌이 아예 없다
        .init(id: 6, kind: .dice, icon: "ic_benefit_dice_color", title: "주사위 굴리고",
              reward: "나온 눈만큼 P 받기"),
        .init(id: 7, kind: .luck, icon: "ic_benefit_luck_color", title: "뽑기 돌리고",
              reward: "랜덤 P 받기", badge: "이벤트", introIcon: "ic_benefit_luck"),
        // 주사위 · 뽑기 바로 뒤에 둔다 — **운으로 받는 셋**이 한 덩어리로 읽힌다
        .init(id: 13, kind: .scratch, icon: "ic_benefit_scratch_color", title: "카드 긁고",
              reward: "숨은 P 받기"),
        .init(id: 8, kind: .quiz, icon: "ic_benefit_quiz", title: "AI 퀴즈 풀고",
              reward: "+30 P 받기"),
        .init(id: 9, kind: .touch, icon: "ic_benefit_touch_color", title: "옆 사람 터치하고",
              reward: "+10 P 받기", badge: "신규", introIcon: "ic_benefit_touch"),
        .init(id: 10, kind: .sns, icon: "ic_benefit_sns", title: "인스타에 올리고",
              reward: "+100 P 받기", badge: "인기"),
        .init(id: 11, kind: .weight, icon: "ic_benefit_scale_color", title: "체중 재고",
              reward: "+20 P 받기", introIcon: "ic_benefit_scale"),
        .init(id: 12, kind: .diet, icon: "ic_benefit_diet_color", title: "식단 찍고",
              reward: "+20 P 받기", done: true, introIcon: "ic_benefit_diet"),
    ]
}
