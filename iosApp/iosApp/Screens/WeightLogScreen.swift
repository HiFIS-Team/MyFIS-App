import SwiftUI

/// SPEC.md P-08 체중 기록 (DESIGN.md §6.24).
///
/// **체중계 표시부를 조절하는 화면이다.** 숫자 키패드를 띄우지 않는다 —
/// 오늘 몸무게는 어제 값에서 조금 움직이는 값이라, 처음부터 치는 것보다 **밀어서 맞추는 게 빠르다.**
///
/// 숫자는 가운데 고정이고 **밑의 눈금자가 움직인다** (체중계 창을 돌리는 느낌).
struct WeightLogScreen: View {
    var onBack: () -> Void = {}
    /// TODO(서버): 기록을 올린다. `User.weightKg` 도 이 값으로 갱신된다 (SPEC P-08)
    var onSave: (Double) -> Void = { _ in }

    /// 눈금 하나 = 0.1kg. 정수(`727`)로 다뤄야 0.1 을 더할 때 오차가 안 쌓인다.
    ///
    /// **처음 값은 `task` 에서 넣는다.** 초기값으로 주면 `scrollPosition` 이
    /// 레이아웃 전이라 스크롤이 안 걸리고 눈금자가 맨 왼쪽(30kg)에 머문다 (확인함)
    @State private var tick: Int?

    private var value: Double { Double(tick ?? WeightPlaceholder.lastTick) / 10 }
    private var diff: Double { value - WeightPlaceholder.last }

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: "체중 기록", onBack: onBack)

            Spacer(minLength: 0)

            readout
            WeightRuler(tick: $tick)
                .padding(.top, MyFisSpacing.xxxl)

            Spacer(minLength: 0)

            // TODO: 하루 1회만 적립된다 (여러 번 기록은 가능) — 서버가 판정한다
            MyFisPrimaryButton(title: "기록하고 +20 P 받기") {
                onSave(value)
                onBack()
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.bottom, MyFisSpacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            guard tick == nil else { return }
            tick = WeightPlaceholder.lastTick
        }
    }

    /// 체중계 창 — 숫자가 주인공이라 `metric.xl`. 자릿수가 바뀌어도 안 흔들리게 tnum
    private var readout: some View {
        VStack(spacing: MyFisSpacing.sm) {
            HStack(alignment: .lastTextBaseline, spacing: MyFisSpacing.sm) {
                Text(value, format: .number.precision(.fractionLength(1)))
                    .font(MyFisFont.metricXl.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
                Text("kg")
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.textTertiary)
            }

            // **증감에 좋고 나쁨 색을 붙이지 않는다** (SPEC P-08) —
            // 체중이 느는 게 목표인 사람도 있다
            Text(diffLabel)
                .font(MyFisFont.bodySm.monospacedDigit())
                .foregroundStyle(MyFisColor.textSecondary)
        }
    }

    private var diffLabel: String {
        let last = WeightPlaceholder.last.formatted(.number.precision(.fractionLength(1)))
        guard abs(diff) >= 0.05 else { return "지난 기록 \(last) kg 과 같아요" }
        let sign = diff > 0 ? "+" : "−"
        let gap = abs(diff).formatted(.number.precision(.fractionLength(1)))
        return "지난 기록 \(last) kg 보다 \(sign)\(gap) kg"
    }
}

/// 가로 눈금자 — **숫자는 가만히 있고 눈금이 흐른다.**
///
/// 눈금 한 칸이 `0.1kg`, 1kg 마다 긴 눈금과 숫자를 둔다.
/// 가운데 표시선에 걸린 눈금이 곧 값이다 (`scrollPosition`).
private struct WeightRuler: View {
    @Binding var tick: Int?

    /// 30.0 ~ 150.0 kg. 이 밖은 입력할 일이 없다
    private static let range = 300...1500
    /// 눈금 사이 간격. 좁으면 0.1 을 집기 어렵고 넓으면 10kg 옮기는 데 몇 번을 쓸어야 한다
    private static let spacing: CGFloat = 10
    private static let height: CGFloat = 64

    var body: some View {
        // 표시선은 **눈금 줄에만** 걸친다. 숫자 줄까지 내려오면 눈금이 아니라 화면을 가르는 선이 된다
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Self.range, id: \.self) { t in
                            Tick(value: t)
                                .frame(width: Self.spacing, height: Self.height, alignment: .top)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                // 첫 눈금과 마지막 눈금도 가운데까지 올 수 있어야 한다
                .contentMargins(.horizontal, (proxy.size.width - Self.spacing) / 2, for: .scrollContent)
                .scrollPosition(id: $tick, anchor: .center)
                .scrollTargetBehavior(.viewAligned)
            }
            .frame(height: Self.height + 20)

            // 가운데 표시선 — **이 화면의 라임 한 곳** (§3.2)
            Capsule()
                .fill(MyFisColor.accent)
                .frame(width: 3, height: 32)
                .allowsHitTesting(false)
        }
        // 0.1 이 넘어갈 때마다 손끝에 걸리는 느낌을 준다 (§6.7)
        .sensoryFeedback(.selection, trigger: tick)
    }

    /// 눈금 하나. 1kg 는 길고 숫자까지, 0.5kg 는 중간, 나머지는 짧게
    private struct Tick: View {
        let value: Int

        private var isWhole: Bool { value % 10 == 0 }
        private var isHalf: Bool { value % 5 == 0 }

        var body: some View {
            VStack(spacing: MyFisSpacing.sm) {
                Capsule()
                    .fill(isWhole ? MyFisColor.textSecondary : MyFisColor.borderSubtle)
                    .frame(width: isWhole ? 2 : 1, height: isWhole ? 28 : (isHalf ? 20 : 14))

                if isWhole {
                    Text("\(value / 10)")
                        .font(MyFisFont.caption.monospacedDigit())
                        .foregroundStyle(MyFisColor.textTertiary)
                        .fixedSize()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

/// TODO(서버): 마지막 기록은 서버가 준다. 처음이면 가입(A-06)에서 받은 값을 쓴다
enum WeightPlaceholder {
    static let last = 72.7
    static var lastTick: Int { Int((last * 10).rounded()) }
}
