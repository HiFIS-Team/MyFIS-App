import SwiftUI

/// 앱의 뿌리 — 안드로이드 `AppShell` 의 `NavHost` 와 같은 자리.
///
/// ```
/// ZStack
/// ├── TabShell     ← 헤더 + 탭 콘텐츠 + 하단 유리 탭 바. 잎이 덮어도 **안 움직인다**
/// └── pages[…]     ← 오른쪽에서 밀려 들어와 셸을 통째로 덮는다 (탭 바까지)
/// ```
///
/// **왜 `NavigationStack` 을 쓰지 않나** (2026-08-25 결정, DESIGN.md §7.1)
/// - 내비 바는 화면들이 **공유하는 크롬**이라, 화면이 바뀔 때마다 시스템이 아이템을
///   morph 시킨다 — 유리 껍데기, 뒤로 버튼 옆 그루터기, 아이콘이 좌우로 밀리는 것 전부 그 결과다
/// - 잎이 탭 안에서 밀리면 하단 유리 탭 바를 덮을 수 없어 **가시성을 상태로 토글**해야 했고,
///   그러면 툭 사라지고 툭 생긴다
/// - 헤더를 화면이 그리면 헤더는 화면과 **함께** 움직인다. 따로 노는 것이 없다
///
/// **셸은 밀려 나가지 않는다.** 안드로이드도 그렇다 (`exitTransition = None`) —
/// 셸이 같이 움직이면 하단 바가 왕복하는 게 눈에 걸린다.
struct AppRoot: View {
    @State private var pages: [Route] = MyFisDebug.initialRoutes
    /// 스토어 검색 모드. **잎이 아니라 셸의 상태다** — 상품 상세의 검색 버튼도 이걸 켠다 (§6.9)
    @State private var storeSearching = MyFisDebug.startsInSearch
    /// 가장자리 스와이프로 끌고 있는 거리
    @State private var drag: CGFloat = 0

    /// 여기서 시작한 드래그만 뒤로가기로 본다 (§7.1)
    private static let edge: CGFloat = 24
    /// 이만큼 끌었으면 손을 떼도 닫는다
    private static let closeDistance: CGFloat = 90

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // 잎이 반투명하면 뒤가 비치므로, 바탕은 여기서 한 번만 깐다
                MyFisColor.bgBase.ignoresSafeArea()

                TabShell(open: open, storeSearching: $storeSearching)
                    // 덮인 셸에는 손이 닿지 않는다
                    .allowsHitTesting(pages.isEmpty)

                ForEach(Array(pages.enumerated()), id: \.offset) { index, route in
                    let isTop = index == pages.count - 1
                    // 아래에서 올라온 화면은 **옆으로 끌어 닫지 않는다** — 옆으로 끌다
                    // 아래로 사라지면 방향이 어긋나 화면이 튄다. 닫기는 헤더의 X 다
                    let swipeable = isTop && !route.risesFromBottom
                    leaf(route)
                        .offset(x: swipeable ? drag : 0)
                        .zIndex(Double(index + 1))
                        .transition(.move(edge: route.risesFromBottom ? .bottom : .trailing))
                        .gesture(swipeable ? edgeBack(width: proxy.size.width) : nil)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .task {
            MyFisDebug.applySlowMotionIfNeeded()
            MyFisDebug.scheduleAutoNavigation(open: open, back: back)
        }
    }

    /// 왼쪽 가장자리에서 오른쪽으로 쓸면 잎을 걷는다 — 안드로이드 시스템 뒤로가기에 맞춘다.
    ///
    /// ⚠️ 예전에 화면 전체에 `simultaneousGesture(DragGesture())` 를 걸었다가
    /// **버튼 탭을 삼켜서** "나가기를 연타해야 나가지는" 버그가 났다. 두 가지로 막는다 —
    /// 1. `minimumDistance` 를 줘서 **움직이지 않는 탭은 제스처가 되지 않는다**
    /// 2. `simultaneousGesture` 가 아니라 `gesture` 로 걸고, **가장자리에서 시작한 것만** 받는다
    private func edgeBack(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged { value in
                guard value.startLocation.x <= Self.edge else { return }
                // 세로로 긋는 손짓은 안쪽 스크롤 몫이다
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                drag = max(0, value.translation.width)
            }
            .onEnded { value in
                guard value.startLocation.x <= Self.edge else { return }
                let flung = value.predictedEndTranslation.width > 240
                guard drag > Self.closeDistance || flung else {
                    withAnimation(MyFisMotion.base) { drag = 0 }
                    return
                }
                // **손가락 위치에서 이어서 화면 밖까지 밀어낸 뒤 걷는다.**
                // 바로 걷으면 `.transition` 이 같이 돌아 화면이 한 번 튄다 (확인함)
                withAnimation(MyFisMotion.base) {
                    drag = width
                } completion: {
                    var snap = Transaction()
                    snap.disablesAnimations = true
                    withTransaction(snap) {
                        _ = pages.popLast()
                        drag = 0
                    }
                }
            }
    }

    // MARK: - 이동
    //
    // 화면은 스스로 이동하지 않는다. 콜백으로 여기에 **요청**한다 (안드로이드와 같다).

    /// 전환은 DESIGN.md §7 `slow` (320ms) — 안드로이드 `pushSpec` 과 같은 값
    private func open(_ route: Route) {
        withAnimation(MyFisMotion.slow) { pages.append(route) }
    }

    private func back() {
        withAnimation(MyFisMotion.slow) { _ = pages.popLast() }
        drag = 0
    }

    /// 셸까지 한 번에 돌아간다 (예: 장바구니에서 "상품 보러 가기")
    private func backToShell() {
        withAnimation(MyFisMotion.slow) { pages.removeAll() }
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
                    // 검색은 스토어의 모드라, 상세에서 누르면 **스토어로 돌아가 검색을 켠다**
                    onSearch: { backToShell(); storeSearching = true },
                    onCart: { open(.storeCart) }
                )
            case .activity(let action):
                // 활동 화면은 갈래마다 따로 만든다 (2026-08-27). 만들 때까지 자리만 둔다
                VStack(spacing: 0) {
                    DetailHeader(title: action.title, onBack: back,
                                 backIcon: "ic_header_close", backLabel: "닫기")
                    PlaceholderScreen(id: "\(action.kind)", title: action.title,
                                      description: action.reward)
                }
            case .weightLog:
                WeightLogScreen(onBack: back)
            case .storeCart:
                StoreCartScreen(onBack: back, onStore: backToShell)
            case .storeMy:
                StoreMyScreen(onBack: back, onCart: { open(.storeCart) })
            case .branch:
                BranchScreen(onBack: back)
            }
        }
    }

}

#Preview {
    AppRoot().preferredColorScheme(.dark)
}
