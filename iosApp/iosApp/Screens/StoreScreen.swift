import SwiftUI

/// SPEC.md S-01 스토어 홈. (레퍼런스: 토스 쇼핑)
///
/// 위에서부터 — 헤더(검색·장바구니·마이) · 카테고리 · 내 마일리지 · 배너 · 마일리지 모으기 · 상품 그리드.
///
/// **레퍼런스의 구조만 가져오고 색은 우리 것을 쓴다** (DESIGN.md §3.2).
/// 원본은 파랑·빨강 뱃지가 화면마다 튀지만, 우리는 다크 + 라임 하나다.
/// 이 화면에서 **라임은 내 마일리지 숫자 한 곳뿐** — 상품 가격까지 라임으로 칠하면
/// "지금 중요한 숫자" 라는 신호가 사라진다.
///
/// 헤더 아래(카테고리·마일리지)는 **스크롤해도 남는다** (S 공통 규칙 — 살 수 있는지 매번 계산하게 하지 않는다).
struct StoreScreen: View {
    /// 검색어. **헤더는 셸의 내비 바가 들고 있다** (§6.9 · §7.1) —
    /// 화면 안에 직접 그리면 잎이 밀려 들어올 때 헤더가 같이 밀려 흔들린다
    @Binding var query: String
    var onCart: () -> Void = {}
    var onMy: () -> Void = {}
    var onItem: (StoreItem) -> Void = { _ in }
    /// 검색 모드인지. 필드가 내비 바에 있으므로 셸이 알려 준다
    var isSearching = false

    @State private var category: StoreCategory = .all
    /// TODO(서버): 찜은 계정에 붙는다. 지금은 화면이 들고 있다
    @State private var liked: Set<Int> = []

    private var items: [StoreItem] {
        StorePlaceholder.items.filter { category == .all || $0.category == category }
    }

    private var results: [StoreItem] {
        StorePlaceholder.items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    private let columns = [
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
    ]

    private func toggleLike(_ id: Int) {
        if liked.contains(id) { liked.remove(id) } else { liked.insert(id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                SearchResults(
                    query: $query,
                    results: results,
                    balance: StorePlaceholder.balance,
                    liked: liked,
                    onLike: { toggleLike($0) },
                    onItem: onItem
                )
            } else {
                browse
            }
        }
    }

    /// 평소의 스토어 — 마일리지 띠부터 상품 그리드까지
    private var browse: some View {
        VStack(spacing: 0) {
            MileageBand(balance: StorePlaceholder.balance)

            ScrollView {
                // 필터는 **위에 붙는다.** 목록을 내려가다 카테고리를 바꾸려고 위로 되돌아가면 안 된다
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    BannerCarousel(banners: StorePlaceholder.banners)
                        .padding(.top, MyFisSpacing.sm)
                        .padding(.bottom, MyFisSpacing.lg)

                    Section {
                        LazyVGrid(columns: columns, spacing: MyFisSpacing.lg) {
                            ForEach(items) { item in
                                ItemCard(
                                    item: item,
                                    balance: StorePlaceholder.balance,
                                    liked: liked.contains(item.id),
                                    onLike: { toggleLike(item.id) },
                                    onTap: { onItem(item) }
                                )
                            }
                        }
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)
                        .padding(.top, MyFisSpacing.md)
                    } header: {
                        CategoryFilter(selected: $category)
                    }
                }
                .padding(.bottom, MyFisSpacing.xxxl)
            }
        }
    }
}

/// 스토어 검색 필드 — **내비 바 안**에 산다 (DESIGN.md §6.9).
///
/// 화면 콘텐츠로 그리면 잎 화면이 밀려 들어올 때 같이 밀려서 헤더가 흔들린다 (§7.1).
struct StoreSearchField: View {
    @Binding var query: String
    var focused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            Image("ic_header_search")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(MyFisColor.textTertiary)
            TextField(
                "",
                text: $query,
                prompt: Text("상품 검색").foregroundColor(MyFisColor.textTertiary)
            )
            .font(MyFisFont.bodySm)
            .foregroundStyle(MyFisColor.textPrimary)
            .focused(focused)
            .submitLabel(.search)
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image("ic_header_clear")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(MyFisColor.textTertiary)
                }
                .buttonStyle(.myFisTap)
                .accessibilityLabel("지우기")
            }
        }
        .padding(.horizontal, MyFisSpacing.md)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        // **알약이 아니라 모서리만 둥글다** (§6.9) — 안드로이드와 같은 값을 쓴다
        .background(
            MyFisColor.surface2,
            in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        )
    }
}

private struct SearchResults: View {
    @Binding var query: String
    let results: [StoreItem]
    let balance: Int
    let liked: Set<Int>
    let onLike: (Int) -> Void
    let onItem: (StoreItem) -> Void

    private let suggestions = ["음료", "프로틴", "타월", "보틀", "매트"]
    private let columns = [
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
    ]

    var body: some View {
        Group {
            if query.isEmpty {
                suggestionList
            } else if results.isEmpty {
                emptyState
            } else {
                grid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var suggestionList: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            Text("추천 검색어")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)
            FlowRow(items: suggestions) { word in
                Button {
                    query = word
                } label: {
                    Text(word)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .padding(.horizontal, MyFisSpacing.md)
                        .padding(.vertical, MyFisSpacing.sm)
                        .background(MyFisColor.surface2, in: Capsule())
                }
                .buttonStyle(.myFisTap)
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.top, MyFisSpacing.lg)
    }

    private var emptyState: some View {
        VStack(spacing: MyFisSpacing.md) {
            Text("\u{2018}\(query)\u{2019} 검색 결과가 없어요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
            Button("검색어 지우기") { query = "" }
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textPrimary)
                .buttonStyle(.myFisTap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: MyFisSpacing.lg) {
                ForEach(results) { item in
                    ItemCard(
                        item: item,
                        balance: balance,
                        liked: liked.contains(item.id),
                        onLike: { onLike(item.id) },
                        onTap: { onItem(item) }
                    )
                }
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.top, MyFisSpacing.lg)
            .padding(.bottom, MyFisSpacing.xxxl)
        }
        // 스크롤을 시작하면 키보드를 내린다 — 결과를 보려는 참이다
        .scrollDismissesKeyboard(.immediately)
    }
}

/// 칩을 줄 바꿔 흘려 놓는다. 개수가 적어 `Layout` 까지 만들지 않는다.
private struct FlowRow<Item: Hashable, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            ForEach(items, id: \.self) { content($0) }
        }
    }
}

/// 시뮬레이터에는 키보드를 칠 수단이 마땅치 않다. 검색 모드를 스크린샷으로 확인할 때
/// `SIMCTL_CHILD_MYFIS_SEARCH=1` (빈 검색) 또는 `=음료` (결과) 로 띄운다.
enum StoreSearch {
    /// 검색 모드는 이제 **시스템 검색 바**가 켠다. 여기서는 검색어만 심어 준다
    static var initialQueryForDebug: String {
        #if DEBUG
        let value = ProcessInfo.processInfo.environment["MYFIS_SEARCH"] ?? ""
        return value == "1" ? "" : value
        #else
        return ""
        #endif
    }
}


/// 배너 — 옆 장이 살짝 보이게 두고 넘긴다. 몇 장 중 몇 번째인지 오른쪽 아래에 적는다.
///
/// `contentMargins` 로 좌우를 물려 두면 다음 장이 자연스럽게 걸친다 —
/// `TabView(.page)` 는 화면 폭을 꽉 채워서 이 모양이 안 나온다.
///
/// **5초마다 저절로 넘어가고, 끝에서 되감지 않는다.** 배너 목록을 여러 바퀴 미리 깔아 두고
/// 가운데서 시작하면 계속 같은 방향으로 흐른다 — 마지막에서 처음으로 되튀면 눈에 걸린다.
///
/// **손을 대면 멈춘다.** 떼고 나서 다시 5초를 센다 (읽는 중에 넘어가면 안 된다).
private struct BannerCarousel: View {
    let banners: [StoreBanner]

    /// 한 장 = 배너 하나가 몇 바퀴째에 놓였는지까지 포함한 자리. `id` 가 겹치면 스크롤 위치를 못 잡는다
    private struct Slide: Identifiable, Hashable {
        let id: Int
        let banner: StoreBanner
    }

    /// 5초에 한 장씩이면 200바퀴는 사실상 끝이 없다
    private static let cycles = 200
    private static let interval: Duration = .seconds(5)
    private static let height: CGFloat = 168

    private let slides: [Slide]
    private let start: Int

    @State private var position: Int?
    /// 손을 대고 있거나 아직 미끄러지는 중
    @State private var touching = false

    init(banners: [StoreBanner]) {
        self.banners = banners
        slides = (0..<(Self.cycles * banners.count)).map {
            Slide(id: $0, banner: banners[$0 % banners.count])
        }
        start = (Self.cycles / 2) * banners.count
        _position = State(initialValue: start)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: MyFisSpacing.md) {
                ForEach(slides) { slide in
                    card(slide)
                        .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: MyFisSpacing.md)
                        .id(slide.id)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, MyFisSpacing.screenHorizontal, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $position)
        .frame(height: Self.height)
        .modifier(PauseWhileTouching(touching: $touching))
        // 자리가 바뀌거나 손을 떼면 타이머를 처음부터 다시 센다
        .task(id: Tick(position: position ?? start, touching: touching)) {
            guard !touching else { return }
            try? await Task.sleep(for: Self.interval)
            guard !Task.isCancelled, let current = position, current + 1 < slides.count else { return }
            withAnimation(MyFisMotion.slow) { position = current + 1 }
        }
    }

    private struct Tick: Equatable {
        let position: Int
        let touching: Bool
    }

    private func card(_ slide: Slide) -> some View {
        ZStack {
            MyFisColor.surface1

            // 사진이 없으므로 우리 벡터를 크게 깔아 자리를 잡는다.
            // TODO(서버): 배너 이미지가 오면 교체한다.
            Image(slide.banner.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 144, height: 144)
                .foregroundStyle(MyFisColor.surface3)
                .offset(x: 18)
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(alignment: .leading, spacing: MyFisSpacing.sm) {
                Text(slide.banner.title)
                    .font(MyFisFont.titleLg)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text(slide.banner.body)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(MyFisSpacing.cardPadding)

            Text("\(slide.id % banners.count + 1) / \(banners.count)")
                .font(MyFisFont.caption.monospacedDigit())
                .foregroundStyle(MyFisColor.textSecondary)
                .padding(.horizontal, MyFisSpacing.sm)
                .padding(.vertical, 2)
                .background(MyFisColor.surface3, in: Capsule())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(MyFisSpacing.md)
        }
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.lg, style: .continuous))
    }
}

/// 스크롤이 멈춰 있을 때만 자동 넘김을 돌린다.
///
/// `onScrollPhaseChange` 는 iOS 18+ 다. 그 아래에서는 자동 넘김만 하고 멈춤 판정을 못 한다 —
/// 손으로 넘기면 자리가 바뀌면서 타이머가 다시 시작되므로 크게 어긋나지는 않는다.
private struct PauseWhileTouching: ViewModifier {
    @Binding var touching: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.onScrollPhaseChange { _, phase in
                touching = phase != .idle
            }
        } else {
            content
        }
    }
}

/// 카테고리 필터 (레퍼런스: 무신사 탭).
///
/// 알약이 아니라 **글자 + 밑줄**이다. 상품 목록 위에서는 알약이 시각적으로 너무 무겁고,
/// 여기서 고른 것은 "지금 보고 있는 목록"이라 제목처럼 읽혀야 한다.
///
/// 밑줄은 칸을 따라 **흐른다** — 글자의 자식이 아니라 **위치를 재서** 옮긴다 (Android 와 같은 방식).
/// `matchedGeometryEffect` 로 하면 이동이 우리 애니메이션을 타지 않아 속도를 못 정한다 (확인함).
private struct CategoryFilter: View {
    @Binding var selected: StoreCategory

    @State private var frames: [StoreCategory: CGRect] = [:]

    private static let space = "storeFilter"

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(StoreCategory.allCases) { category in
                    let isSelected = category == selected
                    Button {
                        // ⚠️ withAnimation 을 쓰면 **아래 그리드까지** 트랜잭션에 걸려
                        // 상품이 한 장씩 제각각 나타난다 (Android 는 그냥 갈린다).
                        selected = category
                    } label: {
                        Text(category.label)
                            .font(isSelected ? MyFisFont.titleSm : MyFisFont.body)
                            .foregroundStyle(isSelected ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                            // 글자 자체를 잰다 — 패딩까지 재면 밑줄이 글자보다 넓어진다
                            .background {
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: TabFrames.self,
                                        value: [category: geo.frame(in: .named(Self.space))]
                                    )
                                }
                            }
                            .padding(.horizontal, MyFisSpacing.sm)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.myFisTap)
                }
            }
            .coordinateSpace(.named(Self.space))
            .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
            .overlay(alignment: .bottomLeading) {
                Rectangle()
                    .fill(MyFisColor.textPrimary)
                    .frame(width: frames[selected]?.width ?? 0, height: 2)
                    .offset(x: (frames[selected]?.minX ?? 0) + MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
                    // 고르는 동작이라 `fast`(120ms). `base`(200ms) 는 감속 커브 때문에 끝이 끌린다
                    .animation(MyFisMotion.fast, value: selected)
            }
            .onPreferenceChange(TabFrames.self) { frames = $0 }
        }
        // 스티키 헤더라 배경이 불투명해야 아래 카드가 비쳐 지나가지 않는다
        .background(MyFisColor.bgBase)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(MyFisColor.borderSubtle)
                .frame(height: 1)
        }
    }
}

/// 각 카테고리 글자가 어디서 시작해 얼마나 넓은지 — 밑줄을 그리려면 이게 있어야 한다
private struct TabFrames: PreferenceKey {
    static let defaultValue: [StoreCategory: CGRect] = [:]

    static func reduce(
        value: inout [StoreCategory: CGRect],
        nextValue: () -> [StoreCategory: CGRect]
    ) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// 상품 카드 (레퍼런스: 토스 쇼핑).
///
/// **카드 높이는 모두 같다.** 원본은 제목 줄 수에 따라 카드가 들쭉날쭉한데,
/// 그러면 그리드가 어긋나 보인다 — 제목을 **두 줄로 고정**해 자리를 미리 잡아 둔다.
///
/// 제목과 마일리지 사이에 **몇 명이 봤는지 · 평점(리뷰 수)** 을 둔다.
/// 배송 문구(내일도착 같은 것)는 없다 — 여기 상품은 **지점에서 받는다.**
///
/// **부족해도 가리지 않는다** (SPEC S-01) — 얼마가 모자란지 적어 목표로 삼게 한다. 품절도 마찬가지다.
private struct ItemCard: View {
    let item: StoreItem
    let balance: Int
    let liked: Bool
    let onLike: () -> Void
    let onTap: () -> Void

    private var short: Int { max(0, item.price - balance) }
    private var dimmed: Bool { item.soldOut }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            image
            VStack(alignment: .leading, spacing: 0) {
                Text(item.name)
                    .font(MyFisFont.body)
                    .foregroundStyle(dimmed ? MyFisColor.textTertiary : MyFisColor.textPrimary)
                    // 두 줄로 고정해야 카드 높이가 서로 같다
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)

                meta
                    .padding(.top, 2)

                HStack(spacing: 0) {
                    Text(item.price.mileage)
                        .font(MyFisFont.titleSm.monospacedDigit())
                        .foregroundStyle(dimmed ? MyFisColor.textTertiary : MyFisColor.textPrimary)
                    Spacer(minLength: 0)
                    LikeButton(liked: liked, action: onLike)
                }
                .padding(.top, MyFisSpacing.sm)
            }
            .padding(MyFisSpacing.md)
        }
        .background(MyFisColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private var image: some View {
        ZStack {
            MyFisColor.surface2
            // TODO(서버): 상품 이미지가 오면 교체한다. 지금은 자리만 잡는다.
            Image("ic_tab_store")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .foregroundStyle(MyFisColor.surface3)

            if item.soldOut || short > 0 {
                Text(item.soldOut ? "품절" : "\(short.mileage) 부족")
                    .font(MyFisFont.caption)
                    .foregroundStyle(item.soldOut ? MyFisColor.textSecondary : MyFisColor.textTertiary)
                    .padding(.horizontal, MyFisSpacing.sm)
                    .padding(.vertical, 2)
                    .background(
                        MyFisColor.surface3,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(MyFisSpacing.sm)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    /// 몇 명이 봤는지 · 평점(리뷰 수) — 제목과 가격 사이
    private var meta: some View {
        HStack(spacing: 3) {
            Image("ic_store_views")
                .resizable()
                .frame(width: 13, height: 13)
            Text(item.views.viewCount)
                .font(MyFisFont.caption.monospacedDigit())
            // 구분은 점이 아니라 **세로선**이다. 점은 조회수 숫자에 묻힌다
            Rectangle()
                .fill(MyFisColor.borderStrong)
                .frame(width: 1, height: 10)
                .padding(.horizontal, 2)
            Image("ic_store_rating")
                .resizable()
                .frame(width: 11, height: 11)
            Text("\(String(format: "%.1f", item.rating)) (\(item.reviewCount.decimal))")
                .font(MyFisFont.caption.monospacedDigit())
                .lineLimit(1)
        }
        .foregroundStyle(MyFisColor.textTertiary)
    }

}

/// 찜. 카드 전체를 누르면 상세로 가므로 여기만 따로 눌리게 한다 (DESIGN.md §6.12).
struct LikeButton: View {
    let liked: Bool
    let action: () -> Void
    /// 터치 영역. 상세 화면의 하단 바처럼 크게 써야 하는 자리가 있다
    var box: CGFloat = 28
    var icon: CGFloat = 20

    var body: some View {
        Button(action: action) {
            Image(liked ? "ic_store_like_fill" : "ic_store_like")
                .resizable()
                .frame(width: icon, height: icon)
                .foregroundStyle(liked ? MyFisColor.like : MyFisColor.textTertiary)
                // 색이 차는 건 **즉시**여야 한다. 바깥에서 걸린 애니메이션이 여기까지 흘러오면
                // 하트가 늦게 채워진다 (그리는 건 빠른데 색만 뒤늦게 번지는 것처럼 보였다)
                .animation(nil, value: liked)
                .frame(width: box, height: box)
                // 튀고 고리가 퍼지는 반응은 리뷰의 `도움 됐어요` 와 **같은 것**을 쓴다 (§6.21)
                .burst(active: liked, color: MyFisColor.like)
                .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
        .accessibilityLabel(liked ? "찜 해제" : "찜하기")
    }
}
