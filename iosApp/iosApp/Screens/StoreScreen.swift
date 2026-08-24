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
    var onSearch: () -> Void = {}
    var onCart: () -> Void = {}
    var onMy: () -> Void = {}
    var onHistory: () -> Void = {}
    var onQuest: (StoreQuest) -> Void = { _ in }
    var onItem: (StoreItem) -> Void = { _ in }

    @State private var category: StoreCategory = .all

    /// 검색 모드 — 헤더가 화면을 통째로 가져간다 (검색 화면으로 따로 밀지 않는다)
    @State private var isSearching = StoreSearch.initialForDebug
    @State private var query = StoreSearch.initialQueryForDebug
    @FocusState private var searchFocused: Bool
    @Namespace private var glass

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

    var body: some View {
        VStack(spacing: 0) {
            StoreHeader(
                query: $query,
                isSearching: $isSearching,
                focused: $searchFocused,
                glass: glass,
                onCart: onCart,
                onMy: onMy,
                onSearch: onSearch
            )

            if isSearching {
                SearchResults(
                    query: $query,
                    results: results,
                    balance: StorePlaceholder.balance,
                    onItem: onItem
                )
            } else {
                browse
            }
        }
    }

    /// 평소의 스토어 — 카테고리부터 상품 그리드까지
    private var browse: some View {
        VStack(spacing: 0) {
            CategoryTabs(selected: $category)
            MileageStrip(balance: StorePlaceholder.balance, onHistory: onHistory)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    BannerCarousel(banners: StorePlaceholder.banners)
                        .padding(.top, MyFisSpacing.sm)

                    QuestSection(quests: StorePlaceholder.quests, onQuest: onQuest)
                        .padding(.top, MyFisSpacing.xxl)

                    SectionHeader(title: "추천 상품", chip: "내 지점")
                        // 상품은 지점별로 다를 수 있다 (SPEC S-01) — 무엇이 걸러진 목록인지 밝힌다
                        .padding(.top, MyFisSpacing.xxl)
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)

                    LazyVGrid(columns: columns, spacing: MyFisSpacing.lg) {
                        ForEach(items) { item in
                            ItemCard(item: item, balance: StorePlaceholder.balance) { onItem(item) }
                        }
                    }
                    .padding(.horizontal, MyFisSpacing.screenHorizontal)
                    .padding(.top, MyFisSpacing.md)
                }
                .padding(.bottom, MyFisSpacing.xxxl)
            }
        }
    }
}

/// 스토어 헤더 (DESIGN.md §6.9).
///
/// 검색이 폭을 다 먹고 오른쪽에 장바구니 · 마이만 둔다.
/// **워드마크를 넣지 않는다** — 검색이 들어오면 가운데 자리가 없다.
///
/// **검색을 누르면 화면을 옮기지 않고 헤더가 검색 모드로 늘어난다** (iOS 만, 2026-08-24).
/// 오른쪽 아이콘 자리는 **유리 `취소` 버튼**으로 바뀌고, 필드는 그만큼 늘어난다.
/// 화면을 새로 밀면 유리 탭 바가 다시 그려지며 한 번 깜빡인다 — 셸을 건드리지 않는 편이 낫다 (§7.1).
private struct StoreHeader: View {
    @Binding var query: String
    @Binding var isSearching: Bool
    @FocusState.Binding var focused: Bool
    let glass: Namespace.ID
    let onCart: () -> Void
    let onMy: () -> Void
    let onSearch: () -> Void

    var body: some View {
        // 유리끼리 서로를 인식해야 **모양이 이어지며** 바뀐다 — 그래서 컨테이너로 묶는다.
        // 컨테이너·유리는 iOS 26 부터라 그 아래에서는 그냥 알약으로 떨어진다.
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: MyFisSpacing.sm) { row }
            } else {
                row
            }
        }
        .frame(height: 56)
        // 아이콘의 터치 영역이 화면 여백만큼 튀어나오므로 그만큼 당겨 준다 (§6.9)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }

    private var row: some View {
        HStack(spacing: 0) {
            SearchField(query: $query, isSearching: $isSearching, focused: $focused, onEnter: onSearch)
                // 왼쪽은 헤더 여백까지 그대로 쓴다. 여백을 더 주면 필드만 안쪽으로 밀려 짧아 보인다
                .padding(.trailing, isSearching ? MyFisSpacing.sm : MyFisSpacing.xs)

            if isSearching {
                Button {
                    focused = false
                    query = ""
                    withAnimation(MyFisMotion.slow) { isSearching = false }
                } label: {
                    Text("취소")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .padding(.horizontal, MyFisSpacing.md)
                        .frame(height: 40)
                }
                .buttonStyle(.plain)
                .modifier(GlassMorph(id: Self.trailing, namespace: glass, filled: true))
            } else {
                HStack(spacing: 0) {
                    HeaderIcon("ic_header_cart", "장바구니", onCart)
                    HeaderIcon("ic_header_my", "마이", onMy)
                }
                .modifier(GlassMorph(id: Self.trailing, namespace: glass, filled: false))
            }
        }
    }

    /// 아이콘 묶음과 `취소` 가 **같은 자리**임을 알려 주는 이름. 이게 같아야 서로 바뀐다.
    private static let trailing = "storeHeaderTrailing"
}

/// 유리 하나. 같은 `id` 를 단 뷰끼리 **자리를 이어받으며** 바뀐다 (iOS 26+).
///
/// `filled` 는 유리 배경까지 입힐지 — `취소` 는 입히고, 아이콘 묶음은 자리만 잡는다.
/// iOS 25 이하에서는 유리가 없으므로 `surface.3` 알약으로 떨어진다.
private struct GlassMorph: ViewModifier {
    let id: String
    let namespace: Namespace.ID
    let filled: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if filled {
                content
                    .glassEffect(.regular.interactive(), in: SearchField.shape)
                    .glassEffectID(id, in: namespace)
                    .glassEffectTransition(.matchedGeometry)
            } else {
                content
                    .glassEffectID(id, in: namespace)
                    .glassEffectTransition(.matchedGeometry)
            }
        } else if filled {
            content.background(MyFisColor.surface3, in: SearchField.shape)
        } else {
            content
        }
    }
}

/// 평소에는 버튼처럼 보이지만, 누르면 **그 자리에서** 입력을 받는다.
///
/// 검색 모드가 아닐 때는 `disabled` 로 막아 두고 탭 제스처만 받는다 —
/// 그래야 스크롤 중에 실수로 키보드가 올라오지 않는다.
private struct SearchField: View {
    @Binding var query: String
    @Binding var isSearching: Bool
    @FocusState.Binding var focused: Bool
    let onEnter: () -> Void

    static let shape = RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            Image("ic_header_search")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(MyFisColor.textTertiary)

            ZStack(alignment: .leading) {
                if query.isEmpty {
                    Text("상품 검색")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                }
                TextField("", text: $query)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .focused($focused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    // 커서는 우리 액센트를 쓴다 — 시스템 파랑이 화면에서 유일한 색이 되면 안 된다
                    .tint(MyFisColor.accent)
                    .disabled(!isSearching)
            }

            if isSearching, !query.isEmpty {
                Button {
                    query = ""
                    focused = true
                } label: {
                    Image("ic_header_clear")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(MyFisColor.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("검색어 지우기")
            }
        }
        .padding(.horizontal, MyFisSpacing.md)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        // 알약이 아니라 **모서리만** 둥글다 (§6.9). 완전 라운드는 헤더에서 과하게 동그래 보인다
        .background(MyFisColor.surface2, in: Self.shape)
        .contentShape(Self.shape)
        .onTapGesture {
            guard !isSearching else { return }
            withAnimation(MyFisMotion.slow) { isSearching = true }
            focused = true
            onEnter()
        }
        .accessibilityLabel("상품 검색")
    }
}

/// 검색 모드의 본문.
///
/// - 아직 안 쳤으면 **추천 검색어**만 보여준다 (최근 검색어는 저장할 곳이 없다 — 🔵)
/// - 치는 동안 **결과가 바로 걸러진다.** 따로 확인 버튼을 두지 않는다
/// - 없으면 §6.10 대로 한 줄 + 액션 하나
private struct SearchResults: View {
    @Binding var query: String
    let results: [StoreItem]
    let balance: Int
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
                .buttonStyle(.plain)
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
                .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: MyFisSpacing.lg) {
                ForEach(results) { item in
                    ItemCard(item: item, balance: balance) { onItem(item) }
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
    static var initialForDebug: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["MYFIS_SEARCH"] != nil
        #else
        false
        #endif
    }

    static var initialQueryForDebug: String {
        #if DEBUG
        let value = ProcessInfo.processInfo.environment["MYFIS_SEARCH"] ?? ""
        return value == "1" ? "" : value
        #else
        return ""
        #endif
    }
}

/// 카테고리 — 고른 것만 알약이 채워진다. 하단 탭·캘린더와 같은 규칙이다 (색이 아니라 채움)
private struct CategoryTabs: View {
    @Binding var selected: StoreCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MyFisSpacing.xs) {
                ForEach(StoreCategory.allCases) { category in
                    let isSelected = category == selected
                    Button {
                        withAnimation(MyFisMotion.fast) { selected = category }
                    } label: {
                        Text(category.label)
                            .font(MyFisFont.titleSm)
                            .foregroundStyle(isSelected ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                            .padding(.horizontal, MyFisSpacing.md)
                            .padding(.vertical, 10)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                                        .fill(MyFisColor.surface2)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, MyFisSpacing.md)
        }
    }
}

/// 보유 마일리지 — **스크롤해도 남는다** (SPEC S 공통 규칙).
///
/// 이 화면의 라임은 여기 하나다.
private struct MileageStrip: View {
    let balance: Int
    let onHistory: () -> Void

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            Text("내 마일리지")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)
            Text(balance.mileage)
                .font(MyFisFont.titleSm.monospacedDigit())
                .foregroundStyle(MyFisColor.accent)
            Spacer(minLength: 0)
            Button(action: onHistory) {
                Text("교환 내역 ›")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.sm)
    }
}

/// 배너 — 옆 장이 살짝 보이게 두고 넘긴다. 몇 장 중 몇 번째인지 오른쪽 아래에 적는다.
///
/// `contentMargins` 로 좌우를 물려 두면 다음 장이 자연스럽게 걸친다 —
/// `TabView(.page)` 는 화면 폭을 꽉 채워서 이 모양이 안 나온다.
private struct BannerCarousel: View {
    let banners: [StoreBanner]

    @State private var current: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MyFisSpacing.md) {
                ForEach(banners) { banner in
                    card(banner)
                        .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: MyFisSpacing.md)
                        .id(banner.id)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, MyFisSpacing.screenHorizontal, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $current)
        .frame(height: 150)
    }

    private func card(_ banner: StoreBanner) -> some View {
        ZStack {
            MyFisColor.surface1

            // 사진이 없으므로 우리 벡터를 크게 깔아 자리를 잡는다.
            // TODO(서버): 배너 이미지가 오면 교체한다.
            Image(banner.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 132, height: 132)
                .foregroundStyle(MyFisColor.surface3)
                .offset(x: 18)
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(alignment: .leading, spacing: MyFisSpacing.sm) {
                Text(banner.title)
                    .font(MyFisFont.titleLg)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text(banner.body)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(MyFisSpacing.cardPadding)

            Text("\(index(of: banner)) / \(banners.count)")
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

    private func index(of banner: StoreBanner) -> Int {
        (banners.firstIndex(of: banner) ?? 0) + 1
    }
}

/// 마일리지 모으기 — 살 수 없는 걸 봤을 때 **바로 모으러 갈 수 있어야 한다.**
/// 혜택 탭(P)의 미니 활동으로 가는 지름길이다.
private struct QuestSection: View {
    let quests: [StoreQuest]
    let onQuest: (StoreQuest) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            SectionHeader(
                title: "마일리지 모으기",
                chip: "오늘 최대 " + quests.reduce(0) { $0 + $1.reward }.mileage
            )
            .padding(.horizontal, MyFisSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: MyFisSpacing.md) {
                    ForEach(quests) { quest in
                        QuestTile(quest: quest) { onQuest(quest) }
                    }
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
            }
        }
    }
}

private struct QuestTile: View {
    let quest: StoreQuest
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: MyFisSpacing.sm) {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(MyFisColor.surface2)
                        .frame(width: 56, height: 56)
                        .overlay {
                            Image(quest.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundStyle(MyFisColor.textPrimary)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)

                    // 뱃지는 타일 위로 떠서 걸친다 (레퍼런스와 같은 배치)
                    Text("+\(quest.reward)P")
                        .font(MyFisFont.caption.monospacedDigit())
                        .foregroundStyle(MyFisColor.textPrimary)
                        .padding(.horizontal, MyFisSpacing.sm)
                        .padding(.vertical, 1)
                        .background(MyFisColor.surface3, in: Capsule())
                }
                .frame(width: 64, height: 66)

                Text(quest.label)
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 64)
        }
        .buttonStyle(.plain)
    }
}

private struct SectionHeader: View {
    let title: String
    var chip: String?

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            Text(title)
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            if let chip {
                Text(chip)
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .padding(.horizontal, MyFisSpacing.sm)
                    .padding(.vertical, 3)
                    .background(MyFisColor.surface2, in: Capsule())
            }
            Spacer(minLength: 0)
        }
    }
}

/// 상품 카드.
///
/// **부족해도 가리지 않는다** (SPEC S-01) — 얼마가 모자란지 적어 목표로 삼게 한다.
/// 품절도 숨기지 않는다.
private struct ItemCard: View {
    let item: StoreItem
    let balance: Int
    let onTap: () -> Void

    private var short: Int { max(0, item.price - balance) }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: MyFisSpacing.sm) {
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
                .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(item.soldOut ? MyFisColor.textTertiary : MyFisColor.textPrimary)
                        .lineLimit(1)
                    Text(item.price.mileage)
                        .font(MyFisFont.titleSm.monospacedDigit())
                        .foregroundStyle(item.soldOut ? MyFisColor.textTertiary : MyFisColor.textPrimary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
