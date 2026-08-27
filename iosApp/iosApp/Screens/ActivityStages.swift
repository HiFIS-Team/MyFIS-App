import SwiftUI

/// 활동 랜딩의 **연출 상태** (DESIGN.md §6.25).
enum ActivityStage {
    /// 대기 — 그림이 은은하게 떠 있다
    case idle
    /// 재생 중 — 버튼은 눌리지 않는다
    case playing
    /// 끝났다 — 받은 P 가 남는다
    case result
}

/// 연출은 **진행값 하나(0→1)** 로 굴린다.
///
/// 단계마다 애니메이션을 따로 걸면 두 플랫폼이 미세하게 어긋나고, 중간에 끊어 되돌리기도 어렵다.
/// 진행값에서 자리·각도·투명도를 **계산해서** 그리면 iOS·Android 가 같은 장면을 그린다.
enum Stagecraft {
    /// `from`~`to` 구간을 0~1 로 자른다. 구간 밖은 0 또는 1
    static func slice(_ p: Double, _ from: Double, _ to: Double) -> Double {
        min(max((p - from) / (to - from), 0), 1)
    }

    /// 시작과 끝이 부드러운 곡선 (구간 안에서만)
    static func ease(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }
}

/// 뽑기 — **캡슐이 떨리다 갈라지고 P 가 튀어나온다.**
struct LuckStage: View {
    let color: Color
    let progress: Double
    let reward: String

    /// 0.0 떨림 → 0.25 갈라짐 → 0.45 P 등장 → 0.75 반짝이
    private var shake: Double { Stagecraft.slice(progress, 0, 0.25) }
    private var split: Double { Stagecraft.ease(Stagecraft.slice(progress, 0.25, 0.55)) }
    private var reveal: Double { Stagecraft.ease(Stagecraft.slice(progress, 0.45, 0.75)) }
    private var settle: Double { Stagecraft.slice(progress, 0.75, 1) }

    /// 갈라지기 전까지 부르르 — 곧 열린다는 예고다
    private var wobble: Double {
        shake >= 1 ? 0 : sin(shake * .pi * 6) * 7
    }

    var body: some View {
        ZStack {
            Half(color: color, top: true)
                .rotationEffect(.degrees(wobble - 24 * split))
                .offset(y: -86 * split)
                .opacity(1 - 0.45 * split)

            Half(color: color.opacity(0.72), top: false)
                .rotationEffect(.degrees(wobble + 24 * split))
                .offset(y: 86 * split)
                .opacity(1 - 0.45 * split)

            // 반짝이는 **갈라진 뒤에** 퍼진다. 같이 터지면 뭐가 나온 건지 안 보인다
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) / 8 * 2 * .pi
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: cos(angle) * 96 * settle,
                        y: sin(angle) * 96 * settle
                    )
                    .opacity(reveal * (1 - settle))
            }

            RewardText(text: reward, color: color, reveal: reveal, settle: settle)
        }
    }

    /// 캡슐 반쪽. 위는 밝고 아래는 어둡다
    private struct Half: View {
        let color: Color
        let top: Bool

        var body: some View {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.62)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 100, height: 100)
                // 반원만 남긴다 — 원 두 개가 아니라 **하나가 갈라진 것**으로 보여야 한다
                .mask(alignment: top ? .top : .bottom) {
                    Rectangle().frame(height: 50)
                }
                // ⚠️ 그림자를 걸지 않는다 (§9 이탈 #5) — 다크에서 거의 안 보이는데
                // **iOS 에만** 있어 안드로이드와 화면이 달라져 있었다 (2026-08-27)
        }
    }
}

/// 연출 끝에 나오는 값. **커졌다 제자리로** — 그냥 떠오르면 받은 느낌이 안 난다
private struct RewardText: View {
    let text: String
    let color: Color
    let reveal: Double
    let settle: Double

    var body: some View {
        Text(text)
            .font(MyFisFont.metricLg.monospacedDigit())
            .foregroundStyle(color)
            // ⚠️ 글로우를 걸지 않는다 (§9 이탈 #5) — 안드로이드에는 없다.
            // 커졌다 제자리로 오는 움직임만으로 충분히 읽힌다 (2026-08-27)
            .scaleEffect(0.4 + 0.78 * reveal - 0.16 * settle)
            .opacity(reveal)
    }
}
