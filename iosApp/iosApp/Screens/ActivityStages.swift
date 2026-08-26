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
                .shadow(color: color.opacity(0.4), radius: 20, y: top ? -6 : 8)
        }
    }
}

/// 사다리 — **점이 길을 타고 내려가고, 당첨 칸 종이가 뜯긴다.**
struct LadderStage: View {
    let color: Color
    let progress: Double
    let reward: String

    // 대기 글리프(사다리 아이콘)와 같은 크기여야 재생 순간 안 튄다.
    // 아이콘을 다시 그려 폭이 넓어져서 같이 올렸다 (24 기준 기둥 간격 12.8 · 높이 18.8 → 148 기준)
    private static let railGap: CGFloat = 79
    private static let height: CGFloat = 116
    /// 가로대 간격 — 아이콘 기준 4.3 (24) → 26.5 (148)
    private static let rung: CGFloat = 26.5

    private var walk: Double { Stagecraft.slice(progress, 0.1, 0.68) }
    private var tear: Double { Stagecraft.ease(Stagecraft.slice(progress, 0.68, 0.84)) }
    private var reveal: Double { Stagecraft.ease(Stagecraft.slice(progress, 0.78, 1)) }

    /// 왼쪽 기둥에서 출발해 가로대를 만날 때마다 건너간다.
    /// **오른쪽으로 두 번 건너가는 길**을 고정으로 쓴다 — 결과는 어차피 서버가 정한다
    private var dot: CGPoint {
        let legs: [(CGPoint, CGPoint)] = {
            let left = -Self.railGap / 2, right = Self.railGap / 2
            let top = -Self.height / 2, mid1 = -Self.rung
            let mid2 = Self.rung, bottom = Self.height / 2
            return [
                (CGPoint(x: left, y: top), CGPoint(x: left, y: mid1)),
                (CGPoint(x: left, y: mid1), CGPoint(x: right, y: mid1)),
                (CGPoint(x: right, y: mid1), CGPoint(x: right, y: mid2)),
                (CGPoint(x: right, y: mid2), CGPoint(x: left, y: mid2)),
                (CGPoint(x: left, y: mid2), CGPoint(x: left, y: bottom)),
            ]
        }()
        let step = walk * Double(legs.count)
        let index = min(Int(step), legs.count - 1)
        let t = step - Double(index)
        let (from, to) = legs[index]
        return CGPoint(
            x: from.x + (to.x - from.x) * t,
            y: from.y + (to.y - from.y) * t
        )
    }

    var body: some View {
        ZStack {
            Group {
                Ladder(color: color)

                // 걸어 내려가는 점 — **흰 점**이다. 같은 색이면 기둥에 묻혀 안 보인다 (확인함)
                Circle()
                    .fill(MyFisColor.textPrimary)
                    .frame(width: 14, height: 14)
                    .shadow(color: color.opacity(0.9), radius: 10)
                    .offset(x: dot.x, y: dot.y)
                    .opacity(walk > 0 ? 1 : 0)

                // 당첨 칸 — 도착하면 **뜯겨 떨어진다**
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color.opacity(0.9))
                    Capsule()
                        .fill(MyFisColor.bgBase.opacity(0.35))
                        .frame(width: 26, height: 4)
                }
                .frame(width: Self.railGap + 10, height: 24)
                .offset(x: -Self.railGap / 2, y: Self.height / 2 + 26 + 52 * tear)
                .rotationEffect(.degrees(30 * tear), anchor: .topLeading)
                .opacity(1 - tear)
            }
            // 결과가 나오면 사다리는 **물러난다**. 안 그러면 숫자가 기둥에 걸쳐 안 읽힌다
            .opacity(1 - 0.72 * reveal)

            RewardText(text: reward, color: color, reveal: reveal, settle: 0)
        }
    }

    /// 기둥 둘 + 가로대 셋
    private struct Ladder: View {
        let color: Color

        var body: some View {
            ZStack {
                // 굵기도 아이콘에서 가져왔다 (24 기준 3.2 → 148 기준 20)
                ForEach([-1.0, 1.0], id: \.self) { side in
                    Capsule()
                        .fill(color.opacity(0.9))
                        .frame(width: 20, height: LadderStage.height)
                        .offset(x: LadderStage.railGap / 2 * side)
                }
                ForEach([-1.0, 0.0, 1.0], id: \.self) { row in
                    Capsule()
                        .fill(color.opacity(0.6))
                        .frame(width: LadderStage.railGap, height: 16)
                        .offset(y: LadderStage.rung * row)
                }
            }
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
            .shadow(color: color.opacity(0.5), radius: 18)
            .scaleEffect(0.4 + 0.78 * reveal - 0.16 * settle)
            .opacity(reveal)
    }
}
