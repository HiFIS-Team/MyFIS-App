import SwiftUI

/// DESIGN.md §6.5 리스트 / 행.
///
/// **규격만 있고 부를 수 있는 것이 없던 자리**다 (§10.1 에 적혀 있던 것) —
/// 마이(Y-01)가 이 행을 열 번 넘게 쓰면서 이제 만든다.
///
/// - 높이 최소 `56`
/// - 값이 있으면 오른쪽에 붙는다 (`1,240 P` · `2장`)
/// - **꺾쇠는 실제로 이동하는 행에만** 단다 (§6.5)
/// - 좌우 여백은 **감싸는 카드가 준다** — 행이 또 주면 두 번 들어간다
struct MyFisListRow: View {
    let title: String
    /// 오른쪽에 붙는 **글자** 값 (`2장`)
    var value: String?
    /// 글자로 못 쓰는 값 — **마일리지가 그렇다.** 포인트 표기는 `MileageText` 하나뿐이라(§3.3)
    /// 여기에 그대로 넣는다. `value` 보다 우선한다
    var accessory: AnyView?
    /// 눌러서 어딘가로 가는 행인가. 아니면 꺾쇠를 달지 않는다
    var moves = true
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: MyFisSpacing.md) {
                Text(title)
                    .font(MyFisFont.body)
                    .foregroundStyle(MyFisColor.textPrimary)

                Spacer(minLength: MyFisSpacing.sm)

                if let accessory {
                    accessory
                } else if let value {
                    Text(value)
                        .font(MyFisFont.bodySm.monospacedDigit())
                        .foregroundStyle(MyFisColor.textSecondary)
                }
                if moves { Chevron(size: 18) }
            }
            .frame(minHeight: MyFisSize.listRowMin)
            // 글자가 없는 자리도 눌리게 한다
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }
}

/// 카드 안에서 행과 행을 가르는 줄 (§6.5) — `border.subtle` 1
struct MyFisRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(MyFisColor.borderSubtle)
            .frame(height: 1)
    }
}
