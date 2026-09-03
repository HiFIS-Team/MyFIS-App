import ImageIO
import SwiftUI
import UIKit

/// SPEC.md C-01 유산소 탭 (DESIGN.md §6.28).
///
/// 레퍼런스는 **버핏그라운드 유산소 탭**이다 (사용자 지정).
/// **뼈대만 가져오고 색은 우리 것을 쓴다** (§3.2) — 원본은 카드 아홉 장을 형광 초록으로
/// 채우지만 우리는 판을 어둡게 두고 **진행바에만 라임**을 쓴다 (§2 원칙 3).
///
/// 이 탭이 답하는 질문은 둘 — **"이번 달 얼마나 뛰었지"** 와 **"다음에 뭘 하면 되지"**.
/// 한때 `이번 주 누적 → 빈 기기 → 최근 기록` 이었는데(§6.28 구안), 그건 **다 본 뒤에
/// 할 일이 없는 화면**이었다. 미션이 그 자리를 메운다.
struct CardioScreen: View {
    var onStore: () -> Void = {}
    // TODO(C-03): 태그를 읽으면 `운동 중` 으로 넘긴다. 지금은 시스템 시트에서 끝난다

    @State private var tab: CardioMissionTab = .daily

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        monthCard
                        shortcutRow
                            .padding(.top, MyFisSpacing.cardGap)
                        missionTabs
                            .padding(.top, MyFisSpacing.sectionGap)
                        MissionGrid(tab: tab)
                            .padding(.top, MyFisSpacing.lg)
                    }
                    .padding(.horizontal, MyFisSpacing.screenHorizontal)
                    // 알약이 마지막 줄을 가리지 않게 그만큼 비워 둔다
                    .padding(.bottom, MyFisSize.buttonSecondary + MyFisSpacing.xxxl)
                }

                // 이 화면의 액션은 이 하나뿐 (§2 원칙 5) — 엄지가 닿는 자리에 둔다 (원칙 2).
                // 폭을 다 쓰면 **떠 있는 탭 바와 둥근 덩어리가 둘로 겹치므로** 알약으로 맞춘다 (§6.28)
                MyFisPrimaryButton(title: "유산소 시작하기", pill: true,
                                   action: { CardioScanner.shared.start() })
                    .padding(.bottom, MyFisSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// **누구의 기록인지 밝히는 줄이다.**
    ///
    /// 다른 탭 헤더(§6.9)는 아이콘만 두지만 여기는 **내 몸의 기록**이라 이름이 앞에 온다.
    /// 사진을 얼굴이 아니라 **색 원 + 첫 글자**로 대신한다 — P-07 레이더와 같은 규칙이다
    /// (SPEC P-07 프라이버시: 실명·사진을 쓰지 않는다).
    private var header: some View {
        HStack(spacing: MyFisSpacing.md) {
            Text(CardioPlaceholder.name.prefix(1))
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.textPrimary)
                .frame(width: MyFisSize.chip, height: MyFisSize.chip)
                .background(MyFisColor.surface3, in: Circle())

            Text(CardioPlaceholder.name)
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)

            Spacer(minLength: MyFisSpacing.md)

            MileageChip(balance: BenefitPlaceholder.balance)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }

    /// 이번 달 누적 — **이 화면의 주인공**이다 (§2 원칙 1).
    ///
    /// 주가 아니라 **달**로 센다 (2026-09-02 수정, 사용자 지정 레퍼런스) —
    /// 유산소는 주 단위로 보면 0인 주가 흔해서 **숫자가 자주 비어 보인다.**
    private var monthCard: some View {
        MyFisCard(radius: MyFisRadius.lg) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: MyFisSpacing.sm) {
                        Image("ic_tab_cardio")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(MyFisColor.textSecondary)
                        Text("이번 달")
                            .font(MyFisFont.label)
                            .foregroundStyle(MyFisColor.textSecondary)
                    }
                    Text(CardioPlaceholder.monthKm)
                        .font(MyFisFont.metricXl)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .padding(.top, MyFisSpacing.md)
                    Text("km / month")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                }
                Spacer(minLength: MyFisSpacing.md)
                // 브랜드 마크는 **우리 도장**이다 — 원본의 네온 방패 자리
                Image("ic_stamp")
                    .resizable()
                    .frame(width: 72, height: 72)
            }

            HStack(spacing: MyFisSpacing.md) {
                Text("지금까지 \(CardioPlaceholder.monthKm)km 달렸어요")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
                Spacer(minLength: 0)
                Chevron()
            }
            .padding(.top, MyFisSpacing.lg)
        }
    }

    /// 뱃지 · 주문 — 원본의 `BADGE` / `ORDER` 두 칸. 좁은 칸 하나 + 넓은 칸 하나다
    private var shortcutRow: some View {
        WeightedRow(weights: [5, 8], spacing: MyFisSpacing.cardGap) {
            MyFisCard {
                Text("TIER")
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .frame(maxWidth: .infinity)
                Image("ic_stamp")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .frame(maxWidth: .infinity)
                    .padding(.top, MyFisSpacing.md)
                Text(CardioPlaceholder.tier)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, MyFisSpacing.md)
            }
            .frame(maxHeight: .infinity)

            Button(action: onStore) {
                MyFisCard {
                    // 꺾쇠는 **얹는다** — 줄 안에 끼우면 가운데 글자가 왼쪽으로 밀린다
                    Text("ORDER")
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .trailing) { Chevron() }
                    AnimatedDrink()
                        .frame(width: 48, height: 48)
                        .frame(maxWidth: .infinity)
                        .padding(.top, MyFisSpacing.md)
                    Text("운동하고 마실 것 주문하기")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, MyFisSpacing.md)
                }
                .frame(maxHeight: .infinity)
            }
            .buttonStyle(.myFisTap)
        }
    }

    /// 미션 갈래 줄 — `일간` · `주간` · `월간`.
    ///
    /// **밑줄이 칸을 따라 흐른다** — 스토어 카테고리(§6.12)와 같은 규칙이다.
    /// 다만 스토어는 칸 폭이 제각각이라 **위치를 재야** 하지만,
    /// 여기는 셋이 폭을 고르게 나눠 가지므로 **순번만 알면** 자리가 나온다.
    ///
    /// 고른 것은 색이 아니라 밑줄로 알린다 — 라임은 진행바와 버튼의 몫이다.
    private var missionTabs: some View {
        let tabs = CardioMissionTab.allCases
        let index = tabs.firstIndex(of: tab) ?? 0

        return HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { item in
                Button {
                    tab = item
                } label: {
                    Text(item.title)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(item == tab ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MyFisSpacing.md)
                }
                .buttonStyle(.myFisTap)
            }
        }
        // 바닥 줄이 세 칸을 하나로 묶는다 — 없으면 막대가 허공에서 움직인다
        .overlay(alignment: .bottom) {
            MyFisColor.borderSubtle.frame(height: 1)
        }
        .overlay(alignment: .bottomLeading) {
            GeometryReader { geo in
                let slot = geo.size.width / CGFloat(tabs.count)
                MyFisColor.textPrimary
                    .frame(width: slot, height: 2)
                    .offset(x: slot * CGFloat(index), y: geo.size.height - 2)
            }
            // 고르는 동작이라 `fast`(120ms) 다 — 스토어 밑줄과 같은 값 (§7)
            .animation(MyFisMotion.fast, value: tab)
        }
    }
}

/// 폭을 **비율로** 나누는 가로줄.
///
/// SwiftUI 에는 Compose 의 `weight` 가 없다 — `layoutPriority` 는 순서만 정하지 비율을 못 정한다.
/// `WaterTimeScreen` 의 `FlowLayout` 과 같은 방식으로 `Layout` 을 직접 짠다.
struct WeightedRow: Layout {
    let weights: [CGFloat]
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let total = proposal.width ?? 0
        let widths = widths(in: total)
        // 두 칸 높이를 맞춘다 — 더 높은 쪽에 낮은 쪽을 맞춘다
        let height = zip(subviews, widths)
            .map { $0.sizeThatFits(.init(width: $1, height: nil)).height }
            .max() ?? 0
        return CGSize(width: total, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        for (view, width) in zip(subviews, widths(in: bounds.width)) {
            view.place(
                at: CGPoint(x: x, y: bounds.minY),
                proposal: .init(width: width, height: bounds.height)
            )
            x += width + spacing
        }
    }

    private func widths(in total: CGFloat) -> [CGFloat] {
        let gaps = spacing * CGFloat(max(weights.count - 1, 0))
        let usable = max(total - gaps, 0)
        let sum = weights.reduce(0, +)
        guard sum > 0 else { return weights.map { _ in 0 } }
        return weights.map { usable * $0 / sum }
    }
}

/// 미션 칸 세 줄짜리 격자. 줄 수가 적어 `LazyVGrid` 를 쓰지 않는다 (화면이 통째로 스크롤한다)
private struct MissionGrid: View {
    let tab: CardioMissionTab

    private var rows: [[CardioMission]] {
        let items = CardioPlaceholder.missions.filter { $0.tab == tab }
        return stride(from: 0, to: items.count, by: 3).map {
            Array(items[$0 ..< min($0 + 3, items.count)])
        }
    }

    var body: some View {
        VStack(spacing: MyFisSpacing.cardGap) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top, spacing: MyFisSpacing.cardGap) {
                    ForEach(row) { MissionCard(mission: $0) }
                    // 마지막 줄이 덜 찼으면 빈 칸으로 채운다 — 남은 칸이 늘어나면 안 된다
                    ForEach(0 ..< (3 - row.count), id: \.self) { _ in
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

/// 미션 한 칸.
///
/// ⚠️ **판을 라임으로 채우지 않는다.** 원본은 칸을 통째로 형광 초록으로 채우는데,
/// 그러면 아홉 칸이 전부 액센트라 **어느 것도 강조가 아니게 된다** (§2 원칙 3).
/// 라임은 **진행바 한 줄**에만 준다 — 그게 이 칸에서 유일하게 변하는 값이다.
private struct MissionCard: View {
    let mission: CardioMission

    var body: some View {
        MyFisCard {
            Image(mission.icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(MyFisColor.textSecondary)
                .frame(maxWidth: .infinity)
            Text(mission.title)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textPrimary)
                .lineLimit(1)
                .padding(.top, MyFisSpacing.md)
            Text(mission.progress)
                .font(MyFisFont.caption)
                .foregroundStyle(MyFisColor.textTertiary)
                .lineLimit(1)
                .padding(.top, 2)
            MyFisProgress(value: mission.ratio)
                .padding(.top, MyFisSpacing.md)
        }
    }
}

/// `ORDER` 칸의 움직이는 잔 (사용자 제공, 2026-09-03).
///
/// **플랫폼이 주는 디코더를 그대로 쓴다** (§2 원칙 6) — `ImageIO` 가 움직이는 WebP 의
/// 프레임을 풀어 주고 `UIImageView` 가 돌린다. 그림 라이브러리를 붙이지 않는다.
///
/// ⚠️ 원본 GIF 는 **알파가 없어** 흰 바탕이 통째로 들어 있었다. 어두운 판에 얹으면 흰 네모가 된다 —
/// 모서리에서 번지는 흰 영역만 지우고(잔 안의 흰 하이라이트는 살린다) **알파 있는 WebP** 로 다시 구웠다.
struct AnimatedDrink: UIViewRepresentable {
    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView(image: Self.image)
        view.contentMode = .scaleAspectFit
        // 카드가 폭을 정하므로 이미지가 제 크기를 주장하면 안 된다
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}

    /// 프레임을 푸는 건 한 번이면 된다 — 칸이 다시 그려질 때마다 풀지 않는다
    private static let image: UIImage? = load("ic_order_drink")

    private static func load(_ name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "webp"),
              let data = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(data as CFData, nil)
        else { return nil }

        var frames: [UIImage] = []
        var total: TimeInterval = 0
        for index in 0 ..< CGImageSourceGetCount(source) {
            guard let cg = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            frames.append(UIImage(cgImage: cg))
            total += delay(source, index)
        }
        guard !frames.isEmpty else { return nil }
        return UIImage.animatedImage(with: frames, duration: total)
    }

    /// 프레임 간격은 파일이 들고 있다. 못 읽으면 우리가 구운 값(80ms)으로 둔다
    private static func delay(_ source: CGImageSource, _ index: Int) -> TimeInterval {
        guard let all = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let webp = all[kCGImagePropertyWebPDictionary] as? [CFString: Any],
              let value = (webp[kCGImagePropertyWebPUnclampedDelayTime]
                           ?? webp[kCGImagePropertyWebPDelayTime]) as? TimeInterval,
              value > 0
        else { return 0.08 }
        return value
    }
}

/// 오른쪽 꺾쇠 — 아래 꺾쇠를 돌려 쓴다 (§6.28 구안과 같은 방법)
private struct Chevron: View {
    var body: some View {
        Image("ic_chevron_down")
            .renderingMode(.template)
            .resizable()
            .frame(width: 20, height: 20)
            .rotationEffect(.degrees(-90))
            .foregroundStyle(MyFisColor.textTertiary)
    }
}

/// 미션 갈래 (SPEC C-01)
enum CardioMissionTab: CaseIterable {
    case daily, weekly, monthly

    var title: String {
        switch self {
        case .daily: "일간"
        case .weekly: "주간"
        case .monthly: "월간"
        }
    }
}

/// 미션 한 칸 (SPEC C-01)
struct CardioMission: Identifiable {
    let id: Int
    let tab: CardioMissionTab
    let icon: String
    let title: String
    /// `0.4Km / 1Km` 처럼 **얼마나 남았는지**를 그대로 적는다
    let progress: String
    let ratio: Double
}

// TODO(서버): 이름·누적·미션 달성은 서버가 준다 (SPEC §8). 하드코딩하지 않는다
enum CardioPlaceholder {
    static let name = "은후"
    static let monthKm = "12.4"
    /// 🔵 등급 체계는 아직 없다 — 자리만 잡아 둔 것이다
    static let tier = "실버"

    static let missions: [CardioMission] = [
        .init(id: 1, tab: .daily, icon: "ic_place_cardio",
              title: "오늘 3km", progress: "0.4Km / 3Km", ratio: 0.13),
        .init(id: 2, tab: .daily, icon: "ic_place_machine",
              title: "계단 10분", progress: "0분 / 10분", ratio: 0),
        .init(id: 3, tab: .daily, icon: "ic_quest_attend",
              title: "오늘 출석", progress: "1일 / 1일", ratio: 1),
        .init(id: 4, tab: .daily, icon: "ic_quest_board",
              title: "기록 남기기", progress: "0회 / 1회", ratio: 0),
        .init(id: 5, tab: .monthly, icon: "ic_tab_cardio",
              title: "이번 달 30km", progress: "12.4Km / 30Km", ratio: 0.41),
        .init(id: 6, tab: .monthly, icon: "ic_quest_attend",
              title: "12일 채우기", progress: "5일 / 12일", ratio: 0.42),
        .init(id: 7, tab: .monthly, icon: "ic_tab_ranking",
              title: "랭킹 100위", progress: "142위 / 100위", ratio: 0.7),
        .init(id: 8, tab: .weekly, icon: "ic_tab_cardio",
              title: "이번 주 5km", progress: "3.2Km / 5Km", ratio: 0.64),
        .init(id: 9, tab: .weekly, icon: "ic_quest_attend",
              title: "3일 나오기", progress: "2일 / 3일", ratio: 0.66),
        .init(id: 10, tab: .weekly, icon: "ic_place_machine",
              title: "계단 20분", progress: "0분 / 20분", ratio: 0),
    ]
}
