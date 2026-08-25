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
            ProcessInfo.processInfo.environment["MYFIS_TAB"] == "store" ? store : 0
            #else
            0
            #endif
        }
    }

    @State private var tabSet: TabSet = .initialForDebug
    @State private var baseSlot = Slot.initialBaseForDebug
    @State private var weightSlot = 1

    /// 잎 화면 경로.
    ///
    /// **직접 만든 덮개를 버리고 `NavigationStack` 에 맡긴다** (2026-08-25 재작성).
    /// 뒤로 버튼·가장자리 스와이프·스택 관리가 전부 시스템 몫이 된다 —
    /// 직접 만들었더니 화면 전체 드래그가 탭을 삼키고, 잠금이 안 풀리고,
    /// 같은 화면이 두 장 쌓였다. 안드로이드가 `NavHost` 로 멀쩡했던 이유이기도 하다.
    @State private var path: [HeaderRoute] = HeaderRoute?.initialForDebug.map { [$0] } ?? []

    var body: some View {
        NavigationStack(path: $path) {
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
            // 탭 헤더도 **시스템 내비 바**가 그린다 (§6.9 · §7.1).
            // 화면 안에 직접 그리면 잎이 밀려 들어올 때 헤더가 같이 밀려 흔들린다
            .toolbar { tabHeader }
            // **큰 제목 자리를 비워 두지 않는다.** 기본값(.automatic)은 스택 루트에서 큰 제목이라,
            // 제목이 없어도 그 높이만큼 빈 줄이 생겨 헤더와 본문이 멀어진다
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MyFisColor.bgBase, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: HeaderRoute.self) { leafScreen($0) }
        }
        // 뒤로 화살표 색. 잎 화면들이 모두 이 틴트를 물려받는다
        .tint(MyFisColor.textPrimary)
    }

    /// 탭 화면의 헤더 (DESIGN.md §6.9).
    ///
    /// 화면마다 다르므로 **선택된 탭을 보고 고른다.** 각 탭 뷰에 따로 달면
    /// 안 보이는 탭의 항목까지 섞여 들어온다.
    @ToolbarContentBuilder
    private var tabHeader: some ToolbarContent {
        if tabSet == .base, baseSlot == Slot.home {
            // TODO: 지점 선택(M-01) · 회원권(M-06) 이 붙으면 연결한다
            ToolbarItem(placement: .topBarLeading) {
                HeaderIcon("ic_header_branch", "지점") {}
            }
            ToolbarItem(placement: .principal) { Wordmark() }
            ToolbarItem(placement: .topBarTrailing) {
                HeaderIcon("ic_header_membership", "멤버십") {}
            }
            ToolbarItem(placement: .topBarTrailing) {
                HeaderIcon("ic_header_notification", "알림") { open(.notifications) }
            }
        }

        // 스토어 헤더 — 검색 필드가 가운데를 다 쓰고 오른쪽에 장바구니·마이 (§6.9).
        // 검색 중에는 오른쪽 자리가 `취소` 로 바뀐다
        if tabSet == .base, baseSlot == Slot.store {
            ToolbarItem(placement: .principal) {
                // 내비 바는 principal 에 **딱 필요한 만큼만** 자리를 준다.
                // 검색이 폭을 다 써야 하는 헤더라(§6.9) 오른쪽 아이콘 자리를 뺀 폭을 직접 잡는다
                StoreSearchButton { open(.storeSearch) }
                    .frame(width: max(160, UIScreen.main.bounds.width - 160))
            }
            ToolbarItem(placement: .topBarTrailing) {
                HeaderIcon("ic_header_cart", "장바구니") { open(.storeCart) }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HeaderIcon("ic_header_my", "마이") { open(.storeMy) }
            }
        }
    }

    @ViewBuilder
    private func leafScreen(_ route: HeaderRoute) -> some View {
        switch route {
        case .notifications:
            NotificationScreen()
        case .storeMy:
            StoreMyScreen(onCart: { open(.storeCart) })
        case .storeCart:
            StoreCartScreen(onStore: { popToStore() })
        case .storeSearch:
            StoreSearchScreen(onItem: { open(.storeItem($0)) })
        case .storeItem(let item):
            StoreItemScreen(item: item, onCart: { open(.storeCart) })
        }
    }

    private func open(_ route: HeaderRoute) {
        path.append(route)
    }

    /// 잎을 전부 걷고 스토어 탭으로. 장바구니 빈 상태의 [상품 보러 가기] 가 쓴다
    private func popToStore() {
        baseSlot = Slot.store
        path.removeAll()
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
                        onCart: { open(.storeCart) },
                        onMy: { open(.storeMy) },
                        onItem: { open(.storeItem($0)) }
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

/// 왼쪽 가장자리에서 오른쪽으로 쓸면 덮개를 걷는다 — iOS 기본 pop 제스처를 흉내 낸다.
///
/// 시작점이 **가장자리 24pt 안쪽일 때만** 잡는다. 그래야 안쪽 스크롤·탭을 방해하지 않는다.
///
/// 놓아서 닫을 때는 화면 밖까지 직접 밀어낸 뒤 걷어낸다.
/// `withAnimation` 으로 걷으면 `.transition` 이 같이 돌아 손가락 위치에서 한 번 튄다.
