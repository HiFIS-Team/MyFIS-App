import SwiftUI

/// SPEC.md S-02 상품 상세 (DESIGN.md §6.21).
///
/// 이 화면이 답해야 하는 건 하나다 — **"이거 지금 바꿀 수 있나?"**
/// 그래서 가격 밑에 곧바로 교환 후 잔액(또는 부족분)을 붙이고, 하단 버튼이 같은 말을 반복한다.
struct StoreItemScreen: View {
    let item: StoreItem
    var balance: Int = StorePlaceholder.balance
    let onBack: () -> Void
    var onSearch: () -> Void = {}
    var onCart: () -> Void = {}
    var onExchange: () -> Void = {}

    @State private var liked = false

    private var short: Int { max(item.price - balance, 0) }

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        image
                        head
                        facts
                        reviews
                    }
                }
                // 시뮬레이터에는 스크롤을 시킬 수단이 없다. 아래쪽(리뷰)을 스크린샷으로 확인할 때
                // `SIMCTL_CHILD_MYFIS_HOME_SCROLL=bottom` 으로 띄운다 (홈과 같은 훅을 쓴다)
                .defaultScrollAnchor(HomeScroll.initialForDebug)
                buyBar
            }
            .ignoresSafeArea(edges: .top)

        }
        // 떠 있는 버튼은 **시스템 툴바**에 맡긴다 — iOS 26 이 알아서 유리 원으로 그리고,
        // 스크롤에도 고정되며 터치 타겟까지 맞춰 준다 (직접 그리면 굴절이 없어 유리로 안 보인다)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("뒤로")
            }
            // TODO: S-07 검색 · S-06 장바구니가 붙으면 연결한다
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onSearch) {
                    Image("ic_header_search")
                }
                .accessibilityLabel("검색")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onCart) {
                    Image("ic_header_cart")
                }
                .accessibilityLabel("장바구니")
            }
        }
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
    }

    /// 분류·이름·가격, 그리고 **바꿀 수 있는지**
    private var head: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Chip(label: item.category.label)
                Chip(label: "인기 \(popularityRank)위")
            }

            Text(item.name)
                .font(MyFisFont.titleLg)
                .foregroundStyle(MyFisColor.textPrimary)
                .padding(.top, MyFisSpacing.md)

            HStack(spacing: MyFisSpacing.sm) {
                Image("ic_mileage_fill")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(MyFisColor.accent)
                Text(item.price.mileage)
                    .font(MyFisFont.metricLg.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
            }
            .padding(.top, MyFisSpacing.sm)

            // 가격 바로 밑에서 **바꿀 수 있는지**를 답한다. 하단 버튼까지 내려가서 알 일이 아니다
            Text(availability)
                .font(MyFisFont.bodySm.monospacedDigit())
                .foregroundStyle(
                    short > 0 || item.soldOut ? MyFisColor.warning : MyFisColor.textSecondary
                )
                .padding(.top, MyFisSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.lg)
    }

    private var availability: String {
        if item.soldOut { return "지금은 품절이에요" }
        if short > 0 { return "\(short.mileage) 더 모으면 교환할 수 있어요" }
        return "교환하면 \((balance - item.price).mileage) 남아요"
    }

    /// 나머지 사실들. 한 줄에 하나씩, 라벨 폭을 고정해 값이 세로로 정렬된다
    private var facts: some View {
        VStack(spacing: 0) {
            divider
            FactRow(
                label: "평점 · 리뷰",
                value: "\(String(format: "%.1f", item.rating)) (\(item.reviewCount.decimal))",
                chevron: true
            )
            FactRow(label: "조회", value: item.views.viewCount)
            FactRow(label: "수령", value: "지점 데스크에서 받아요", chevron: true)
            FactRow(label: "교환권", value: "발급 후 7일 안에 수령")
            divider
        }
    }

    private var divider: some View {
        Rectangle().fill(MyFisColor.borderSubtle).frame(height: 1)
    }

    /// 리뷰 (DESIGN.md §6.21).
    ///
    /// **상품 설명은 두지 않는다.** 파워에이드가 뭔지 설명할 이유가 없다 —
    /// 사람들이 궁금한 건 "이거 받아보니 어땠나" 뿐이라 리뷰만 남긴다.
    private var reviews: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: MyFisSpacing.sm) {
                Text("리뷰")
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text("\(item.reviewCount.decimal)개")
                    .font(MyFisFont.bodySm.monospacedDigit())
                    .foregroundStyle(MyFisColor.textTertiary)
                    .padding(.bottom, 2)
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)

            HStack(spacing: MyFisSpacing.sm) {
                Stars(filled: Int(item.rating), size: 18)
                Text(String(format: "%.1f", item.rating))
                    .font(MyFisFont.titleMd.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)

            ForEach(StorePlaceholder.reviews) { review in
                divider
                ReviewRow(review: review)
            }
            divider

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
                .padding(.vertical, MyFisSpacing.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, MyFisSpacing.xl)
        .padding(.bottom, MyFisSpacing.md)
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

    var body: some View {
        Text(label)
            .font(MyFisFont.label)
            .foregroundStyle(MyFisColor.textSecondary)
            .padding(.horizontal, MyFisSpacing.sm)
            .padding(.vertical, MyFisSpacing.xs)
            .background(
                MyFisColor.surface2,
                in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
            )
    }
}

private struct FactRow: View {
    let label: String
    let value: String
    var chevron: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
                .frame(width: 88, alignment: .leading)
            Text(value)
                .font(MyFisFont.body.monospacedDigit())
                .foregroundStyle(MyFisColor.textPrimary)
                .lineLimit(1)
            Spacer(minLength: MyFisSpacing.sm)
            if chevron {
                Image("ic_chevron_down")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(MyFisColor.textTertiary)
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.md)
        .contentShape(Rectangle())
    }
}

private struct ReviewRow: View {
    let review: StoreReview

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Stars(filled: review.rating, size: 14)
                Text(review.author)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
                Text(review.date)
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textTertiary)
            }

            Text(review.body)
                .font(MyFisFont.body)
                .foregroundStyle(MyFisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, MyFisSpacing.sm)

            // TODO(서버): 도움 됐어요 집계가 붙으면 실제로 누르게 한다
            Button {} label: {
                Text("도움 됐어요 \(review.helpful)")
                    .font(MyFisFont.caption.monospacedDigit())
                    .foregroundStyle(MyFisColor.textSecondary)
                    .padding(.horizontal, MyFisSpacing.md)
                    .padding(.vertical, MyFisSpacing.sm)
                    .background(
                        MyFisColor.surface2,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, MyFisSpacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.lg)
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
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
