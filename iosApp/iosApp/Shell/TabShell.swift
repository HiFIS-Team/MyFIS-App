import SwiftUI

/// 탭 셸 — 화면(자기 헤더 포함) + **하단 유리 탭 바**.
///
/// 하단 바는 네이티브 `TabView` 를 쓴다 (§2 원칙 6) — iOS 26 이 Liquid Glass 로 그리고
/// 선택 인디케이터·모션·스크롤 축소까지 전부 Apple 구현이다.
/// **가시성을 상태로 토글하지 않는다.** 잎이 덮으므로 끌 일이 없다.
///
/// SPEC.md §3 — 웨이트 탭을 누르면 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
/// **세트 교체는 TabView 를 갈아끼우지 않는다.** 슬롯 5개짜리 `TabView` 하나를 유지하고
/// 각 슬롯의 아이콘·콘텐츠만 바꾼다 — 그래야 바가 파괴·재생성되지 않는다.
struct TabShell: View {
    let open: (Route) -> Void
    /// 찜 — 스토어 홈과 검색 잎이 나눠 쓴다 (뿌리가 들고 있다)
    @Binding var liked: Set<Int>

    private static let baseTabs = BaseTab.allCases
    private static let weightTabs = WeightTab.allCases

    @State private var tabSet: TabSet = MyFisDebug.initialTabSet
    @State private var baseTab: BaseTab = MyFisDebug.initialBaseTab
    @State private var weightTab: WeightTab = MyFisDebug.initialWeightTab
    /// 웨이트 요일 띠 — 여닫는 칩이 툴바에 있어서 셸이 든다
    @State private var weekOpen = MyFisDebug.weightWeekOpen

    var body: some View {
        TabView(selection: selection) {
            ForEach(0..<Self.baseTabs.count, id: \.self) { slot in
                screen(at: slot)
                    .tabItem { icon(at: slot).accessibilityLabel(label(at: slot)) }
                    .tag(slot)
            }
        }
        // 선택은 **색이 아니라 채움**으로 알린다 (§6.7).
        // 라임은 화면 콘텐츠 몫이다 — 항상 켜져 있는 바가 액센트 예산을 먹으면 안 된다.
        .tint(MyFisColor.textPrimary)
        .toolbar { tabToolbar }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 툴바 (탭 화면 헤더)
    //
    // **탭 화면 헤더는 여기서 시스템 툴바로 올린다** 🟢 (2026-09-15, §6.9 · §7.1).
    // 스택(`AppRoot`)이 탭 **밖**이라 탭 안 화면이 단 `.toolbar` 는 올라오지 않는다.
    // 잎이 밀려 들어오면 이 아이템들이 잎의 뒤로 · 액션으로 **녹아 바뀐다** (iOS 26 유리).
    // 화면 이름 · 칩은 유리를 씌우지 않는다 (`withoutGlass`) — 판이 없어야 하거나 자기 판이 있다

    @ToolbarContentBuilder
    private var tabToolbar: some ToolbarContent {
        if tabSet == .base && baseTab == .home { homeToolbar }
        if tabSet == .base && baseTab == .benefit { benefitToolbar }
        if tabSet == .base && baseTab == .store { storeToolbar }
        if tabSet == .base && baseTab == .my { myToolbar }
        if tabSet == .weight && weightTab == .weight { weightToolbar }
        if tabSet == .weight && weightTab == .cardio { cardioToolbar }
        if tabSet == .weight && weightTab == .group { groupToolbar }
    }

    /// 홈 — 지점 · 워드마크 · 멤버십 + 알림
    @ToolbarContentBuilder
    private var homeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            ToolbarIcon("ic_header_branch", "지점") { open(.branch) }
        }
        ToolbarItem(placement: .principal) {
            Wordmark()
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            // TODO: 회원권(M-06) 이 붙으면 연결한다
            ToolbarIcon("ic_header_membership", "멤버십") {}
            ToolbarIcon("ic_header_notification", "알림") { open(.notifications) }
        }
    }

    /// 혜택 — 마일리지 칩 + 적립 내역. 글자 제목을 달지 않는다 — 칩이 이미 "P를 모으는 곳"이라고 말한다
    @ToolbarContentBuilder
    private var benefitToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            // ⚠️ 툴바 왼쪽은 폭을 좁게 준다 — 안 고정하면 글자가 빠지고 동전만 남는다 (확인함)
            MileageChip(balance: BenefitPlaceholder.balance)
                .fixedSize()
        }
        .withoutGlass()
        ToolbarItem(placement: .topBarTrailing) {
            // TODO: P-02 적립 내역이 붙으면 연결한다
            ToolbarIcon("ic_header_history", "적립 내역") {}
        }
    }

    /// 스토어 — 마일리지 칩 + 검색 · 장바구니 · 마이 (§6.12). 워드마크는 없다 — 칩이 왼쪽을 쓴다.
    /// `마이` 는 **마이 탭이 아니다** — 교환에 관한 나(S-08)로 간다
    @ToolbarContentBuilder
    private var storeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            MileageChip(balance: StorePlaceholder.balance)
                .fixedSize()
        }
        .withoutGlass()
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarIcon("ic_header_search", "검색") { open(.storeSearch) }
            ToolbarIcon("ic_header_cart", "장바구니") { open(.storeCart) }
            ToolbarIcon("ic_header_my", "마이") { open(.storeMy) }
        }
    }

    /// 마이 — 프로필 + 설정 (§6.38)
    @ToolbarContentBuilder
    private var myToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            MyProfileChip()
                .fixedSize()
        }
        .withoutGlass()
        ToolbarItem(placement: .topBarTrailing) {
            // TODO(Y-03): 설정 화면이 붙으면 연결한다
            ToolbarIcon("ic_header_settings", "설정") {}
        }
    }

    /// 웨이트 — 화면 이름 + 이번 주 칩 (§6.33)
    @ToolbarContentBuilder
    private var weightToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            ToolbarScreenTitle("웨이트")
        }
        .withoutGlass()
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation(MyFisMotion.base) { weekOpen.toggle() }
            } label: {
                WeightWeekChip(open: weekOpen)
            }
            .buttonStyle(.myFisTap)
            .accessibilityLabel(weekOpen ? "이번 주 접기" : "이번 주 펼치기")
        }
        .withoutGlass()
    }

    /// 유산소 — 화면 이름 + 마일리지 칩 (§6.28). 유산소는 뛴 만큼 P가 붙는다
    @ToolbarContentBuilder
    private var cardioToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            ToolbarScreenTitle("유산소")
        }
        .withoutGlass()
        ToolbarItem(placement: .topBarTrailing) {
            MileageChip(balance: BenefitPlaceholder.balance)
                .fixedSize()
        }
        .withoutGlass()
    }

    /// 모임 — 화면 이름 + 검색 (§6.29). 지점은 걸지 않는다 — 활동 지역이 들어와 목록이 지점 것만이 아니다
    @ToolbarContentBuilder
    private var groupToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            ToolbarScreenTitle("모임")
        }
        .withoutGlass()
        ToolbarItem(placement: .topBarTrailing) {
            ToolbarIcon("ic_header_search", "모임 검색") { open(.groupSearch) }
        }
    }

    // MARK: - 탭 선택

    private var selection: Binding<Int> {
        Binding(
            get: { tabSet == .base ? Self.baseTabs.firstIndex(of: baseTab)! : Self.weightTabs.firstIndex(of: weightTab)! },
            set: { slot in
                switch tabSet {
                case .base:
                    let tab = Self.baseTabs[slot]
                    // 웨이트는 목적지가 아니라 **통로**다. baseTab 을 바꾸지 않아야
                    // '이전' 으로 돌아왔을 때 보던 탭으로 복귀한다.
                    if tab == .weight {
                        weightTab = .weight
                        withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                    } else {
                        baseTab = tab
                    }
                case .weight:
                    let tab = Self.weightTabs[slot]
                    if tab == .back {
                        withAnimation(.snappy(duration: 0.35)) { tabSet = .base }
                    } else {
                        weightTab = tab
                    }
                }
            }
        )
    }

    /// 선택된 자리만 **안쪽이 찬 벌**로 바꾼다. 실루엣이 같아 바뀔 때 튀지 않는다.
    private func icon(at slot: Int) -> Image {
        // 크기는 우리 SVG 의 width/height 가 정한다 (28pt).
        // `.font(.system(size:))` / `.imageScale` 은 탭 바에서 무시된다 (확인함)
        let tab: any MyFisTab = tabSet == .base ? Self.baseTabs[slot] : Self.weightTabs[slot]
        let selected = tabSet == .base ? Self.baseTabs[slot] == baseTab : Self.weightTabs[slot] == weightTab
        return Image(selected ? tab.iconFilled : tab.icon)
    }

    private func label(at slot: Int) -> String {
        tabSet == .base ? Self.baseTabs[slot].label : Self.weightTabs[slot].label
    }

    // MARK: - 탭별 화면
    //
    // 화면은 **헤더를 그리지 않는다** — 위 툴바가 맡는다 (§6.9 · §7.1, 2026-09-15).

    @ViewBuilder
    private func screen(at slot: Int) -> some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            if tabSet == .base {
                switch Self.baseTabs[slot] {
                case .home:
                    HomeScreen(
                        // TODO: H-03 AI 식단이 붙으면 onDiet 을 연결한다
                        // 홈의 유산소 바로가기 — 세트를 바꾸고 유산소로 바로 들어간다
                        onCardio: {
                            weightTab = .cardio
                            withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                        },
                        // 홈의 오늘의 루틴 카드 — 같은 길로 웨이트(W-01)에 들어간다
                        onWeight: {
                            weightTab = .weight
                            withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                        },
                        // 홈의 마일리지 상품 — 같은 세트 안이라 탭만 옮긴다
                        onStore: { baseTab = .store }
                    )
                case .benefit:
                    BenefitScreen(onAction: { action in
                        // **갈 곳이 있는 줄은 바로 보낸다** (§6.23, 2026-09-02 사용자 지정) —
                        // 랜딩은 여기서 끝내고 돌아가는 활동의 몫이지, 다른 화면으로 가는 길목이 아니다.
                        // 체중·물 마시기는 매일 하는 기록이라 랜딩을 거치지 않는다 (§6.25)
                        switch action.kind {
                        case .weight: open(.weightLog)
                        case .water: open(.water)
                        // 홈의 `오늘의 루틴` · `유산소` 바로가기와 **같은 길**로 세트를 바꾼다
                        case .routine:
                            weightTab = .weight
                            withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                        case .cardio:
                            weightTab = .cardio
                            withAnimation(.snappy(duration: 0.35)) { tabSet = .weight }
                        default: open(.activity(action))
                        }
                    })
                case .store:
                    // 스토어 헤더의 '마이' 는 **마이 탭이 아니다.** 교환에 관한 나(S-08)로 간다.
                    StoreScreen(
                        onItem: { open(.storeItem($0)) },
                        liked: $liked
                    )
                case .my:
                    MyScreen()
                case .weight:
                    Color.clear // 통로
                }
            } else {
                switch Self.weightTabs[slot] {
                case .weight:
                    WeightScreen(onExercise: { open(.workoutDetail($0)) },
                                 onSession: { open(.workoutSession) },
                                 weekOpen: $weekOpen)
                case .cardio:
                    // TODO(C-02): `유산소 시작하기` 는 기기 NFC 스캔이 붙으면 연결한다
                    CardioScreen(onStore: {
                        // 유산소의 `주문` 칸 — 세트를 되돌리고 스토어로 보낸다
                        baseTab = .store
                        withAnimation(.snappy(duration: 0.35)) { tabSet = .base }
                    })
                case .ranking:
                    PlaceholderScreen(id: "R-01", title: "랭킹", description: "웨이트 · 유산소 · 마일리지")
                case .group:
                    GroupScreen(onCreate: { open(.groupCreate) })
                case .back:
                    Color.clear // 통로
                }
            }
        }
    }
}
