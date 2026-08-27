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
    /// 스토어 검색 모드 — 상품 상세에서도 켤 수 있어야 해서 **뿌리가 들고 있다** (§6.9)
    @Binding var storeSearching: Bool

    private static let baseTabs = BaseTab.allCases
    private static let weightTabs = WeightTab.allCases

    @State private var tabSet: TabSet = MyFisDebug.initialTabSet
    @State private var baseTab: BaseTab = MyFisDebug.initialBaseTab
    @State private var weightTab: WeightTab = .weight

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
    // 화면은 **자기 헤더를 자기가 그린다** (§6.9). 셸은 헤더를 모른다.

    @ViewBuilder
    private func screen(at slot: Int) -> some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            if tabSet == .base {
                switch Self.baseTabs[slot] {
                case .home:
                    HomeScreen(
                        onBranch: { open(.branch) },
                        onNotification: { open(.notifications) },
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
                        // 체중은 매일 하는 기록이라 랜딩을 거치지 않는다 (§6.25)
                        open(action.kind == .weight ? .weightLog : .activity(action))
                    })
                case .store:
                    // 스토어 헤더의 '마이' 는 **마이 탭이 아니다.** 교환에 관한 나(S-08)로 간다.
                    StoreScreen(
                        onCart: { open(.storeCart) },
                        onMy: { open(.storeMy) },
                        onItem: { open(.storeItem($0)) },
                        searching: $storeSearching
                    )
                case .my:
                    PlaceholderScreen(id: "Y-01", title: "마이", description: "프로필 · 기록 · 설정")
                case .weight:
                    Color.clear // 통로
                }
            } else {
                switch Self.weightTabs[slot] {
                case .weight:
                    PlaceholderScreen(id: "W-01", title: "이번 주 루틴", description: "AI가 보낸 주간 루틴")
                case .cardio:
                    PlaceholderScreen(id: "C-01", title: "유산소", description: "기기 목록 · NFC 스캔")
                case .ranking:
                    PlaceholderScreen(id: "R-01", title: "랭킹", description: "웨이트 · 유산소 · 마일리지")
                case .group:
                    PlaceholderScreen(id: "G-01", title: "모임", description: "모임 · 커뮤니티")
                case .back:
                    Color.clear // 통로
                }
            }
        }
    }
}
