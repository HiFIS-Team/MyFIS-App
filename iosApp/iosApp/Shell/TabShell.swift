import SwiftUI
import UIKit

/// 탭 셸 — **탭 자리마다 내비게이션 스택** + 하단 유리 탭 바.
///
/// 하단 바는 네이티브 `TabView` 를 쓴다 (§2 원칙 6) — iOS 26 이 Liquid Glass 로 그리고
/// 선택 인디케이터·모션·스크롤 축소까지 전부 Apple 구현이다.
///
/// **스택은 탭 안에 있다** 🟢 (2026-09-15, 사용자 지적 — *"하단바로 이동할때 헤더랑 히어로랑 따로 노는데"*).
/// 스택이 탭 밖이면 내비 바가 앱에 하나라, 탭을 누르는 순간 **헤더가 먼저 바뀌고 본문이 나중에** 바뀌었다.
/// 탭마다 스택을 두면 헤더가 그 탭 화면의 일부라 **한 장으로 같이** 바뀐다 (크림 · 대부분의 UIKit 앱과 같은 짜임).
/// - 잎은 **지금 탭의 스택**에 쌓이고 하단 탭 바를 숨긴다 (`.toolbar(.hidden, for: .tabBar)`)
/// - 탭을 옮겼다 돌아오면 그 탭에서 열어 둔 잎이 그대로다 (시스템 탭 동작)
/// - 탭 세트를 바꾸면 스택을 전부 비운다 — 자리(슬롯)는 같아도 화면이 다르다
///
/// SPEC.md §3 — 웨이트 탭을 누르면 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
/// **세트 교체는 TabView 를 갈아끼우지 않는다.** 슬롯 5개짜리 `TabView` 하나를 유지하고
/// 각 슬롯의 아이콘·콘텐츠만 바꾼다 — 그래야 바가 파괴·재생성되지 않는다.
struct TabShell<Leaf: View>: View {
    let open: (Route) -> Void
    /// 찜 — 스토어 홈과 검색 잎이 나눠 쓴다 (뿌리가 들고 있다)
    @Binding var liked: Set<Int>
    /// 최근 검색 — 스토어 머리 검색과 검색 잎이 나눠 쓴다 (뿌리가 들고 있다)
    @Binding var storeRecents: SearchRecents
    /// 최근 검색 — 모임 머리 검색과 모임 검색 잎이 나눠 쓴다 (뿌리가 들고 있다)
    @Binding var groupRecents: SearchRecents
    /// 지금 선택된 자리 — 뿌리가 잎을 **어느 스택에** 쌓을지 여기서 안다
    @Binding var activeSlot: Int
    /// 자리마다 스택
    @Binding var paths: [[Route]]
    /// 잎 화면 — 뿌리가 만든다 (잎이 쓰는 상태를 뿌리가 들고 있다)
    @ViewBuilder let leaf: (Route) -> Leaf

    // 제네릭 타입이라 저장 static 을 못 둔다 — 계산으로 둔다
    private static var baseTabs: [BaseTab] { BaseTab.allCases }
    private static var weightTabs: [WeightTab] { WeightTab.allCases }

    @State private var tabSet: TabSet = MyFisDebug.initialTabSet
    @State private var baseTab: BaseTab = MyFisDebug.initialBaseTab
    @State private var weightTab: WeightTab = MyFisDebug.initialWeightTab
    /// 웨이트 요일 띠 — 여닫는 칩이 툴바에 있어서 셸이 든다
    @State private var weekOpen = MyFisDebug.weightWeekOpen
    /// 스토어 머리 검색 — **셸이 든다.** 검색창은 스토어 화면이 제목 자리에 달고, `취소` 는 이 셸의 툴바에 있다 (§6.9)
    @State private var storeQuery = MyFisDebug.storeSearchOpen ? MyFisDebug.searchQuery : ""
    @State private var storeSearching = MyFisDebug.storeSearchOpen
    /// 모임 머리 검색 — 시스템 검색 버튼이 펼쳐진다 (`NavigationBarSearch`, 2026-09-15)
    @State private var groupQuery = MyFisDebug.groupHeaderQuery
    @State private var groupSearching = false
    /// 화면 폭 — 검색칸 폭을 계산한다 (`storeSearchWidth` · `groupSearchWidth`)
    @State private var shellWidth: CGFloat = 0

    /// 스토어 검색칸 폭 — 화면 폭 − 양끝 여백 − 알약 사이 − 오른쪽 알약.
    /// 오른쪽 알약 치수는 iOS 26 시스템 값이라 **실측해서 토큰으로 뒀다** (DESIGN §6.9)
    ///
    /// **검색 중엔 `취소` 가 좁은 만큼 넓어진다** (크림, 2026-09-15 사용자 — *"검색할때는 더 넓어져야 하는거 아닌가"*).
    /// 폭은 켜짐만 따르고, 켜고 끄는 `withAnimation` 을 같이 탄다 (`cancelStoreSearch`)
    private var storeSearchWidth: CGFloat {
        searchWidth(trailing: storeSearching ? MyFisSize.toolbarCancelPlatter : MyFisSize.toolbarPairPlatter)
    }

    private func searchWidth(trailing: CGFloat) -> CGFloat {
        let width = shellWidth - MyFisSize.toolbarEdge * 2 - MyFisSize.toolbarPlatterGap - trailing
            - MyFisSize.toolbarFieldInset * 2
        return max(MyFisSize.minTouchTarget, width)
    }

    /// 스토어 검색 끄기 — `취소` · 디버그가 같이 쓴다.
    ///
    /// **끄기와 좁히기를 한 애니메이션에** 🟢 (60fps 넷 비교, 2026-09-15 사용자 — *"접힐때는 바로 확접히네"*)
    /// - ✅ 같은 순간 — 검색칸이 네다섯 장에 걸쳐 좁아지고 돋보기 · 글자는 제자리
    /// - ❌ 먼저 좁히고 0.05초 뒤 끄기 — 좁히기가 애니메이션 밖이라 **한 장 만에 확 접혔다**
    /// - ❌ 폭에 애니메이션을 태우기(같은 순간 · 먼저 좁히기 둘 다) — 돋보기 · 글자가 **왼쪽으로 튀어 잘렸다**
    /// - ❌ 전환이 끝난 뒤 좁히기 — 넓은 칸 옆에 아이콘 알약이 안 들어가 `…` 로 접혔다
    private func cancelStoreSearch() {
        storeQuery = ""
        withAnimation(MyFisMotion.slow) { storeSearching = false }
    }

    private func cancelGroupSearch() {
        groupQuery = ""
        withAnimation(MyFisMotion.base) { groupSearching = false }
    }

    var body: some View {
        TabView(selection: selection) {
            ForEach(0..<Self.baseTabs.count, id: \.self) { slot in
                NavigationStack(path: $paths[slot]) {
                    screen(at: slot)
                        .toolbar { toolbar(at: slot) }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationDestination(for: Route.self) { route in
                            // 잎은 하단 탭 바를 덮는다 — 탭 바는 `TabBarPush` 가 화면과 함께 밀어낸다.
                            // ⚠️ `.toolbar(.hidden, for: .tabBar)` 를 쓰지 않는다 — 전환과 따로 툭 사라지고 툭 나타났다
                            leaf(route)
                        }
                }
                // **세트가 바뀌면 스택을 새로 만든다** 🟢 (2026-09-15, 사용자 지적 — 하단바로 옮길 때 헤더 유리에 옆에서 들어올 때 같은 애니메이션).
                // 같은 칸에서 내용만 갈아 끼우면 iOS 가 "같은 내비 바의 아이템 교체"로 보고 헤더를 비웠다가 유리를 번지게 다시 띄웠다
                // (웨이트 · 이전 누를 때, 60fps 녹화로 확인). 새 스택이면 헤더가 페이지와 같이 바뀐다 — 기본 세트 탭끼리 옮길 때와 같다.
                // ❌ 두 세트 스택을 칸마다 살려 두고 겹쳐 바꾸는 방식도 해 봤다 — 탭 바가 먼저 바뀌는 건 그대로였고,
                //    같은 칸에 살려 둔 **다른 세트 화면(혜택)이 겹쳐 바뀌는 도중에 비쳤다** (60fps). 되돌렸다
                .id(tabSet)
                .tabItem { icon(at: slot).accessibilityLabel(label(at: slot)) }
                .tag(slot)
            }
        }
        // 선택은 **색이 아니라 채움**으로 알린다 (§6.7).
        // 라임은 화면 콘텐츠 몫이다 — 항상 켜져 있는 바가 액센트 예산을 먹으면 안 된다.
        .tint(MyFisColor.textPrimary)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { shellWidth = $0 }
        .onChange(of: currentSlot, initial: true) { _, now in
            activeSlot = now
            labelTabs()
        }
        // 세트를 바꾸면 자리는 같아도 화면이 다르다 — 쌓아 둔 잎을 비운다
        .onChange(of: tabSet) { _, _ in
            paths = Array(repeating: [], count: paths.count)
            // 스택을 새로 만들므로 머리 검색도 닫는다 — 돌아왔을 때 키보드가 불쑥 올라오지 않게
            storeQuery = ""
            storeSearching = false
            groupQuery = ""
            groupSearching = false
            // **탭 바 아이콘도 페이지처럼 겹쳐 바꾼다** (2026-09-15, 사용자 — 3번 "거슬리는거 있으면 그것도 해").
            // 그냥 두면 아이콘 다섯 개가 누르는 순간 한꺼번에 갈리고, 페이지는 시스템 전환이라 겹쳐 흐려진다
            UITabBarController.myFisCrossfadeTabBar(duration: MyFisMotion.baseDuration)
            // 자리 번호가 같은 채 세트만 바뀌기도 한다 (혜택 1 ↔ 웨이트 1) — 이름을 다시 단다
            labelTabs()
        }
        .task {
            // **통로 칸(웨이트 · 이전)은 UIKit 이 고르지 않게 하고 선택값만 바꾼다** 🟢 (2026-09-15, `TabBarPush` · §7.1).
            // 누르면 UIKit 이 통로 칸으로 전환을 시작했다가 SwiftUI 가 진짜 칸으로 되돌려, 페이지는 툭 · 헤더는 늦게 번지며 떴다
            UITabBarController.myFisTakeOverSelection = { slot in
                guard isPassage(slot) else { return false }
                DispatchQueue.main.async { selection.wrappedValue = slot }
                return true
            }
            MyFisDebug.scheduleAutoTab { baseTab = $0 }
            MyFisDebug.scheduleAutoSlot { selection.wrappedValue = $0 }
            MyFisDebug.scheduleAutoTap()
            MyFisDebug.scheduleNavTap()
            MyFisDebug.scheduleStoreSearch(
                open: { withAnimation(MyFisMotion.slow) { storeSearching = true } },
                cancel: cancelStoreSearch
            )
            MyFisDebug.scheduleGroupSearch(
                open: { withAnimation(MyFisMotion.slow) { groupSearching = true } },
                cancel: cancelGroupSearch
            )
        }
    }

    /// 지금 선택된 자리
    private var currentSlot: Int {
        tabSet == .base ? Self.baseTabs.firstIndex(of: baseTab)! : Self.weightTabs.firstIndex(of: weightTab)!
    }

    // MARK: - 툴바 (탭 화면 헤더)
    //
    // **탭 화면 헤더는 시스템 툴바다** 🟢 (2026-09-15, §6.9 · §7.1). 각 자리 스택의 뿌리 화면에 단다.
    // 잎이 밀려 들어오면 이 아이템들이 잎의 뒤로 · 액션으로 **녹아 바뀐다** (iOS 26 유리).
    // 화면 이름 · 칩은 유리를 씌우지 않는다 (`withoutGlass`) — 판이 없어야 하거나 자기 판이 있다

    @ToolbarContentBuilder
    private func toolbar(at slot: Int) -> some ToolbarContent {
        if tabSet == .base && Self.baseTabs[slot] == .home { homeToolbar }
        if tabSet == .base && Self.baseTabs[slot] == .benefit { benefitToolbar }
        if tabSet == .base && Self.baseTabs[slot] == .store { storeToolbar }
        if tabSet == .base && Self.baseTabs[slot] == .my { myToolbar }
        if tabSet == .weight && Self.weightTabs[slot] == .weight { weightToolbar }
        if tabSet == .weight && Self.weightTabs[slot] == .cardio { cardioToolbar }
        if tabSet == .weight && Self.weightTabs[slot] == .group { groupToolbar }
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
        // **마일리지 칩은 뺐다** 🟢 (2026-09-15, 사용자 — *"스토어에서 마일리지 표기는 일단 없애버려 어디에 둘지 같이 고민해보게"*).
        // 🔵 어디에 둘지 미정
        //
        // **왼쪽 검색칸은 툴바에 없다 — 스토어 페이지에 붙어 있다** 🟢 (`PageHeaderSearchField`, 크림 60fps, 2026-09-15).
        // 잎이 드나들 때 페이지와 같이 밀리고, 뒤로 버튼 원과 섞이지 않는다.
        // ❌ 왼쪽 툴바 항목 — 시스템이 넓은 알약을 뒤로 버튼 원으로 녹여 **날개 달린 원**이 남았다. 뺐다가 전환 뒤 넣기로 막았지만 검색칸이 사라졌다 나타났다 (사용자 지적)
        // ❌ 제목 자리 — 알약보다 5pt 아래였고, 잎에 다녀오면 유리 판만 사라졌다 (사용자 지적)
        // 오른쪽은 **항목 그룹** — 장바구니 · 마이 ↔ `취소`. 시스템이 알약을 녹여 바꾼다 (60fps 확인)
        // ⚠️ 항목 하나 안에 아이콘 둘을 넣었다가 **간격이 시스템보다 좁아졌다** (알약 104 → 84pt, 사용자 지적) — 그룹이면 시스템이 잡는다
        // `마이` 는 **마이 탭이 아니다** — 교환에 관한 나(S-08)로 간다
        ToolbarItemGroup(placement: .topBarTrailing) {
            if storeSearching {
                Button("취소", action: cancelStoreSearch)
                    .font(MyFisFont.body)
            } else {
                ToolbarIcon("ic_header_cart", "장바구니") { open(.storeCart) }
                ToolbarIcon("ic_header_my", "마이") { open(.storeMy) }
            }
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
    ///
    /// **돋보기는 시스템 검색 버튼이다** 🟢 — 누르면 시스템이 검색창으로 펼치고 닫기(✕)를 붙인다 (`NavigationBarSearch`, 화면 뒤에 깔림).
    /// 툴바에는 화면 이름만 둔다 — 검색 중엔 시스템이 알아서 가린다 (2026-09-15, 60fps)
    /// - ❌ 오른쪽 툴바 항목에 입력칸을 넣고 폭을 늘리기 — 접힌 원 안 돋보기가 치우쳤고, `취소` 가 끼어들 때
    ///   **빈 원 · 네모 날개**가 생겼다 사라졌다 (사용자 지적)
    /// - ❌ 제목 · 돋보기를 검색칸 · `취소` 로 바꿔 끼우기 — 펼쳐지지 않고 흐려지며 나타났다
    /// - ❌ SwiftUI `searchToolbarBehavior(.minimize)` — 코드로 켜니 펼쳐지지 않았다
    @ToolbarContentBuilder
    private var groupToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            ToolbarScreenTitle("모임")
        }
        .withoutGlass()
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

    /// 탭 이름을 VoiceOver 에 알린다 — 바 항목은 선택 · 세트가 바뀌면 다시 그려져 **다음 런루프**에 단다 (`TabBarPush`)
    private func labelTabs() {
        let labels = (0..<Self.baseTabs.count).map(label(at:))
        DispatchQueue.main.async { UITabBarController.myFisLabelTabs(labels) }
    }

    /// 통로 칸 — 목적지가 아니라 **세트를 바꾸는 자리**다 (기본 세트 `웨이트` · 웨이트 세트 `이전`)
    private func isPassage(_ slot: Int) -> Bool {
        tabSet == .base ? Self.baseTabs[slot] == .weight : Self.weightTabs[slot] == .back
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
                        liked: $liked,
                        query: $storeQuery,
                        searching: $storeSearching,
                        recents: $storeRecents
                    )
                    // 머리 검색칸 — 페이지에 붙어 잎이 드나들 때 같이 밀린다 (크림)
                    .overlay {
                        PageHeaderSearchField(text: $storeQuery, active: $storeSearching, placeholder: "상품 검색",
                                              width: storeSearchWidth, onSubmit: { storeRecents.add($0) })
                    }
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
                    GroupScreen(onCreate: { open(.groupCreate) },
                                query: $groupQuery,
                                searching: $groupSearching,
                                recents: $groupRecents)
                        .background {
                            NavigationBarSearch(text: $groupQuery, active: $groupSearching, placeholder: "모임 검색",
                                                onSubmit: { groupRecents.add($0) })
                        }
                case .back:
                    Color.clear // 통로
                }
            }
        }
    }
}
