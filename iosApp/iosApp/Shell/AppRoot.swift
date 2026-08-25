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

    var body: some View {
        ZStack {
            // 잎이 반투명하면 뒤가 비치므로, 바탕은 여기서 한 번만 깐다
            MyFisColor.bgBase.ignoresSafeArea()

            TabShell(open: open)
                // 덮인 셸에는 손이 닿지 않는다
                .allowsHitTesting(pages.isEmpty)

            ForEach(Array(pages.enumerated()), id: \.offset) { index, route in
                leaf(route)
                    .zIndex(Double(index + 1))
                    .transition(.move(edge: .trailing))
            }
        }
        .task {
            MyFisDebug.applySlowMotionIfNeeded()
            MyFisDebug.scheduleAutoNavigation(open: open, back: back)
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
            default:
                // TODO: 화면이 하나씩 붙는다 — S-06 장바구니 · S-07 검색 · S-08 스토어 마이
                VStack(spacing: 0) {
                    DetailHeader(title: route.title, onBack: back)
                    PlaceholderScreen(
                        id: leafSpecID(route),
                        title: route.title,
                        description: "화면은 다음 단계에서 붙인다"
                    )
                }
            }
        }
    }

    private func leafSpecID(_ route: Route) -> String {
        switch route {
        case .notifications: "H-02"
        case .storeMy: "S-08"
        case .storeCart: "S-06"
        case .storeSearch: "S-07"
        }
    }
}

#Preview {
    AppRoot().preferredColorScheme(.dark)
}
