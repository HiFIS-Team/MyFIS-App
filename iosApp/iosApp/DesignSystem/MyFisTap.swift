import SwiftUI

/// 눌림 표시 (DESIGN.md §7).
///
/// **어둡게 덮지 않는다.** SwiftUI 기본 버튼은 누르는 동안 글자와 배경을 흐리게 만드는데,
/// 안드로이드는 리플도 딤도 없다 (`tapWithHaptics` 는 `indication = null`).
/// 두 플랫폼이 다르게 반응하면 같은 앱으로 안 읽힌다 — 필요한 자리에는
/// 딤 대신 **크기(`pressScale`)나 반응(`burst`)** 을 준다.
struct MyFisTapStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension ButtonStyle where Self == MyFisTapStyle {
    /// `.plain` 대신 쓴다 — `.plain` 은 누르는 동안 내용을 흐리게 만든다
    static var myFisTap: MyFisTapStyle { MyFisTapStyle() }
}
