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

    /// 셸 위를 덮고 있는 잎 화면. nil 이면 탭만 보인다.
    @State private var leaf: HeaderRoute? = .initialForDebug

    var body: some View {
        ZStack {
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

            // 잎 화면은 **탭 바를 감추지 않고 그 위를 덮는다.**
            // `.toolbar(.hidden, for: .tabBar)` 로 감추면 돌아올 때 시스템이 유리 바를
            // 다시 그리면서 한 번 깜빡인다. 셸을 건드리지 않으면 그 일이 아예 없다.
            if let leaf {
                leafScreen(leaf)
                    // 탭 스택을 안 쓰니 시스템 pop 제스처가 따라오지 않는다. 직접 붙인다.
                    .modifier(EdgeSwipeBack { self.leaf = nil })
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
    }

    @ViewBuilder
    private func leafScreen(_ route: HeaderRoute) -> some View {
        switch route {
        case .notifications:
            NavigationStack {
                NotificationScreen(onBack: { close() })
            }
            .tint(MyFisColor.textPrimary)
        case .storeMy:
            NavigationStack {
                StoreMyScreen(onBack: { close() })
            }
            .tint(MyFisColor.textPrimary)
        case .storeItem(let item):
            NavigationStack {
                StoreItemScreen(item: item, onBack: { close() })
            }
            .tint(MyFisColor.textPrimary)
        }
    }

    private func open(_ route: HeaderRoute) {
        withAnimation(MyFisMotion.slow) { leaf = route }
    }

    private func close() {
        withAnimation(MyFisMotion.slow) { leaf = nil }
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
                        onNotification: { open(.notifications) },
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
private struct EdgeSwipeBack: ViewModifier {
    let onClose: () -> Void

    @State private var width: CGFloat = 0
    @State private var offset: CGFloat = 0

    /// 이보다 안쪽에서 시작한 드래그는 무시한다
    private let edge: CGFloat = 24
    /// 이만큼 끌었거나, 이만큼 갈 기세면 닫는다 (화면 폭 대비)
    private let closeRatio: CGFloat = 0.3
    private let flingRatio: CGFloat = 0.5

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear { width = geo.size.width }
                }
            )
            .simultaneousGesture(drag)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .global)
            .onChanged { value in
                guard value.startLocation.x <= edge else { return }
                offset = max(0, value.translation.width)
            }
            .onEnded { value in
                guard value.startLocation.x <= edge else { return }
                let dragged = value.translation.width > width * closeRatio
                let flung = value.predictedEndTranslation.width > width * flingRatio
                if dragged || flung {
                    withAnimation(MyFisMotion.slow, completionCriteria: .removed) {
                        offset = width
                    } completion: {
                        onClose()
                        offset = 0
                    }
                } else {
                    withAnimation(MyFisMotion.slow) { offset = 0 }
                }
            }
    }
}
