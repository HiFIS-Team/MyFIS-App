import SwiftUI

/// 모든 화면이 올라앉는 배경. 순검정 위에 하단 탭 바만 있다.
struct AppShell: View {
    @State private var tabSet: TabSet = .base
    @State private var baseTab: BaseTab = .home
    @State private var weightTab: WeightTab = .weight

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch tabSet {
                    case .base: baseContent
                    case .weight: weightContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 세트가 바뀌는 걸 사용자가 눈치채야 한다 — 탭 바만 크로스페이드 (DESIGN.md §6.7)
                Group {
                    switch tabSet {
                    case .base:
                        BottomTabBar(
                            tabs: [.home, .benefit, .store, .weight, .my],
                            selected: baseTab
                        ) { tab in
                            // 웨이트는 목적지가 아니라 통로다. baseTab 을 바꾸지 않아야
                            // '이전' 으로 돌아왔을 때 보던 탭으로 복귀한다.
                            if tab == .weight {
                                tabSet = .weight
                            } else {
                                baseTab = tab
                            }
                        }
                    case .weight:
                        BottomTabBar(
                            tabs: [.back, .weight, .cardio, .ranking, .group],
                            selected: weightTab,
                            isExit: { $0 == .back }
                        ) { tab in
                            if tab == .back {
                                tabSet = .base
                            } else {
                                weightTab = tab
                            }
                        }
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: tabSet)
            }
        }
    }

    @ViewBuilder
    private var baseContent: some View {
        switch baseTab {
        case .home:
            PlaceholderScreen(id: "H-01", title: "홈", description: "회원권 상태 · 오늘 할 운동 · 마일리지")
        case .benefit:
            PlaceholderScreen(id: "P-01", title: "혜택", description: "보유 마일리지 · 적립 경로")
        case .store:
            PlaceholderScreen(id: "S-01", title: "스토어", description: "마일리지로 굿즈·음료 교환")
        case .my:
            PlaceholderScreen(id: "Y-01", title: "마이", description: "프로필 · 기록 · 설정")
        case .weight:
            // 통로라 여기 도달하지 않는다
            EmptyView()
        }
    }

    @ViewBuilder
    private var weightContent: some View {
        switch weightTab {
        case .weight:
            PlaceholderScreen(id: "W-01", title: "이번 주 루틴", description: "AI가 보낸 주간 루틴")
        case .cardio:
            PlaceholderScreen(id: "C-01", title: "유산소", description: "기기 목록 · NFC 스캔")
        case .ranking:
            PlaceholderScreen(id: "R-01", title: "랭킹", description: "웨이트 · 유산소 · 마일리지")
        case .group:
            PlaceholderScreen(id: "G-01", title: "모임", description: "모임 · 커뮤니티")
        case .back:
            EmptyView()
        }
    }
}

#Preview {
    AppShell().preferredColorScheme(.dark)
}
