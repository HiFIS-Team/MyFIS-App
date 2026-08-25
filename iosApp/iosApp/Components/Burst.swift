import SwiftUI

/// 켜질 때 **한 번 튀고 고리가 퍼지는** 반응 (DESIGN.md §6.21).
///
/// 찜 하트와 리뷰의 `도움 됐어요` 가 같이 쓴다 —
/// 같은 종류의 행동이면 반응도 같아야 한 앱으로 읽힌다.
///
/// **켤 때만** 터뜨린다. 해제까지 축하하면 과하다.
private struct BurstReaction: ViewModifier {
    let active: Bool
    let color: Color

    /// 1 = 끝난 상태(안 보임). 켤 때만 0 으로 되감아 다시 퍼뜨린다
    @State private var ring: Double = 1
    @State private var bump = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(bump ? 1.3 : 1)
            .background {
                Circle()
                    .stroke(color, lineWidth: max(0.5, 3.5 * (1 - ring)))
                    .scaleEffect(0.45 + ring * 0.75)
                    .opacity(1 - ring)
            }
            .onChange(of: active) { _, now in
                guard now else { return }
                ring = 0
                withAnimation(.easeOut(duration: 0.42)) { ring = 1 }
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) { bump = true }
                withAnimation(.spring(response: 0.28, dampingFraction: 0.45).delay(0.11)) { bump = false }
            }
    }
}

extension View {
    /// 켜질 때 튀고 고리가 퍼진다. 아이콘에 건다 (§6.21)
    func burst(active: Bool, color: Color) -> some View {
        modifier(BurstReaction(active: active, color: color))
    }
}
