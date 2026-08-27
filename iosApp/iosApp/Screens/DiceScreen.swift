import SwiftUI

/// P-11 **주사위 굴리기** — 하루 한 번 굴려서 나온 눈만큼 받는다.
///
/// **진짜로 굴러야 한다** (사용자 지정, 2026-08-27). 숫자만 바뀌고 끝나면 뽑기와 구분이 안 된다 —
/// 던져서 뜨고, 구르고, 떨어져서 한 번 튕긴 뒤 멈춘다. 네 가지를 겹쳐 그 느낌을 만든다:
///
/// | 겹 | 값 | 왜 |
/// |----|-----|-----|
/// | 회전 | **2D 로 세 바퀴** + 기울기 26° | 구르는 몸통 |
/// | 눈 | 무작위로 갈리다 **간격이 점점 벌어진다** | 회전이 느려지는 걸 눈이 따라간다 |
/// | 높이 | 올라갔다 내려온다 | 던진 것이지 돌린 것이 아니다 |
/// | 그림자 | 뜨면 **작고 옅어진다** | 높이를 바닥이 알려 준다 |
///
/// ⚠️ **`rotation3DEffect` 로 한 바퀴를 돌리지 않는다.** 90°에서 몸통이 종잇장이 되어
/// 구르는 게 아니라 **카드가 뒤집히는** 것으로 읽힌다 (확인함). 도는 건 2D 로 하고,
/// 입체감은 90°에 닿지 않는 기울기(26°)로만 준다.
///
/// 액센트는 **결과 숫자 + Primary 2곳**이다 (§3.2). 주사위 몸통은 갈래 색(`category.orange`)을 쓴다 —
/// 목록에서 누른 주황이 그대로 커지는 것이라 어디서 왔는지 다시 읽을 필요가 없다.
struct DiceScreen: View {
    var onClose: () -> Void = {}

    /// 눈 하나당 받는 P. `나온 눈만큼` 을 1~6 P 로 두면 출석(+50 P) 옆에서 너무 초라하다
    private static let pointsPerPip = 10

    @State private var stage: DiceStage = .idle
    @State private var face = 5
    /// 누적 회전각 — 굴릴 때마다 더한다
    @State private var spin: Double = 0
    /// 0 바닥, 1 최고점
    @State private var lift: Double = 0
    /// 입체로 보이게 하는 기울기. **90°에 닿으면 안 된다**
    @State private var tilt: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: "주사위 굴리기", onBack: onClose,
                         backIcon: "ic_header_close", backLabel: "닫기")

            Text("하루 한 번")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)
                .padding(.top, MyFisSpacing.lg)

            board
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            MyFisPrimaryButton(title: buttonTitle,
                               isEnabled: stage != .rolling,
                               action: tapButton)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 시뮬레이터에는 버튼을 누를 수단이 없다 — `SIMCTL_CHILD_MYFIS_AUTOPLAY=2`
        .task { MyFisDebug.scheduleAutoPlay(tapButton) }
    }

    // MARK: - 주사위

    private var board: some View {
        VStack(spacing: MyFisSpacing.xxxl) {
            ZStack(alignment: .bottom) {
                // 그림자가 높이를 알려 준다 — 뜨면 작아지고 옅어진다
                Ellipse()
                    .fill(Color.black.opacity(0.5 - 0.34 * lift))
                    .frame(width: 96 - 36 * lift, height: 18 - 7 * lift)

                DieFace(face: face)
                    .frame(width: 116, height: 116)
                    .rotation3DEffect(.degrees(tilt),
                                      axis: (x: 1, y: 0.45, z: 0),
                                      perspective: 0.55)
                    .rotationEffect(.degrees(spin))
                    .scaleEffect(1 + 0.10 * lift)
                    .offset(y: -18 - 132 * lift)
            }
            .frame(height: 230, alignment: .bottom)

            resultLine
        }
    }

    @ViewBuilder
    private var resultLine: some View {
        switch stage {
        case .result(let pips):
            VStack(spacing: MyFisSpacing.xs) {
                Text("\(pips)\(Self.particle(pips)) 나왔어요")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text("+\(pips * Self.pointsPerPip) P")
                    .font(MyFisFont.metricMd)
                    .foregroundStyle(MyFisColor.accent)
            }
        default:
            Text("나온 눈 하나당 \(Self.pointsPerPip) P")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
        }
    }

    /// 숫자를 한자음으로 읽었을 때의 주격 조사 — 일**이**, 이**가**, 삼**이**, 사**가**, 오**가**, 육**이**
    private static func particle(_ pips: Int) -> String {
        [1: "이", 2: "가", 3: "이", 4: "가", 5: "가", 6: "이"][pips] ?? "이"
    }

    private var buttonTitle: String {
        switch stage {
        case .idle: "굴리기"
        case .rolling: "구르는 중"
        case .result(let pips): "+\(pips * Self.pointsPerPip) P 받기"
        }
    }

    // MARK: - 굴리기

    private func tapButton() {
        switch stage {
        case .idle: roll()
        case .rolling: break
        case .result: onClose()
        }
    }

    private func roll() {
        stage = .rolling
        // TODO(서버): 눈은 서버가 정한다 (SPEC §8). 클라이언트가 뽑으면 조작할 수 있다
        let pips = Int.random(in: 1...6)

        // 구르는 몸통 — 세 바퀴를 끝에서 급히 죽인다.
        // 딱 떨어지게 세우지 않는다 — 진짜 주사위는 조금 비뚤게 선다
        withAnimation(.timingCurve(0.08, 0.62, 0.16, 1, duration: 1.25)) {
            spin += 1080 + Double.random(in: -11...11)
        }
        withAnimation(.easeOut(duration: 0.42)) { tilt = 26 }
        withAnimation(.easeIn(duration: 0.62).delay(0.42)) { tilt = 0 }
        // 던졌다가 떨어진다. 올라갈 때보다 내려올 때가 조금 길다
        withAnimation(.easeOut(duration: 0.46)) { lift = 1 }
        withAnimation(.easeIn(duration: 0.58).delay(0.46)) { lift = 0 }

        Task {
            // 눈이 갈리는 간격을 **점점 벌린다** — 회전이 느려지는 걸 눈이 따라간다
            var wait = 0.05
            var spent = 0.0
            while spent < 1.05 {
                try? await Task.sleep(for: .seconds(wait))
                spent += wait
                face = Int.random(in: 1...6)
                wait *= 1.2
            }
            face = pips
            // 착지 뒤 한 박자 두고 숫자를 띄운다 — 같이 나오면 굴러 멈춘 게 안 보인다
            try? await Task.sleep(for: .seconds(0.18))
            withAnimation(MyFisMotion.base) { stage = .result(pips) }
        }
    }
}

enum DiceStage: Equatable {
    case idle
    case rolling
    case result(Int)
}

// MARK: - 눈 하나

/// 주사위 한 면. 눈은 **3×3 격자**의 정해진 자리에 찍는다 — 진짜 주사위와 같은 배치라야 읽힌다.
struct DieFace: View {
    let face: Int

    /// 각 눈이 차지하는 격자 자리 (열, 행)
    private static let layout: [Int: [(Int, Int)]] = [
        1: [(1, 1)],
        2: [(0, 0), (2, 2)],
        3: [(0, 0), (1, 1), (2, 2)],
        4: [(0, 0), (2, 0), (0, 2), (2, 2)],
        5: [(0, 0), (2, 0), (1, 1), (0, 2), (2, 2)],
        6: [(0, 0), (0, 1), (0, 2), (2, 0), (2, 1), (2, 2)],
    ]

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let pip = side * 0.17
            let inset = side * 0.20
            let step = (side - inset * 2 - pip) / 2

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: side * 0.22, style: .continuous)
                    .fill(MyFisColor.categoryOrange)

                ForEach(Array((Self.layout[face] ?? []).enumerated()), id: \.offset) { _, spot in
                    Circle()
                        .fill(MyFisColor.onAccent)
                        .frame(width: pip, height: pip)
                        .offset(x: inset + step * CGFloat(spot.0),
                                y: inset + step * CGFloat(spot.1))
                }
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
