import SwiftUI

/// SPEC.md S-02 상품 상세 (DESIGN.md §6.21).
///
/// 이 화면이 답해야 하는 건 하나다 — **"이거 지금 바꿀 수 있나?"**
/// 그래서 가격 밑에 곧바로 교환 후 잔액(또는 부족분)을 붙이고, 하단 버튼이 같은 말을 반복한다.
struct StoreItemScreen: View {
    let item: StoreItem
    var balance: Int = StorePlaceholder.balance
    var onBack: () -> Void = {}
    var onSearch: () -> Void = {}
    var onCart: () -> Void = {}
    var onExchange: () -> Void = {}

    @State private var liked = false
    /// 이미지를 지나면 아이콘 밑으로 **글자가 지나간다.** 그때부터 바탕을 깔아 준다
    @State private var scrolledPastImage = false

    private var short: Int { max(item.price - balance, 0) }

    var body: some View {
        ZStack(alignment: .top) {
            MyFisColor.bgBase.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        image
                        head
                        facts
                        reviews
                        suggestions
                    }
                }
                // 시뮬레이터에는 스크롤을 시킬 수단이 없다. 아래쪽(리뷰)을 스크린샷으로 확인할 때
                // `SIMCTL_CHILD_MYFIS_HOME_SCROLL=bottom` 으로 띄운다 (홈과 같은 훅을 쓴다)
                .defaultScrollAnchor(MyFisDebug.homeScrollAnchor)
                .coordinateSpace(.named(Self.scrollSpace))
                buyBar
            }
            .ignoresSafeArea(edges: .top)

            floatingBar
        }
    }

    /// 떠 있는 버튼 줄 — 이미지 위에 얹힌다. **스크롤을 따라가지 않는다**
    /// (내려 읽다가 뒤로가기가 사라지면 안 된다).
    ///
    /// 사진 위에서는 바탕이 없고, 이미지를 지나 **글자가 아이콘 밑으로 들어오면** 바탕을 켠다.
    private var floatingBar: some View {
        HeaderBar {
            HeaderIcon("ic_tab_back", "뒤로", action: onBack)
        } center: {
            EmptyView()
        } trailing: {
            HStack(spacing: 0) {
                HeaderIcon("ic_header_search", "검색", action: onSearch)
                HeaderIcon("ic_header_cart", "장바구니", action: onCart)
            }
        }
        .background(MyFisColor.bgBase.opacity(scrolledPastImage ? 1 : 0))
        .animation(MyFisMotion.base, value: scrolledPastImage)
    }

    /// 상품 이미지. 위 버튼들은 이미지 **위에 떠 있다** — 이미지를 화면 끝까지 쓰기 위해서다
    private var image: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .background(MyFisColor.surface2)
            .overlay {
                // TODO(서버): 상품 이미지가 오면 교체한다
                Image("ic_tab_store")
                    .resizable()
                    .frame(width: 96, height: 96)
                    .foregroundStyle(MyFisColor.surface3)
            }
            // 이미지 밑단이 툴바까지 올라오면 그때부터 바탕을 켠다.
            // `onScrollGeometryChange` 는 iOS 18 부터라 좌표계로 잰다 (배포 타깃 17)
            .overlay {
                GeometryReader { geometry in
                    Color.clear.onChange(
                        of: geometry.frame(in: .named(Self.scrollSpace)).maxY < 120,
                        initial: true
                    ) { _, past in
                        scrolledPastImage = past
                    }
                }
            }
    }

    /// 스크롤 좌표계 이름 — 이미지가 얼마나 올라갔는지 재는 데만 쓴다
    private static let scrollSpace = "storeItemScroll"

    /// 분류·이름·가격.
    ///
    /// 이름과 가격을 **한 줄에 마주 세운다.** 가격을 왼쪽 아래에 따로 두면
    /// 오른쪽이 통째로 비어 화면이 성겨 보인다.
    private var head: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Chip(label: item.category.label, dot: item.category.dotColor)
                // TODO: 분류 랭킹(🔵)이 붙으면 연결한다
                Chip(label: "인기 \(popularityRank)위", chevron: true)
            }

            HStack(spacing: MyFisSpacing.md) {
                Text(item.name)
                    .font(MyFisFont.titleLg)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                HStack(spacing: MyFisSpacing.xs) {
                    Image("ic_coin")
                        .resizable()
                        .frame(width: 22, height: 22)
                    MileageText(item.price)
                        .font(MyFisFont.metricMd)
                }
                .fixedSize()
            }
            .padding(.top, MyFisSpacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.lg)
    }

    /// 나머지 사실들.
    ///
    /// **카드로 담는다.** 위아래 선만 그으면 표처럼 보인다 (§6.19 · 리뷰와 같은 판단).
    /// 줄마다 아이콘을 둬 네 줄이 회색 덩어리로 뭉치지 않게 한다.
    private var facts: some View {
        VStack(spacing: 0) {
            FactRow(
                icon: "ic_store_rating",
                label: "리뷰",
                value: String(format: "%.1f", item.rating),
                sub: "(\(item.reviewCount.decimal))",
                // 별만 색을 가진다 — `rating` 은 상태가 아니라 평점 전용 색이다 (§3.1)
                iconTint: MyFisColor.rating,
                chevron: true
            )
            FactRow(icon: "ic_store_views", label: "조회", value: item.views.viewCount)
            // TODO(서버): 지점은 선택한 지점을 따라간다
            FactRow(icon: "ic_header_branch", label: "수령", value: "강남점 데스크", chevron: true)
            FactRow(icon: "ic_my_coupon", label: "교환권", value: "발급 후 7일 안에 수령")
        }
        .padding(.vertical, MyFisSpacing.sm)
        .background(
            MyFisColor.surface1,
            in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        )
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }

    private var divider: some View {
        Rectangle().fill(MyFisColor.borderSubtle).frame(height: 1)
    }

    /// 리뷰 (DESIGN.md §6.21).
    ///
    /// **상품 설명은 두지 않는다.** 파워에이드가 뭔지 설명할 이유가 없다 —
    /// 사람들이 궁금한 건 "이거 받아보니 어땠나" 뿐이라 리뷰만 남긴다.
    ///
    /// 요약 · 리뷰 · 모두 보기가 **한 장 안에** 있다. 장을 나누면 같은 이야기가 흩어져 보이고,
    /// `모두 보기` 는 카드 밖에 떨어져 어디로 가는 링크인지 모호해진다.
    private var reviews: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.cardGap) {
            HStack(alignment: .bottom, spacing: MyFisSpacing.sm) {
                Text("리뷰")
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text("\(item.reviewCount.decimal)개")
                    .font(MyFisFont.bodySm.monospacedDigit())
                    .foregroundStyle(MyFisColor.textTertiary)
                    .padding(.bottom, 2)
            }

            VStack(spacing: 0) {
                RatingSummary(item: item)
                ForEach(StorePlaceholder.reviews) { review in
                    cardDivider
                    ReviewRow(review: review)
                }
                cardDivider

                // TODO: 전체 리뷰 목록(🔵)이 붙으면 연결한다
                Button {} label: {
                    HStack(spacing: 0) {
                        Text("리뷰 \(item.reviewCount.decimal)개 모두 보기")
                            .font(MyFisFont.bodySm.monospacedDigit())
                        Image("ic_chevron_down")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .rotationEffect(.degrees(-90))
                    }
                    .foregroundStyle(MyFisColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MyFisSpacing.md)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.myFisTap)
            }
            .background(
                MyFisColor.surface1,
                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.top, MyFisSpacing.xl)
        .padding(.bottom, MyFisSpacing.md)
    }

    /// 카드 **안**의 구분선. 배경 위에 긋는 전체 폭 선과 다르다 — 한 장 안에서 항목을 가른다
    private var cardDivider: some View {
        Rectangle().fill(MyFisColor.borderSubtle).frame(height: 1)
    }

    /// 추천 상품 (§6.21).
    ///
    /// **가로 줄로 둔다.** 이미 긴 화면이라 격자로 깔면 리뷰가 저 위로 밀린다.
    /// 여기서 고르는 기준은 "지금 살 수 있나"가 아니라 **"비슷한 게 뭐 있나"** 라
    /// 마일리지가 모자란 상품도 가리지 않는다 (SPEC S-01 — 부족한 상품은 목표가 된다).
    private var suggestions: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("이런 것도 있어요")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: MyFisSpacing.cardGap) {
                    ForEach(recommendations) { SuggestionCard(item: $0) }
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
            }
            .padding(.top, MyFisSpacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, MyFisSpacing.xl)
        .padding(.bottom, MyFisSpacing.xxxl)
    }

    /// 추천 목록. **같은 분류를 먼저** 채우고 모자라면 많이 본 순으로 잇는다.
    ///
    /// TODO(서버): 추천은 서버가 고른다. 품절은 뺀다 — 추천해 놓고 못 바꾸면 헛걸음이다
    private var recommendations: [StoreItem] {
        let pool = StorePlaceholder.items
            .filter { $0.id != item.id && !$0.soldOut }
            .sorted { $0.views > $1.views }
        var ordered = pool.filter { $0.category == item.category }
        ordered += pool.filter { !ordered.contains($0) }
        return Array(ordered.prefix(6))
    }

    /// 하단 고정 바 (§6.21).
    ///
    /// **엄지가 닿는 자리**라 이 화면의 유일한 Primary 를 여기 둔다 (§2 원칙 2·5).
    /// 못 바꾸는 이유는 버튼 글자가 직접 말한다 — 비활성만 시키고 이유를 안 적으면 사용자가 막힌다.
    private var buyBar: some View {
        VStack(spacing: 0) {
            divider
            HStack(spacing: MyFisSpacing.sm) {
                // 스토어 그리드와 **같은 하트**를 쓴다 — 누를 때 반응(팝 + 고리)까지 같아야 한 앱으로 읽힌다
                LikeButton(
                    liked: liked,
                    action: { liked.toggle() },
                    box: Self.barIconBox,
                    icon: Self.barIconSize
                )
                BarIcon(icon: "ic_header_cart", label: "장바구니", tint: MyFisColor.textSecondary, action: onCart)
                MyFisPrimaryButton(
                    title: buyLabel,
                    isEnabled: !item.soldOut && short == 0,
                    action: onExchange
                )
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)
            .background(MyFisColor.bgBase)
        }
    }

    private var buyLabel: String {
        if item.soldOut { return "품절" }
        if short > 0 { return "\(short.mileage) 부족" }
        return "교환하기"
    }

    /// 하단 바 아이콘 — 사진처럼 크게. 작으면 엄지로 겨냥하기도 어렵다
    private static let barIconBox: CGFloat = 48
    private static let barIconSize: CGFloat = 28

    /// 같은 분류 안에서 몇 번째로 많이 봤는지. TODO(서버): 랭킹이 오면 지운다
    private var popularityRank: Int {
        let ranked = StorePlaceholder.items
            .filter { $0.category == item.category }
            .sorted { $0.views > $1.views }
        return (ranked.firstIndex { $0.id == item.id } ?? 0) + 1
    }
}

private struct Chip: View {
    let label: String
    var dot: Color? = nil
    var chevron: Bool = false

    var body: some View {
        HStack(spacing: MyFisSpacing.xs) {
            if let dot {
                Circle().fill(dot).frame(width: 6, height: 6)
            }
            Text(label)
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)
            if chevron {
                Image("ic_chevron_down")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(MyFisColor.textTertiary)
            }
        }
        .padding(.horizontal, MyFisSpacing.sm)
        .padding(.vertical, MyFisSpacing.xs)
        .background(
            MyFisColor.surface2,
            in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
        )
    }
}

extension StoreCategory {
    /// 분류 점 색 (§3.1 카테고리 팔레트).
    ///
    /// **점에만 칠한다.** 글자까지 칠하면 액션처럼 보이고, 팔레트 규칙(아이콘 전용)도 깨진다.
    var dotColor: Color {
        switch self {
        case .drink: MyFisColor.categoryBlue
        case .caffeine: MyFisColor.categoryGold
        case .protein: MyFisColor.categoryViolet
        case .goods: MyFisColor.categoryCoral
        case .all: MyFisColor.categoryGray
        }
    }
}

private struct FactRow: View {
    let icon: String
    let label: String
    let value: String
    var sub: String? = nil
    var iconTint: Color = MyFisColor.textTertiary
    var chevron: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Image(icon)
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(iconTint)
                .padding(.trailing, MyFisSpacing.sm)
            // 라벨 폭을 고정해 값이 **세로로 정렬**된다. `교환권` 이 가장 길어 그 폭에 맞춘다
            Text(label)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
                .lineLimit(1)
                .frame(width: 56, alignment: .leading)
            Text(value)
                .font(MyFisFont.body.monospacedDigit())
                .foregroundStyle(MyFisColor.textPrimary)
                .lineLimit(1)
            if let sub {
                Text(sub)
                    .font(MyFisFont.bodySm.monospacedDigit())
                    .foregroundStyle(MyFisColor.textTertiary)
                    .padding(.leading, MyFisSpacing.xs)
            }
            Spacer(minLength: MyFisSpacing.sm)
            if chevron {
                Image("ic_chevron_down")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(MyFisColor.textTertiary)
            }
        }
        .padding(.horizontal, MyFisSpacing.cardPadding)
        .padding(.vertical, MyFisSpacing.md)
        .contentShape(Rectangle())
    }
}

/// 평균 별점 + 분포.
///
/// **숫자를 주인공으로 세운다** (§2 원칙 1). 분포 막대는 회색으로 둔다 —
/// 별까지 금색, 막대까지 금색이면 요약이 시끄러워진다.
private struct RatingSummary: View {
    let item: StoreItem

    var body: some View {
        let breakdown = item.ratingBreakdown
        let peak = max(breakdown.max() ?? 1, 1)

        HStack(spacing: MyFisSpacing.lg) {
            VStack(spacing: 0) {
                Text(String(format: "%.1f", item.rating))
                    .font(MyFisFont.metricLg.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
                Stars(filled: Int(item.rating), size: 16)
            }

            VStack(spacing: 4) {
                ForEach(Array(breakdown.enumerated()), id: \.offset) { index, count in
                    BreakdownRow(
                        star: 5 - index,
                        count: count,
                        ratio: Double(count) / Double(peak)
                    )
                }
            }
        }
        .padding(MyFisSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct BreakdownRow: View {
    let star: Int
    let count: Int
    let ratio: Double

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            Text("\(star)")
                .font(MyFisFont.caption.monospacedDigit())
                .foregroundStyle(MyFisColor.textTertiary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(MyFisColor.surface3)
                    Capsule()
                        .fill(MyFisColor.textSecondary)
                        .frame(width: geo.size.width * min(max(ratio, 0), 1))
                }
            }
            .frame(height: 6)
            Text(count.decimal)
                .font(MyFisFont.caption.monospacedDigit())
                .foregroundStyle(MyFisColor.textTertiary)
                .frame(width: 34, alignment: .trailing)
        }
    }
}

/// 리뷰 한 건. 한 장 안에서 **구분선으로** 갈린다
private struct ReviewRow: View {
    let review: StoreReview

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Stars(filled: review.rating, size: 14)
                Text(review.author)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
                Spacer(minLength: 0)
                Text(review.date)
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textTertiary)
            }

            Text(review.body)
                .font(MyFisFont.body)
                .foregroundStyle(MyFisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, MyFisSpacing.sm)

            HelpfulButton(count: review.helpful)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, MyFisSpacing.sm)
        }
        .padding(MyFisSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 도움 됐어요 (§6.21).
///
/// 찜 하트와 **같은 반응**을 쓴다 (튀고 고리가 퍼진다) — 같은 종류의 행동이라서다.
/// 색만 다르다: 하트는 `like`, 여기는 `helpful`.
private struct HelpfulButton: View {
    let count: Int

    // TODO(서버): 도움 됐어요 집계가 붙으면 서버 값으로 바꾼다
    @State private var marked = false

    private var tint: Color { marked ? MyFisColor.helpful : MyFisColor.textSecondary }

    var body: some View {
        Button { marked.toggle() } label: {
            HStack(spacing: MyFisSpacing.xs) {
                Image("ic_store_helpful")
                    .resizable()
                    .frame(width: 15, height: 15)
                    // 고리가 글자에 닿지 않도록 아이콘보다 넉넉한 자리를 준다
                    .frame(width: 22, height: 22)
                    .burst(active: marked, color: MyFisColor.helpful)
                Text("\(count + (marked ? 1 : 0))")
                    .font(MyFisFont.caption.monospacedDigit())
            }
            .foregroundStyle(tint)
            // 색이 차는 건 **즉시**여야 한다 (하트와 같은 이유)
            .animation(nil, value: marked)
            .padding(.horizontal, MyFisSpacing.md)
            // 다른 칩과 **같은 높이**로 맞춘다 (§5.2). 전에는 상하 `6` 이라 34 였고
            // 그 값이 §5.1 스케일 밖이었다 — 여기만 **34 → 36** 으로 바뀐다 (2026-08-27)
            .frame(height: MyFisSize.chip)
            // 켜지면 배경도 같은 색 16% 로 든다 — 아이콘만 바뀌면 눌렀는지 스쳐 지나간다
            .background(
                marked ? MyFisColor.helpful.opacity(0.16) : MyFisColor.surface2,
                in: Capsule()
            )
        }
        .buttonStyle(.myFisTap)
        .accessibilityLabel(marked ? "도움 됐어요 취소" : "도움 됐어요")
    }
}

/// 별 다섯 개. 채운 별은 `rating`, 나머지는 표면색으로 남긴다
private struct Stars: View {
    let filled: Int
    let size: CGFloat

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<5, id: \.self) { index in
                Image("ic_store_rating")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundStyle(index < filled ? MyFisColor.rating : MyFisColor.surface3)
            }
        }
    }
}

private struct SuggestionCard: View {
    let item: StoreItem

    /// 카드 폭. **다음 장이 살짝 걸치도록** 잡는다 — 딱 떨어지면 더 있는 줄 모른다
    private static let width: CGFloat = 108

    var body: some View {
        // TODO: 상세 → 상세 이동이 붙으면 연결한다
        Button {} label: {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .background(MyFisColor.surface2)
                    .overlay {
                        // TODO(서버): 상품 이미지가 오면 교체한다
                        Image("ic_tab_store")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(MyFisColor.surface3)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
                Text(item.name)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(1)
                    .padding(.top, MyFisSpacing.sm)
                MileageText(item.price)
                    .font(MyFisFont.titleSm)
                    .padding(.top, 2)
            }
            .frame(width: Self.width, alignment: .leading)
        }
        .buttonStyle(.myFisTap)
    }
}

private struct BarIcon: View {
    let icon: String
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
        .accessibilityLabel(label)
    }
}
