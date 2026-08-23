import SwiftUI

/// 모든 화면이 올라앉는 배경. 순검정 위에 하단 탭 바만 있다.
///
/// **하단 바는 네이티브 `TabView` 를 쓴다.** iOS 26 이상에서는 시스템이 Liquid Glass
/// 탭 바로 그려준다 — 선택 인디케이터·모션·스크롤 시 축소까지 전부 Apple 구현이다.
/// 손으로 흉내 내면 재질만 비슷하고 나머지가 어긋난다.
///
/// SPEC.md §3 — 웨이트 탭을 누르면 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
struct AppShell: View {
    @State private var tabSet: TabSet = .base
    @State private var baseTab: BaseTab = .home
    @State private var weightTab: WeightTab = .weight

    var body: some View {
        Group {
            switch tabSet {
            case .base: baseTabView
            case .weight: weightTabView
            }
        }
        .tint(MyFisColor.accent)
        .animation(.easeInOut(duration: 0.2), value: tabSet)
    }

    // MARK: - 기본 세트: 홈 / 혜택 / 스토어 / 웨이트 / 마이

    private var baseTabView: some View {
        TabView(selection: baseSelection) {
            screen(id: "H-01", title: "홈", description: "회원권 상태 · 오늘 할 운동 · 마일리지")
                .tabItem { Label(BaseTab.home.label, systemImage: BaseTab.home.symbol) }
                .tag(BaseTab.home)

            screen(id: "P-01", title: "혜택", description: "보유 마일리지 · 적립 경로")
                .tabItem { Label(BaseTab.benefit.label, systemImage: BaseTab.benefit.symbol) }
                .tag(BaseTab.benefit)

            screen(id: "S-01", title: "스토어", description: "마일리지로 굿즈·음료 교환")
                .tabItem { Label(BaseTab.store.label, systemImage: BaseTab.store.symbol) }
                .tag(BaseTab.store)

            // 통로다. 선택되지 않고 세트만 바꾼다.
            Color.clear
                .tabItem { Label(BaseTab.weight.label, systemImage: BaseTab.weight.symbol) }
                .tag(BaseTab.weight)

            // TODO: Y-01 마이 화면이 붙으면 교체한다.
            // 그때까지 토큰 확인 화면을 여기 둔다 — 스크롤 콘텐츠가 있어야
            // 유리 바 뒤로 뭐가 지나가는지 확인할 수 있다.
            DesignTokensView()
                .tabItem { Label(BaseTab.my.label, systemImage: BaseTab.my.symbol) }
                .tag(BaseTab.my)
        }
    }

    /// 웨이트는 목적지가 아니라 통로다. `baseTab` 을 바꾸지 않아야
    /// `이전` 으로 돌아왔을 때 보던 탭으로 복귀한다.
    private var baseSelection: Binding<BaseTab> {
        Binding(
            get: { baseTab },
            set: { new in
                if new == .weight { tabSet = .weight } else { baseTab = new }
            }
        )
    }

    // MARK: - 웨이트 세트: 이전 / 웨이트 / 유산소 / 랭킹 / 모임

    private var weightTabView: some View {
        TabView(selection: weightSelection) {
            // 나가는 길. 항상 첫 번째 자리에 고정한다 (DESIGN.md §6.7).
            Color.clear
                .tabItem { Label(WeightTab.back.label, systemImage: WeightTab.back.symbol) }
                .tag(WeightTab.back)

            screen(id: "W-01", title: "이번 주 루틴", description: "AI가 보낸 주간 루틴")
                .tabItem { Label(WeightTab.weight.label, systemImage: WeightTab.weight.symbol) }
                .tag(WeightTab.weight)

            screen(id: "C-01", title: "유산소", description: "기기 목록 · NFC 스캔")
                .tabItem { Label(WeightTab.cardio.label, systemImage: WeightTab.cardio.symbol) }
                .tag(WeightTab.cardio)

            screen(id: "R-01", title: "랭킹", description: "웨이트 · 유산소 · 마일리지")
                .tabItem { Label(WeightTab.ranking.label, systemImage: WeightTab.ranking.symbol) }
                .tag(WeightTab.ranking)

            screen(id: "G-01", title: "모임", description: "모임 · 커뮤니티")
                .tabItem { Label(WeightTab.group.label, systemImage: WeightTab.group.symbol) }
                .tag(WeightTab.group)
        }
    }

    private var weightSelection: Binding<WeightTab> {
        Binding(
            get: { weightTab },
            set: { new in
                if new == .back { tabSet = .base } else { weightTab = new }
            }
        )
    }

    // MARK: -

    private func screen(id: String, title: String, description: String) -> some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()
            PlaceholderScreen(id: id, title: title, description: description)
        }
    }
}

#Preview {
    AppShell().preferredColorScheme(.dark)
}
