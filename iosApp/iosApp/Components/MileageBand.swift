import SwiftUI

/// 보유 마일리지 — **구분선 하나 위에 칩이 얹혀 있다.**
///
/// 라벨("내 마일리지")은 없다. 동전 아이콘이 이미 무슨 숫자인지 말한다.
/// 값 표기가 `n P` 라 **아이콘도 동전 안에 P** 를 넣어 둘이 같은 말을 하게 했다.
///
/// P 는 칠하지 않고 **구멍으로 뚫는다**(`evenodd`) — 그래야 라임 위 글자가 검정이 된다 (§3.2).
///
/// **라임은 동전 하나뿐이다.** 값은 앱 전체와 같은 표기를 쓴다 (§3.3 `MileageText`) —
/// 포인트 숫자를 라임으로 칠하면 같은 값이 화면마다 다르게 읽힌다.
///
/// 스크롤해도 남는다 (SPEC S 공통 규칙).
struct MileageBand: View {
    let balance: Int

    var body: some View {
        ZStack {
            Rectangle()
                .fill(MyFisColor.borderSubtle)
                .frame(height: 1)

            // 칩은 배경이 불투명해서 선 가운데를 덮는다 — 선이 칩을 통과하는 것처럼 보인다
            MileageChip(balance: balance)
        }
        .padding(.vertical, MyFisSpacing.md)
    }
}


/// 마일리지 칩 — **동전 + 값 한 덩어리** (§6.12).
///
/// 스토어 띠(`MileageBand`)와 혜택 헤더(§6.23)가 **같은 것을 쓴다.**
/// 같은 값을 화면마다 다르게 그리면 같은 값으로 안 읽힌다.
struct MileageChip: View {
    let balance: Int

    var body: some View {
        HStack(spacing: MyFisSpacing.xs) {
            Image("ic_coin")
                .resizable()
                .frame(width: 22, height: 22)
            MileageText(balance)
                .font(MyFisFont.titleSm)
        }
        .padding(.leading, MyFisSpacing.sm)
        .padding(.trailing, MyFisSpacing.md)
        // 높이는 여백이 아니라 **값으로 못 박는다** (§5.2). 전에는 상하 `7` 이었는데
        // 그 값이 §5.1 스케일 밖이었다 — 결과 높이는 그대로 36 이다 (2026-08-27)
        .frame(height: MyFisSize.chip)
        .background(MyFisColor.surface2, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("내 마일리지 \(balance.mileage)")
    }
}
