import SwiftUI

/// 스크롤에 따라 접히는 헤더 (DESIGN.md §6.17) — **iOS 전용**.
///
/// - 내려 읽으면 헤더가 콘텐츠와 **같이 올라가며 흐려진다**
/// - 되돌아 올리면 헤더가 **위에서 내려오고**, 이때는 아이콘이 유리로 뜬다 (콘텐츠 위에 얹힌 상태라서)
/// - 맨 위에 닿으면 유리가 풀리고 **원래의 검은 헤더**로 돌아온다
///
/// 안드로이드는 이렇게 하지 않는다. 유리는 iOS 26 의 시스템 재질이라 흉내 내면 어설퍼진다.
struct CollapsingHeaderScroll<Header: View, Content: View>: View {
    var headerHeight: CGFloat = 56
    /// 시뮬레이터 확인용 초기 스크롤 위치
    var scrollAnchor: UnitPoint = .top
    /// `Bool` 은 유리 모드인지 — 헤더가 콘텐츠 위에 떠 있는 상태다
    @ViewBuilder var header: (Bool) -> Header
    @ViewBuilder var content: () -> Content

    /// 콘텐츠가 위로 밀린 양 (맨 위 = 0)
    @State private var scrolled: CGFloat = 0
    /// 헤더 이동량. `-headerHeight`(완전히 숨음) ~ `0`(다 보임)
    @State private var headerY: CGFloat = 0
    @State private var glass = false

    private static var space: String { "collapsingHeader" }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 헤더가 차지하던 자리. 헤더는 오버레이라 흐름에서 빠져 있다
                Color.clear.frame(height: headerHeight)
                content()
            }
            .background {
                GeometryReader { geo in
                    let y = -geo.frame(in: .named(Self.space)).minY
                    // 프리퍼런스 대신 `onChange` 를 쓴다 — 프리퍼런스 콜백은 @Sendable 이라
                    // 여기서 @State 를 건드리면 동시성 경고가 난다
                    Color.clear.onChange(of: y, initial: true) { _, new in follow(new) }
                }
            }
        }
        .coordinateSpace(name: Self.space)
        .defaultScrollAnchor(scrollAnchor)
        .overlay(alignment: .top) {
            header(glass)
                .frame(height: headerHeight)
                // 맨 위에서는 불투명 검정.
                // 떠 있을 때는 **위에서 아래로 옅어지는 옅은 스크림** — 상태바 글씨가 콘텐츠에
                // 묻히지 않을 만큼만. 더 진하면 유리가 검정만 비쳐서 유리로 안 보인다
                // (워드마크 가독성은 스크림이 아니라 유리 알약이 맡는다, §6.17)
                .background {
                    Group {
                        if glass {
                            LinearGradient(
                                colors: [
                                    MyFisColor.bgBase.opacity(0.6),
                                    MyFisColor.bgBase.opacity(0),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            MyFisColor.bgBase
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                }
                .offset(y: headerY)
                // 올라가며 흐려진다 — 반쯤 걸친 상태가 어정쩡해 보이지 않게
                .opacity(1 + headerY / headerHeight)
                .animation(MyFisMotion.base, value: glass)
        }
    }

    /// 손가락을 따라간다 — 스크롤한 만큼 헤더가 밀리고, 되돌리면 그만큼 내려온다.
    ///
    /// 스크롤 위치가 아니라 **변화량**으로 움직여야 "조금만 올려도 헤더가 나오는" 인스타 감각이 난다.
    private func follow(_ y: CGFloat) {
        let delta = y - scrolled
        scrolled = y

        guard y > 0 else {
            // 맨 위(고무줄 포함)에서는 항상 다 보이고, 유리가 아니라 원래 헤더다
            headerY = 0
            glass = false
            return
        }

        headerY = min(0, max(-headerHeight, headerY - delta))

        // **올릴 때만 유리다.** 내려 읽는 중에는 원래(검은) 헤더가 그대로 올라가며 흐려진다 —
        // 유리는 "다시 불러낸 헤더"라는 신호라서, 사라지는 중에 유리로 바뀌면 뜻이 흐려진다
        if delta < 0 {
            glass = true
        } else if delta > 0 {
            glass = false
        }
    }
}
