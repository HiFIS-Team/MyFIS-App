import SwiftUI

/// 모든 화면이 올라앉는 배경. 순검정 위에 하단 탭 바만 있다.
///
/// **하단 바는 네이티브 `TabView` 를 쓴다.** iOS 26 이상에서는 시스템이 Liquid Glass
/// 탭 바로 그려준다 — 선택 인디케이터·모션·스크롤 시 축소까지 전부 Apple 구현이다.
///
/// SPEC.md §3 — 웨이트 탭을 누르면 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
///
/// **세트 교체는 TabView 를 갈아끼우지 않는다.** 슬롯 5개짜리 `TabView` 하나를 유지하고
/// 각 슬롯의 아이콘·콘텐츠만 바꾼다. 그래야 바가 파괴·재생성되지 않고 시스템이
/// 선택 인디케이터를 슬롯 사이로 흘려보낸다. TabView 자체를 교체하면 딱 끊겨 보인다.
struct AppShell: View {
    private enum Slot {
        static let count = 5
        /// 기본 세트의 홈 자리 (항상 첫 번째)
        static let home = 0
        /// 기본 세트에서 웨이트 세트로 들어가는 자리
        static let weightPortal = 3
        /// 웨이트 세트에서 기본 세트로 나가는 자리 (항상 첫 번째)
        static let backPortal = 0
        static let store = 2
        /// 웨이트 세트의 유산소 자리 — 홈 바로가기가 여기로 보낸다
        static let cardio = 2
        /// 웨이트 세트의 웨이트 자리 — 홈의 오늘의 루틴 카드가 여기로 보낸다
        static let weight = 1

        /// 시뮬레이터에는 탭을 누를 수단이 없다. 스토어 화면을 스크린샷으로 확인할 때
        /// `SIMCTL_CHILD_MYFIS_TAB=store` 로 띄운다. 디버그 빌드에서만 동작한다.
        static var initialBaseForDebug: Int {
            #if DEBUG
            let env = ProcessInfo.processInfo.environment
            let storeRoute = (env["MYFIS_ROUTE"] ?? "").hasPrefix("store")
            return env["MYFIS_TAB"] == "store" || storeRoute ? store : 0
            #else
            0
            #endif
        }
    }

    @State private var tabSet: TabSet = .initialForDebug
    @State private var baseSlot = Slot.initialBaseForDebug
    @State private var weightSlot = 1

    /// 스토어 화면 폭 — 검색 필드 폭을 여기서 계산한다 (§6.9).
    ///
    /// 내비 바는 자식에게 남는 폭을 주지 않아 `maxWidth: .infinity` 로는 안 늘어난다.
    /// **툴바 안에서 재면 안 된다** — 잰 값으로 필드 폭을 바꾸면 바가 다시 눕고,
    /// 그러면 또 재게 되어 무한 루프에 빠진다 (CPU 100% 로 확인함).
    /// 본문 폭은 필드 폭에 영향받지 않으므로 되먹임이 없다.
    @State private var storeWidth: CGFloat = 0

    /// 내비 바 좌우 기본 여백 · 검색과 오른쪽 것 사이
    private static let barInset: CGFloat = 20
    private static let searchGap: CGFloat = 16
    /// 오른쪽 아이콘 묶음 폭 — 시스템이 44pt 버튼 두 개를 유리 알약으로 감싼 크기 (재서 확인: 96pt)
    private static let trailingIconsWidth: CGFloat = 96
    /// 잎 화면이 오가는 데 걸리는 시간 (UIKit 기본 0.35 + 여유)
    private static let leafTransition: UInt64 = 450_000_000

    /// `취소` 유리 버튼 폭 (재서 확인: 52pt)
    private static let cancelWidth: CGFloat = 52

    /// 스토어 헤더가 검색 모드인가 (§6.9).
    /// **화면을 옮기지 않는다** — 오른쪽이 `취소` 로 바뀌고 필드가 그 앞까지 늘어나고 본문만 갈린다
    /// 헤더 검색 자리를 지금 그리는가 (§6.9).
    ///
    /// 잎으로 들어갈 때는 **누르는 즉시** 비우고, 돌아올 때는 **전환이 끝난 뒤에** 넣는다.
    /// 전환 도중에 넣으면 시스템이 뒤로 버튼에서 옆으로 늘어나며 그려 준다.
    @State private var storeFieldVisible = (HeaderRoute.initialHomeForDebug
        + HeaderRoute.initialStoreForDebug).isEmpty
    @State private var storeSearching = StoreSearch.initialForDebug
    @State private var storeQuery = StoreSearch.initialQueryForDebug

    /// 왼쪽 여백부터 오른쪽 것 앞까지
    private var searchFieldWidth: CGFloat? {
        guard storeWidth > 0 else { return nil }
        let trailing = storeSearching ? Self.cancelWidth : Self.trailingIconsWidth
        return max(0, storeWidth - (Self.barInset * 2 + trailing + Self.searchGap))
    }

    /// 잎 화면 경로 — **앱 전체에 하나**. Android 의 `NavHost` 백스택과 같은 자리다.
    ///
    /// 스택이 `TabView` **바깥**에 있어야 잎이 하단 탭 바까지 **통째로 덮는다**.
    /// 탭 안에 두면 잎은 탭 콘텐츠 영역에서만 밀리고, 그 위에 떠 있는 유리 탭 바는
    /// 껐다 켜는 수밖에 없어 **툭 사라지고 툭 생긴다** (프레임으로 확인).
    @State private var path: [HeaderRoute] = HeaderRoute.initialHomeForDebug
        + HeaderRoute.initialStoreForDebug

    /// 애니메이션 없이 **툭** 바꾼다
    private func snap(_ change: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, change)
    }

    /// 잎으로 들어간다 — 밀기 전에 검색 자리를 비운다 (§6.9)
    private func push(_ route: HeaderRoute) {
        snap { storeFieldVisible = false }
        path.append(route)
    }

    /// 검색 모드를 켜고 끈다. **애니메이션 없이 툭 바뀐다** — iOS 앱들이 그렇게 한다
    private func setSearching(_ on: Bool) {
        snap {
            storeSearching = on
            if !on { storeQuery = "" }
        }
    }


    var body: some View {
        // **스택이 탭 바깥이다.** 잎 화면은 셸(탭 바 포함)을 통째로 덮는다 —
        // Android 의 `NavHost`(SHELL 라우트 + 잎 라우트 형제) 와 같은 구조다.
        NavigationStack(path: $path) {
            tabs
                .toolbar { tabHeader }
                // **큰 제목 자리를 비워 두지 않는다.** 기본값(.automatic)은 스택 루트에서 큰 제목이라,
                // 제목이 없어도 그 높이만큼 빈 줄이 생겨 헤더와 본문이 멀어진다
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(MyFisColor.bgBase, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationDestination(for: HeaderRoute.self) { leafScreen($0) }
                .background(WidthProbe { storeWidth = $0 })
                // 검색 자리는 따로 얹는다 — 이 아이템만 유리 껍데기를 벗겨야 한다
                .modifier(SearchFieldBar(
                    width: searchFieldWidth,
                    visible: storeFieldVisible && isStoreTab,
                    searching: storeSearching,
                    query: $storeQuery,
                    onSearch: { setSearching(true) }
                ))
                // 검색 중에는 하단 탭을 감춘다 — 검색은 탭을 옮겨 다니는 일이 아니다.
                // 잎 화면은 여기 관여하지 않는다 (덮으므로 끌 일이 없다)
                .modifier(HideTabBar(when: storeSearching))
                // 잎에서 돌아왔다 — **전환이 끝난 뒤** 검색 자리를 되돌린다.
                // 도중에 넣으면 시스템이 뒤로 버튼에서 옆으로 늘여 그려 준다
                .onChange(of: path.isEmpty) { _, empty in
                    guard empty else { return }
                    Task {
                        try? await Task.sleep(nanoseconds: Self.leafTransition)
                        snap { storeFieldVisible = true }
                    }
                }
        }
        // 뒤로 화살표 색. 잎 화면들이 모두 이 틴트를 물려받는다
        .tint(MyFisColor.textPrimary)
    }

    private var tabs: some View {
        TabView(selection: selection) {
            ForEach(0..<Slot.count, id: \.self) { slot in
                content(for: slot)
                    .tabItem {
                        icon(for: slot)
                            .accessibilityLabel(label(for: slot))
                    }
                    .tag(slot)
            }
        }
        // 선택은 **색이 아니라 채움**으로 알린다 (DESIGN.md §6.7).
        // 라임은 화면 콘텐츠 몫으로 남긴다 — 항상 켜져 있는 바가 액센트 예산을 먹으면 안 된다.
        .tint(MyFisColor.textPrimary)
    }

    private var isHomeTab: Bool { tabSet == .base && baseSlot == Slot.home }
    private var isStoreTab: Bool { tabSet == .base && baseSlot == Slot.store }

    /// 탭 헤더 (DESIGN.md §6.9) — 스택 루트가 하나뿐이라 **선택된 탭에 따라 내용을 고른다.**
    ///
    /// `ToolbarContentBuilder` 에는 `buildEither` 가 없어 아이템 개수를 조건으로 바꿀 수 없다 —
    /// 자리는 고정해 두고 **아이템 안의 뷰에서** 가른다.
    @ToolbarContentBuilder
    private var tabHeader: some ToolbarContent {
        // TODO: 지점 선택(M-01) · 회원권(M-06) 이 붙으면 연결한다
        ToolbarItem(placement: .topBarLeading) {
            if isHomeTab { HeaderIcon("ic_header_branch", "지점") {} }
        }
        ToolbarItem(placement: .principal) {
            if isHomeTab { Wordmark() }
        }
        ToolbarItem(placement: .topBarTrailing) {
            if isHomeTab { HeaderIcon("ic_header_membership", "멤버십") {} }
        }
        ToolbarItem(placement: .topBarTrailing) {
            if isHomeTab {
                HeaderIcon("ic_header_notification", "알림") { push(.notifications) }
            }
        }
        // 스토어 — 검색이 폭을 다 먹고 오른쪽에 장바구니 · 마이.
        // **검색 모드면 오른쪽이 `취소` 한 개로 바뀐다.** 유리는 시스템이 그린 그대로 둔다 (§2 원칙 6)
        ToolbarItem(placement: .topBarTrailing) {
            if isStoreTab {
                if storeSearching {
                    Button { setSearching(false) } label: {
                        // 유리 알약이 글자에 딱 붙지 않게 숨통을 준다 (기본은 44pt 원이라 빡빡하다)
                        Text("취소")
                            .font(MyFisFont.body)
                            .padding(.horizontal, MyFisSpacing.sm)
                            .frame(height: MyFisSize.minTouchTarget)
                    }
                    .buttonStyle(.myFisTap)
                    .foregroundStyle(MyFisColor.textPrimary)
                } else {
                    HStack(spacing: 0) {
                        HeaderIcon("ic_header_cart", "장바구니") { push(.storeCart) }
                        HeaderIcon("ic_header_my", "마이") { push(.storeMy) }
                    }
                }
            }
        }
    }

    /// 잎 화면 — 셸을 **통째로 덮으며** 옆에서 들어온다 (하단 탭 바까지).
    ///
    /// **하단 탭을 껐다 켜지 않는다** 🟢 (2026-08-25). 덮으면 될 일을 상태로 토글하면
    /// 전환에 끼어들어 **툭 사라지고 툭 생긴다** (프레임으로 확인).
    @ViewBuilder
    private func leafScreen(_ route: HeaderRoute) -> some View {
        switch route {
        case .notifications:
            NotificationScreen()
        case .storeMy:
            StoreMyScreen(onCart: { path.append(.storeCart) })
        case .storeCart:
            StoreCartScreen(onStore: { path.removeAll() })
        case .storeItem(let item):
            StoreItemScreen(
                item: item,
                // 상세에서 검색을 누르면 **스토어로 돌아가** 검색 모드가 된다
                onSearch: {
                    path.removeAll()
                    setSearching(true)
                },
                onCart: { path.append(.storeCart) }
            )
        }
    }

    // MARK: - 선택

    private var selection: Binding<Int> {
        Binding(
            get: { tabSet == .base ? baseSlot : weightSlot },
            set: { slot in
                switch tabSet {
                case .base:
                    // 웨이트는 목적지가 아니라 통로다. baseSlot 을 바꾸지 않아야
                    // '이전' 으로 돌아왔을 때 보던 탭으로 복귀한다.
                    if slot == Slot.weightPortal {
                        weightSlot = 1
                        withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                    } else {
                        baseSlot = slot
                    }
                case .weight:
                    if slot == Slot.backPortal {
                        withAnimation(.snappy(duration: 0.35)) { tabSet = .base }
                    } else {
                        weightSlot = slot
                    }
                }
            }
        )
    }

    // MARK: - 슬롯별 내용

    /// 선택된 자리만 **안쪽이 찬 벌**로 바꾼다. 실루엣은 같아서 바뀔 때 튀지 않는다.
    ///
    /// 통로 자리(`웨이트`·`이전`)는 선택되지 않으므로 항상 아웃라인이다.
    private func icon(for slot: Int) -> Image {
        let selected = slot == (tabSet == .base ? baseSlot : weightSlot)
        // 크기는 우리 SVG 의 width/height 가 정한다 (28pt).
        // .font(.system(size:)) / .imageScale 은 탭 바에서 무시된다 (확인함)
        let tab: any MyFisTab = tabSet == .base ? baseTabs[slot] : weightTabs[slot]
        return Image(selected ? tab.iconFilled : tab.icon)
    }

    private func label(for slot: Int) -> String {
        tabSet == .base ? baseTabs[slot].label : weightTabs[slot].label
    }

    private let baseTabs: [BaseTab] = [.home, .benefit, .store, .weight, .my]
    private let weightTabs: [WeightTab] = [.back, .weight, .cardio, .ranking, .group]

    @ViewBuilder
    private func content(for slot: Int) -> some View {
        if tabSet == .base {
            switch baseTabs[slot] {
            case .home:
                TabScreen {
                    HomeScreen(
                        // 홈의 유산소 바로가기 — 세트를 바꾸고 유산소로 바로 들어간다
                        onCardio: {
                            weightSlot = Slot.cardio
                            withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                        },
                        // 홈의 오늘의 루틴 카드 — 같은 길로 웨이트(W-01)에 들어간다
                        onWeight: {
                            weightSlot = Slot.weight
                            withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                        },
                        // 홈의 마일리지 상품 — 같은 세트 안이라 탭만 옮긴다
                        onStore: { baseSlot = Slot.store }
                    )
                }
            case .benefit:
                screen(id: "P-01", title: "혜택", description: "보유 마일리지 · 적립 경로")
            case .store:
                // 스토어 헤더의 '마이' 는 **마이 탭이 아니다.** 교환에 관한 나(S-08)로 간다.
                TabScreen {
                    StoreScreen(
                        searching: storeSearching,
                        query: $storeQuery,
                        onCart: { push(.storeCart) },
                        onMy: { push(.storeMy) },
                        onItem: { push(.storeItem($0)) }
                    )
                }

            case .my:
                // TODO: Y-01 마이 화면이 붙으면 교체한다.
                // 그때까지 토큰 확인 화면을 여기 둔다 — 스크롤 콘텐츠가 있어야
                // 유리 바 뒤로 뭐가 지나가는지 확인할 수 있다.
                TabScreen { DesignTokensView() }
            case .weight:
                Color.clear // 통로
            }
        } else {
            switch weightTabs[slot] {
            case .weight:
                screen(id: "W-01", title: "이번 주 루틴", description: "AI가 보낸 주간 루틴")
            case .cardio:
                screen(id: "C-01", title: "유산소", description: "기기 목록 · NFC 스캔")
            case .ranking:
                screen(id: "R-01", title: "랭킹", description: "웨이트 · 유산소 · 마일리지")
            case .group:
                screen(id: "G-01", title: "모임", description: "모임 · 커뮤니티")
            case .back:
                Color.clear // 통로
            }
        }
    }

    private func screen(id: String, title: String, description: String) -> some View {
        TabScreen {
            PlaceholderScreen(id: id, title: title, description: description)
        }
    }
}

private extension TabSet {
    /// 시뮬레이터에는 탭을 자동화할 수단이 없다. 스크린샷으로 특정 상태를 확인할 때
    /// `SIMCTL_CHILD_MYFIS_TABSET=weight` 로 앱을 띄운다.
    ///
    ///     xcrun simctl launch --terminate-running-process booted com.myfis.app
    ///
    /// 디버그 빌드에서만 동작한다.
    static var initialForDebug: TabSet {
        #if DEBUG
        ProcessInfo.processInfo.environment["MYFIS_TABSET"] == "weight" ? .weight : .base
        #else
        .base
        #endif
    }
}

#Preview {
    AppShell().preferredColorScheme(.dark)
}

/// 화면 폭을 잰다. 배경으로 깔아서 잰다 — `GeometryReader` 를 그대로 쓰면 자리를 다 먹는다.
private struct WidthProbe: View {
    let onChange: (CGFloat) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { onChange(proxy.size.width) }
                .onChange(of: proxy.size.width) { _, new in onChange(new) }
        }
    }
}

/// 헤더의 검색 자리를 내비 바에 얹는다 (§6.9).
///
/// **iOS 26 은 툴바 아이템마다 유리 껍데기를 씌운다.** 우리 필드는 다크 위 회색 판이라
/// `sharedBackgroundVisibility(.hidden)` 으로 그 껍데기를 벗긴다.
/// `ToolbarContentBuilder` 안에서는 `if #available` 을 못 쓰므로 (buildEither 가 없다)
/// 여기서 뷰 단계로 갈라 붙인다.
private struct SearchFieldBar: ViewModifier {
    let width: CGFloat?
    let visible: Bool
    let searching: Bool
    @Binding var query: String
    let onSearch: () -> Void

    private var item: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Group {
                if !visible {
                    // 잎이 오가는 **동안에는 자리를 비운다.** 아이템이 남아 있으면 iOS 26 이
                    // 뒤로 버튼과 morph 시켜서, 들어갈 땐 그루터기가 남고 나올 땐 옆에서 늘어난다.
                    // (투명도만 0 으로 해도 틀이 남아 똑같이 morph 된다 — 슬로모션으로 확인)
                    Color.clear.frame(width: 0, height: 0)
                } else if searching {
                    StoreSearchInput(text: $query)
                } else {
                    StoreSearchField(action: onSearch)
                }
            }
            .frame(width: visible ? width : 0)
            // 이 자리만 애니메이션을 끊는다 — 늘었다 줄었다 하지 않고 **툭** 나타난다
            .transaction { $0.disablesAnimations = true }
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.toolbar { item.sharedBackgroundVisibility(.hidden) }
        } else {
            content.toolbar { item }
        }
    }
}

/// 하단 탭을 감춘다. **`.visible` 을 명시하지 않는다** — 탭 루트에서 `.visible` 을 걸어 두면
/// 밀려 들어온 잎 화면의 `.hidden` 을 눌러 버린다 (확인함).
private struct HideTabBar: ViewModifier {
    let when: Bool

    func body(content: Content) -> some View {
        if when {
            content.toolbar(.hidden, for: .tabBar)
        } else {
            content
        }
    }
}
