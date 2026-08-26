import SwiftUI

/// 포인트 표기 — **값이 주인, 단위 `P` 는 한 걸음 뒤** (DESIGN.md §3.3).
///
/// 앱 안에서 포인트가 보이는 자리는 전부 이걸 쓴다. 자리마다 색을 따로 고르면
/// 같은 값이 화면마다 다르게 읽힌다.
///
/// 색은 **한 단계 차이**만 준다 — 값과 단위를 같은 색으로 두면 `1,240 P` 가 한 덩어리
/// 글자로 뭉쳐 자릿수가 안 잡히고, 반대로 단위를 액센트로 칠하면 눈이 숫자 대신 끝으로 간다.
///
/// **포인트 숫자에 라임은 쓰지 않는다.** 어떤 화면은 라임, 어떤 화면은 흰색이면
/// 같은 값이 자리마다 다르게 읽힌다. 액센트는 버튼과 동전 아이콘의 몫이다 (§3.3).
///
/// 글꼴은 바깥에서 준다 (`.font(...)`) — 자리마다 크기가 다르기 때문이다.
/// **자릿수 고정(tnum)은 여기서 건다** — 숫자가 바뀔 때 폭이 흔들리면 안 된다 (§4).
struct MileageText: View {
    let value: Int
    var tone: MileageTone = .primary

    init(_ value: Int, tone: MileageTone = .primary) {
        self.value = value
        self.tone = tone
    }

    var body: some View {
        Self.text(value, tone: tone).monospacedDigit()
    }

    /// 다른 글자와 **한 줄로 이어 붙일 때** 쓴다 (`300 P · 1개`).
    /// 이어 붙이면 줄바꿈·정렬이 하나로 묶여서, 나란히 둔 두 개의 `Text` 보다 안 어긋난다
    static func text(_ value: Int, tone: MileageTone = .primary) -> Text {
        Text(value.decimal).foregroundStyle(tone.value)
            + Text(" P").foregroundStyle(tone.unit)
    }
}

/// 값이 그 자리에서 어떤 무게인지. **단위 색은 여기서만 정해진다.**
enum MileageTone {
    /// 보통 값 — 상품 가격처럼 흰 글씨로 읽는 자리
    case primary
    /// 곁들이는 값 — 교환 내역 한 줄처럼 이미 물러나 있는 자리
    case secondary
    /// 품절처럼 통째로 흐린 자리
    case dimmed

    var value: Color {
        switch self {
        case .primary: MyFisColor.textPrimary
        case .secondary: MyFisColor.textSecondary
        case .dimmed: MyFisColor.textTertiary
        }
    }

    /// 단위는 값보다 한 단계 뒤 — 언제나 `text.tertiary` 다.
    /// **그 아래로는 안 내린다** (AA 하한선, §3.1). 그래서 흐린 자리에서는 값과 같은 색이 된다
    var unit: Color { MyFisColor.textTertiary }
}
