import SwiftUI

/// 헤더의 아이콘 버튼 (DESIGN.md §6.9).
///
/// 홈·스토어 헤더가 같이 쓴다. **자리는 시스템 내비 바**다 (§7.1) —
/// 화면 안에 직접 그리면 잎이 밀려 들어올 때 헤더가 같이 밀려 흔들린다.
struct HeaderIcon: View {
    let asset: String
    let label: String
    let action: () -> Void

    init(_ asset: String, _ label: String, _ action: @escaping () -> Void) {
        self.asset = asset
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(asset)
                // 터치 타겟 44pt (DESIGN.md §5.3). 아이콘은 26pt 지만 영역은 넉넉히 잡는다
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
        .foregroundStyle(MyFisColor.textPrimary)
        .accessibilityLabel(label)
    }
}
