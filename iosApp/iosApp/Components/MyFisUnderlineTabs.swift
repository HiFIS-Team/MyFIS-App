import SwiftUI

/// DESIGN.md §6.29 **밑줄 갈래 줄** — 글자 + 흐르는 밑줄.
///
/// 알약이 아니라 **글자 + 밑줄**이다. 목록 위에서 알약은 시각적으로 너무 무겁고,
/// 여기서 고른 것은 "지금 보고 있는 목록"이라 **제목처럼 읽혀야** 한다.
///
/// **고른 것은 색이 아니라 밑줄로 알린다** — 라임은 버튼과 진행바의 몫이다 (§3.2 액센트 2곳).
///
/// ⚠️ 이 꼴을 스토어(§6.12)와 유산소(§6.27)가 **각자 그리고 있다.** 모임(§6.29)이 세 번째라
/// 여기 한 벌로 모았다 — 두 화면의 이관은 아직이다 (2026-09-04, `ui-design` 금지 6번).
struct MyFisUnderlineTabs<Item: Hashable>: View {
    /// 칸을 어떻게 늘어놓나
    enum Distribution {
        /// 폭을 고르게 나눠 가진다. 칸이 서넛이고 이름이 짧을 때 (유산소 갈래)
        case filled
        /// 글자 폭만큼만 차지하고 넘치면 옆으로 민다 (스토어 카테고리)
        case scrolling
    }

    let items: [Item]
    @Binding var selection: Item
    var distribution: Distribution = .filled
    let title: (Item) -> String

    /// 고른 칸의 자리. **글자를 재서** 밑줄을 옮긴다 —
    /// `matchedGeometryEffect` 로 하면 이동이 우리 모션을 안 타서 속도를 못 정한다 (확인함)
    @State private var frames: [Int: CGRect] = [:]

    private static var space: String { "myFisUnderlineTabs" }

    var body: some View {
        Group {
            if distribution == .scrolling {
                ScrollView(.horizontal, showsIndicators: false) { row }
            } else {
                row
            }
        }
        // 바닥 줄이 칸들을 하나로 묶는다 — 없으면 밑줄이 허공에서 움직인다
        .overlay(alignment: .bottom) {
            MyFisColor.borderSubtle.frame(height: 1)
        }
    }

    private var row: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let isSelected = item == selection
                Button {
                    // ⚠️ `withAnimation` 을 쓰면 **아래 목록까지** 트랜잭션에 걸려
                    // 줄이 하나씩 제각각 나타난다 (Android 는 그냥 갈린다)
                    selection = item
                } label: {
                    Text(title(item))
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(isSelected ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                        .lineLimit(1)
                        // 글자 자체를 잰다 — 패딩까지 재면 밑줄이 글자보다 넓어진다
                        .background {
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: TabFrames.self,
                                    value: [index: geo.frame(in: .named(Self.space))]
                                )
                            }
                        }
                        .padding(.horizontal, MyFisSpacing.sm)
                        .padding(.vertical, MyFisSpacing.md)
                        .frame(maxWidth: distribution == .filled ? .infinity : nil)
                }
                .buttonStyle(.myFisTap)
            }
        }
        .coordinateSpace(.named(Self.space))
        .overlay(alignment: .bottomLeading) {
            let index = items.firstIndex(of: selection) ?? 0
            Rectangle()
                .fill(MyFisColor.textPrimary)
                .frame(width: frames[index]?.width ?? 0, height: 2)
                .offset(x: frames[index]?.minX ?? 0)
                // 고르는 동작이라 `fast`(120ms). `base` 는 감속 커브 때문에 끝이 끌린다
                .animation(MyFisMotion.fast, value: selection)
        }
        .onPreferenceChange(TabFrames.self) { frames = $0 }
    }
}

/// 각 칸의 글자가 어디서 시작해 얼마나 넓은지 — 밑줄을 옮기려면 이게 있어야 한다
private struct TabFrames: PreferenceKey {
    static let defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}
