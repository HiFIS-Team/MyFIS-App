import SwiftUI

/// 눌림 표시 (DESIGN.md §7).
///
/// **어둡게 덮지 않는다.** SwiftUI 기본 버튼은 누르는 동안 내용을 흐리게 만드는데,
/// 안드로이드는 리플도 딤도 없다 (`tapWithHaptics` 는 `indication = null`).
/// 두 플랫폼이 다르게 반응하면 같은 앱으로 안 읽힌다 —
/// 딤 대신 **크기**로 알린다. 그것도 **아이콘에만** 준다 (§6.7):
/// 판을 통째로 줄이면 화면이 움찔거려 보인다.
struct MyFisTapStyle: ButtonStyle {
    var scale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(MyFisMotion.fast, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == MyFisTapStyle {
    /// 판·카드용 — 크기 변화 없음 (`.plain` 은 내용을 흐리게 만들어서 쓰지 않는다)
    static var myFisTap: MyFisTapStyle { MyFisTapStyle() }
    /// 아이콘 버튼용 — 누르면 0.86배로 줄었다 돌아온다 (§6.7)
    static var myFisIcon: MyFisTapStyle { MyFisTapStyle(scale: 0.86) }
}
