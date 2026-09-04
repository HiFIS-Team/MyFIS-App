import SwiftUI

/// 꺾쇠 — **아래 꺾쇠 아이콘 한 벌을 돌려 쓴다** (DESIGN.md §6.14 · §8).
///
/// 화면마다 같은 것을 `private struct Chevron` 으로 따로 그리고 있었다
/// (2026-09-04 실측: 유산소 · 스토어 마이). 아이콘을 늘리지 않는 규칙이 이미 있으니
/// **돌려 쓰는 코드도 한 벌**로 둔다.
struct Chevron: View {
    /// 도는 각도 — `-90` 오른쪽(이동) · `0` 아래(펼침) · `180` 위(접힘)
    var degrees: Double = -90
    var size: CGFloat = 20
    var color: Color = MyFisColor.textTertiary

    var body: some View {
        Image("ic_chevron_down")
            .renderingMode(.template)
            .resizable()
            .frame(width: size, height: size)
            .rotationEffect(.degrees(degrees))
            .foregroundStyle(color)
    }
}
