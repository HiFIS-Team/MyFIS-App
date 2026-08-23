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
    }

    @State private var tabSet: TabSet = .initialForDebug
    @State private var baseSlot = 0
    @State private var weightSlot = 1

    var body: some View {
        TabView(selection: selection) {
            ForEach(0..<Slot.count, id: \.self) { slot in
                content(for: slot)
                    .tabItem {
                        Image(systemName: symbol(for: slot))
                            .accessibilityLabel(label(for: slot))
                    }
                    .tag(slot)
            }
        }
        .tint(MyFisColor.accent)
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

    private func symbol(for slot: Int) -> String {
        tabSet == .base ? baseTabs[slot].symbol : weightTabs[slot].symbol
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
                screen(id: "H-01", title: "홈", description: "회원권 상태 · 오늘 할 운동 · 마일리지")
            case .benefit:
                screen(id: "P-01", title: "혜택", description: "보유 마일리지 · 적립 경로")
            case .store:
                screen(id: "S-01", title: "스토어", description: "마일리지로 굿즈·음료 교환")
            case .my:
                // TODO: Y-01 마이 화면이 붙으면 교체한다.
                // 그때까지 토큰 확인 화면을 여기 둔다 — 스크롤 콘텐츠가 있어야
                // 유리 바 뒤로 뭐가 지나가는지 확인할 수 있다.
                DesignTokensView()
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
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()
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
