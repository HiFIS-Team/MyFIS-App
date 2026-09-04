import SwiftUI

/// DESIGN.md §6.31 **단계 슬라이더** — 몇 칸 중 몇 번째인지 고른다.
///
/// 값을 정확히 재는 자가 아니라 **`가까운` ↔ `먼` 사이 어디쯤**을 고르는 손잡이다.
/// 그래서 연속값이 아니라 **칸**이다 — 칸 사이 눈금이 몇 단계인지 말해 준다.
///
/// **손잡이는 흰색 하나다.** 라임은 화면당 두 곳이 상한이라(§3.2) 여기까지 칠하면
/// 진짜 액션(`다음`)이 묻힌다 — 다크에서 흰 원은 그것만으로 충분히 앞선다.
struct MyFisSlider: View {
    @Binding var step: Int
    /// 칸 수. 눈금은 `steps - 1` 개 그린다
    var steps: Int = 4

    private static let knob: CGFloat = 34
    private static let track: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let span = geo.size.width - Self.knob
            let ratio = steps <= 1 ? 0 : CGFloat(step) / CGFloat(steps - 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(MyFisColor.surface2)
                    .frame(height: Self.track)

                // 칸 사이 눈금 — 몇 단계인지 손잡이를 안 움직여도 보인다
                ForEach(1 ..< max(steps - 1, 1), id: \.self) { index in
                    Rectangle()
                        .fill(MyFisColor.surface3)
                        .frame(width: 1, height: 10)
                        .offset(x: Self.knob / 2 + span * CGFloat(index) / CGFloat(steps - 1))
                }

                Circle()
                    .fill(MyFisColor.textPrimary)
                    .frame(width: Self.knob, height: Self.knob)
                    .offset(x: span * ratio)
            }
            .frame(height: Self.knob, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = min(max(value.location.x - Self.knob / 2, 0), span)
                        let next = Int((x / max(span, 1) * CGFloat(steps - 1)).rounded())
                        // 칸을 넘을 때만 바꾼다 — 끄는 내내 상태를 갈면 진동이 계속 울린다
                        if next != step { step = next }
                    }
            )
        }
        .frame(height: Self.knob)
    }
}
