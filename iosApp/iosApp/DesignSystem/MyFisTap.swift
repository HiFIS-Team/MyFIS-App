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
            // ⚠️ **크기가 안 변하면 애니메이션도 걸지 않는다** 🟢 (2026-09-06, 사용자 지적).
            //
            // 전에는 `scale` 과 상관없이 늘 걸어 뒀는데, `.myFisTap` 은 `scale: 1` 이라
            // 정작 움직일 게 없다. 그런데 손을 떼는 순간 `isPressed` 가 바뀌면서
            // **그 트랜잭션에 버튼 안의 내용 변화까지 같이 실렸다** —
            // 재생↔일시정지 아이콘이 크로스페이드로 넘어가고, 음성 칩 글자색이
            // 스르륵 어두워졌다. 눌러서 바뀌는 값은 **즉시** 바뀌어야 한다
            .animation(scale == 1 ? nil : MyFisMotion.fast, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == MyFisTapStyle {
    /// 판·카드용 — 크기 변화 없음 (`.plain` 은 내용을 흐리게 만들어서 쓰지 않는다)
    static var myFisTap: MyFisTapStyle { MyFisTapStyle() }
    /// 아이콘 버튼용 — 누르면 0.86배로 줄었다 돌아온다 (§6.7)
    static var myFisIcon: MyFisTapStyle { MyFisTapStyle(scale: 0.86) }
}

/// **안드로이드 `tapWithHaptics` 와 같은 것** — `clickable(indication = null)` 의 iOS 판.
///
/// 🟢 (2026-09-06, 사용자 지정: *"안드로이드는 빠르니까 안드로이드꺼 참고해서 똑같이 만들어라"*)
///
/// **SwiftUI `Button` 을 쓰지 않는다.** `Button` 은 눌림 상태를 자기 트랜잭션으로 다루는데,
/// 손을 떼는 순간 그 트랜잭션에 **버튼 속 내용 변화까지 같이 실린다** —
/// 재생↔일시정지 아이콘이 겹쳐 넘어가고 음성 칩 색이 스르륵 어두워졌다.
/// `MyFisTapStyle` 의 애니메이션을 걷어내도 남았다 (2026-09-06 확인).
/// 안드로이드는 `Button` 없이 탭만 받아 **즉시** 바뀐다 — 그쪽에 맞춘다.
///
/// ⚠️ 눌림 표시가 필요한 자리에는 쓰지 않는다. 이건 **표시 없이 탭만 받는** 판이다.
struct MyFisTappable<Content: View>: View {
    var isEnabled: Bool = true
    /// 화면 낭독기가 읽을 이름 — 글자가 없는 아이콘 버튼이라도 이름은 있어야 한다 (§6.1)
    let label: String
    let action: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        content
            .contentShape(Rectangle())
            .onTapGesture { if isEnabled { action() } }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { if isEnabled { action() } }
    }
}
