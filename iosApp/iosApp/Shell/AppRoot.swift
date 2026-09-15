import SwiftUI

/// 앱의 뿌리 — 안드로이드 `AppShell` 의 `NavHost` 와 같은 자리.
///
/// ```
/// NavigationStack       ← 시스템 내비 바 · push · 뒤로 버튼 · 가장자리 쓸기
/// ├── TabShell (뿌리)    ← 탭 콘텐츠 + 하단 유리 탭 바 + **탭별 툴바**
/// └── pages[…]          ← 오른쪽에서 밀려 들어와 셸을 통째로 덮는다 (탭 바까지)
/// ```
///
/// **시스템 내비게이션을 쓴다** 🟢 (2026-09-15, 사용자 지정 — *"그냥 크림처럼 하고싶다 크림처럼 해봐"*).
/// 옆에서 화면이 들어올 때 헤더 유리가 새 화면 아이콘으로 녹아 바뀌는 것(iOS 26)은 시스템 내비 바만 한다.
/// 2026-08-25 에 끄고 직접 만들었던 덮개(`ZStack` · 가장자리 스와이프 · 패럴랙스)를 걷었다 — 경위는 DESIGN §7.1
/// - 스택은 **탭 밖**이다. 그래야 잎이 하단 탭 바까지 덮는다
/// - 탭 화면 헤더는 `TabShell` 이 툴바로 올린다 — 스택이 탭 밖이면 탭 안 화면의 `.toolbar` 는 안 올라온다
/// - 잎 화면은 **자기 툴바를 자기가 단다** (`navigationTitle` · `.toolbar`)
/// - 뒤 화면 패럴랙스 · 전환 시간은 시스템 값이다
struct AppRoot: View {
    @State private var pages: [Route] = MyFisDebug.initialRoutes
    /// 찜 — 스토어 홈과 검색 잎(S-07)이 나눠 쓴다. TODO(서버): 계정에 붙는다
    @State private var liked: Set<Int> = []
    /// 최근 검색 — 잎이 열렸다 닫혀도 남아야 하므로 셸이 든다. TODO(서버): 계정에 붙는다
    @State private var storeRecents = SearchRecents()
    @State private var groupRecents = SearchRecents()
    /// 물 마시기 미션 시각 — 두 화면이 나눠 쓴다. TODO(서버): 회원 설정으로 옮긴다 (SPEC P-05)
    @State private var waterTimes = WaterSlot.defaultTimes
    // 개설 화면과 지역 설정이 나눠 쓴다 — 잎이 둘이라 셸이 들고 있는다 (상품 상세와 같다)
    @State private var groupRegion: String? = MyFisDebug.groupCreateRegion
    /// 토스트 — **셸이 든다.** 잎에서 한 일도 잎이 걷힌 뒤에 알려야 한다 (§6.35)
    @State private var toasts = ToastCenter()

    var body: some View {
        NavigationStack(path: $pages) {
            TabShell(open: open, liked: $liked)
                .navigationDestination(for: Route.self) { route in
                    leaf(route)
                }
        }
        // 툴바 아이콘 · 시스템 뒤로 버튼 색 — 라임은 콘텐츠 몫이다 (§6.7 탭 바와 같다)
        .tint(MyFisColor.textPrimary)
        // **잎보다도 위다** — 잎에서 한 일을 잎이 걷히면서 알려야 한다
        .overlay { ToastLayer(center: toasts) }
        .ignoresSafeArea(.keyboard)
        .task {
            // 유산소 `ORDER` 칸의 잔은 프레임 57장이라 **화면에서 풀면 늦는다** (§6.28).
            // 앱이 뜰 때 배경에서 미리 펴 둔다 — 도착했을 땐 준비돼 있다
            if let toast = MyFisDebug.initialToast { toasts.show(toast, kind: MyFisDebug.initialToastKind) }
            // 지난번에 앱이 죽으며 남긴 운동 세션 잠금화면을 치운다 — 세션은 메모리라 이어 받을 수 없다
            WorkoutSessionStore.shared.endOrphans()
            AnimatedDrink.prewarm()
            MyFisDebug.applySlowMotionIfNeeded()
            MyFisDebug.scheduleAutoNavigation(open: open, back: back)
        }
    }

    // MARK: - 이동
    //
    // 화면은 스스로 이동하지 않는다. 콜백으로 여기에 **요청**한다 (안드로이드와 같다).
    // 시스템 뒤로 버튼 · 가장자리 쓸기는 스택이 `pages` 를 직접 줄인다.

    private func open(_ route: Route) {
        // 세션은 **밀어 넣기 전에** 연다 — 화면이 첫 프레임부터 새 시계를 그리고,
        // 지난 세션의 마지막 모습이 밀려 들어오지 않는다 (§6.37)
        if case .workoutSession = route {
            WorkoutSessionStore.shared.start(WorkoutSessionPlaceholder.steps)
        }
        pages.append(route)
    }

    private func back() {
        if !pages.isEmpty { pages.removeLast() }
    }

    private func toggleLike(_ id: Int) {
        if liked.contains(id) { liked.remove(id) } else { liked.insert(id) }
    }

    /// 셸까지 한 번에 돌아간다 (예: 장바구니에서 "상품 보러 가기")
    private func backToShell() {
        pages.removeAll()
    }

    /// 잎 화면 하나. **불투명하게 화면 전체를 채운다** — 뒤가 비치면 겹쳐 보인다.
    @ViewBuilder
    private func leaf(_ route: Route) -> some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            switch route {
            case .notifications:
                NotificationScreen(onBack: back)
            case .storeItem(let item):
                StoreItemScreen(
                    item: item,
                    onBack: back,
                    // 검색은 잎이다 — 상세 위에 얹는다. 닫으면 상세로 돌아온다
                    onSearch: { open(.storeSearch) },
                    onCart: { open(.storeCart) }
                )
            case .activity(let action):
                ActivityIntroScreen(action: action, onClose: back)
            case .weightLog:
                WeightLogScreen(onBack: back)
            case .workoutDetail(let exercise):
                WorkoutDetailScreen(exercise: exercise, onBack: back)
            case .workoutSession:
                // TODO(W-05): 완료 화면이 붙으면 그리로 간다. 지금은 셸로 돌아가며 알린다
                WorkoutSessionScreen(onExit: back,
                                     onFinish: { back(); toasts.show("오늘 운동을 마쳤어요") })
            case .storeCart:
                StoreCartScreen(onBack: back, onStore: backToShell)
            case .storeSearch:
                StoreSearchScreen(liked: $liked, recents: $storeRecents, onBack: back,
                                  onItem: { open(.storeItem($0)) },
                                  onLike: toggleLike)
            case .groupSearch:
                // TODO(G-02): 모임 상세가 붙으면 결과 줄을 잇는다
                GroupSearchScreen(recents: $groupRecents, onBack: back)
            case .storeMy:
                StoreMyScreen(onBack: back, onCart: { open(.storeCart) })
            case .branch:
                BranchScreen(onBack: back)
            case .water:
                WaterScreen(times: waterTimes, onClose: back,
                            onChangeTime: { open(.waterTime) })
            case .waterTime:
                WaterTimeScreen(times: waterTimes,
                                onSave: { waterTimes = $0 },
                                onBack: back)
            case .groupCreate:
                // TODO(G-03 2단계): 소개·정원을 묻는 다음 장이 붙으면 `onNext` 를 잇는다
                GroupCreateScreen(onClose: back,
                                  onSearchRegion: { open(.groupRegion) },
                                  onNext: { _, _, _ in open(.groupIntro) },
                                  region: $groupRegion)
            case .groupRegion:
                RegionSearchScreen(onBack: back, onPick: { groupRegion = $0; back() })
            case .groupIntro:
                // TODO(서버): `모임 만들기` 가 실제로 모임을 만든다. 지금은 셸로 돌아간다
                GroupIntroScreen(onClose: { back(); back() }, onBack: back,
                                 onCreate: { _ in
                                     back(); back()
                                     toasts.show("모임을 만들었어요")
                                 })
            }
        }
    }

}

#Preview {
    AppRoot().preferredColorScheme(.dark)
}
