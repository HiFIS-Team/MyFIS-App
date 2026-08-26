import SwiftUI

/// SPEC.md P-01 혜택 홈 (DESIGN.md §6.24).
///
/// 레퍼런스는 **카카오뱅크 혜택 탭**이다 — 제목 + 요약이 한 줄, 배너 하나,
/// 그 아래 **동그란 아이콘 + `~하고` / `~받기`** 두 줄짜리 행 목록.
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

    /// 제목 + 요약 두 개. **탭 화면인데 제목을 다는 유일한 자리다** —
    /// 홈·스토어와 달리 헤더에 넣을 아이콘이 없고, 요약 숫자가 제목 역할을 대신하지도 못한다
    private var header: some View {
        HStack(spacing: 0) {
            Text("혜택")
                .font(MyFisFont.titleLg)
                .foregroundStyle(MyFisColor.textPrimary)
            Spacer(minLength: MyFisSpacing.md)

            Button(action: onHistory) {
                HStack(spacing: MyFisSpacing.sm) {
                    HStack(spacing: MyFisSpacing.xs) {
                        Image("ic_mileage_fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(MyFisColor.accent)
                        MileageText(BenefitPlaceholder.balance)
                            .font(MyFisFont.titleSm)
                    }

                    // 두 숫자를 가르는 선. 같은 무게로 나란히 두면 어느 쪽이 잔액인지 안 갈린다
                    Rectangle()
                        .fill(MyFisColor.borderSubtle)
                        .frame(width: 1, height: 14)

                    Text("이번 달 ")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        + Text("+\(BenefitPlaceholder.earnedThisMonth.decimal) P")
                        .font(MyFisFont.bodySm.monospacedDigit())
                        .foregroundStyle(MyFisColor.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.myFisTap)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
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

/// 적립 경로 한 줄 — 동그란 아이콘 + `~하고` / `~받기`.
///
/// **제목이 행동, 부제가 보상이다.** 반대로 두면 다 똑같이 "P 받기"로 시작해 구분이 안 된다.
private struct ActionRow: View {
    let action: BenefitAction
    let onTap: () -> Void

    private var dimmed: Bool { action.done }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MyFisSpacing.lg) {
                Image(action.icon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 26, height: 26)
                    .foregroundStyle(dimmed ? MyFisColor.textTertiary : MyFisColor.textPrimary)
                    .frame(width: MyFisSize.listRowMin, height: MyFisSize.listRowMin)
                    .background(MyFisColor.surface2, in: Circle())

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

/// 적립 경로 한 줄 (SPEC P-01).
struct BenefitAction: Identifiable, Hashable {
    let id: Int
    let icon: String
    /// 행동 — `출석하고`
    let title: String
    /// 보상 — `+50 P 받기`
    let reward: String
    /// `이벤트` · `신규` · `인기`. 없으면 `nil`
    var badge: String?
    /// 오늘 이미 받았다
    var done: Bool = false
}

/// TODO(서버): 적립 단가·상태는 서버가 준다 (SPEC §8). 하드코딩하지 않는다
enum BenefitPlaceholder {
    static let balance = 1_240
    static let earnedThisMonth = 320

    static let actions: [BenefitAction] = [
        .init(id: 1, icon: "ic_quest_attend", title: "출석하고", reward: "+50 P 받기"),
        .init(id: 2, icon: "ic_tab_weight", title: "루틴 끝내고", reward: "+80 P 받기"),
        .init(id: 3, icon: "ic_tab_cardio", title: "유산소 하고", reward: "10분마다 +10 P"),
        .init(id: 4, icon: "ic_quest_board", title: "도장 찍고", reward: "7일 채우면 +200 P", badge: "이벤트"),
        .init(id: 5, icon: "ic_tab_group", title: "옆 사람 터치하고", reward: "+10 P 받기", badge: "신규"),
        .init(id: 6, icon: "ic_quest_scale", title: "체중 재고", reward: "+20 P 받기", badge: "인기"),
        .init(id: 7, icon: "ic_quest_camera", title: "식단 찍고", reward: "+20 P 받기", done: true),
    ]
}
