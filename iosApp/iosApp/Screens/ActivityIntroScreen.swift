import SwiftUI

/// 적립 활동에 들어가기 전 **랜딩** (DESIGN.md §6.25).
///
/// 레퍼런스는 **카카오뱅크 이벤트 랜딩**이다 — 작은 라벨 · 두 줄짜리 큰 제목 · 기간 ·
/// 큰 그림 · 말풍선 한 줄 · 하단 버튼. **구조만 가져오고 색은 우리 것을 쓴다** (§3.2).
///
/// **활동마다 화면을 따로 만들지 않는다.** 뽑기든 사다리든 여기 들어와서 버튼을 누르면 시작한다 —
/// 그래야 활동이 늘어나도 들어가는 길이 하나로 남는다.
struct ActivityIntroScreen: View {
    let action: BenefitAction
    var onClose: () -> Void = {}

    /// 연출은 **이 화면 안에서** 끝난다 — 뽑기·사다리는 결과까지 여기서 보여준다 (§6.25)
    @State private var stage: ActivityStage = .idle
    /// 연출 진행값 0→1
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: action.kind.intro.kicker, onBack: onClose,
                         backIcon: "ic_header_close", backLabel: "닫기")

            ScrollView {
                VStack(spacing: 0) {
                    // 작은 라벨이 제목 위에 붙어야 머리가 두 단으로 잡힌다 (레퍼런스와 같은 구성)
                    Text(action.kind.intro.label)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textSecondary)
                        .padding(.bottom, MyFisSpacing.sm)

                    // 두 줄짜리 큰 제목 — 목록의 `~하고` / `~받기` 를 그대로 편 것이다.
                    // 목록에서 누른 문장이 그대로 커지므로 어디로 왔는지 다시 읽을 필요가 없다
                    Text(action.title)
                        .foregroundStyle(MyFisColor.textPrimary)
                        + Text("\n")
                        + Text(action.reward)
                        .foregroundStyle(MyFisColor.textPrimary)

                    Text(action.kind.intro.period)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .padding(.top, MyFisSpacing.md)

                    illustration
                        .padding(.top, MyFisSpacing.giant)

                    HintBubble(text: action.kind.intro.hint, color: action.kind.color)
                        .padding(.top, MyFisSpacing.giant)
                }
                .font(MyFisFont.display)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.xxxl)
                .padding(.bottom, MyFisSpacing.xxxl)
            }

            MyFisPrimaryButton(title: buttonTitle, isEnabled: stage != .playing, action: tapButton)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { MyFisDebug.scheduleAutoPlay(tapButton) }
    }

    private var illustration: some View {
        ActivityArt(action: action, stage: stage, progress: progress)
            .frame(height: 260)
    }

    private var buttonTitle: String {
        switch stage {
        case .idle: action.kind.intro.cta
        case .playing: action.kind.intro.playing
        case .result: "\(action.kind.intro.reward) 받기"
        }
    }

    /// 대기 → 재생 → 결과. **연출이 끝나야 버튼이 다시 산다**
    private func tapButton() {
        switch stage {
        case .idle:
            guard action.kind.intro.stagecraft else {
                // TODO: 연출이 없는 활동은 화면(P-05~P-13)이 붙으면 연결한다
                onClose()
                return
            }
            stage = .playing
            withAnimation(.linear(duration: action.kind.intro.duration)) {
                progress = 1
            } completion: {
                stage = .result
            }
        case .playing:
            break
        case .result:
            // TODO(서버): 여기서 적립을 올린다
            onClose()
        }
    }
}

/// 활동 그림 — **큰 글리프 하나와 그 뒤를 떠다니는 원판들.**
///
/// 아이콘을 그냥 크게 키우면 검정 위에 납작하게 붙어 그림처럼 안 보인다 (2026-08-26 지적).
/// 세 가지로 살린다 — **그라디언트**로 위아래 색을 다르게, **그림자**로 띄우고,
/// 뒤에 원판을 **다른 박자로** 흘린다.
///
/// 색 원판 위에 아이콘을 얹는 안은 버렸다 — 뽑기 캡슐처럼 **동그란 아이콘이 구멍처럼** 보인다 (확인함).
private struct ActivityArt: View {
    let action: BenefitAction
    var stage: ActivityStage = .idle
    var progress: Double = 0

    /// 동작 줄이기가 켜져 있으면 멈춰 둔다 (§7)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false

    private var color: Color { action.kind.color }

    private var style: ActivityArtStyle { action.kind.intro.art }

    var body: some View {
        ZStack {
            // 빛 — 검정 위에 글리프만 두면 붕 떠 보인다 (§6.25)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.26), .clear],
                        center: .center, startRadius: 0, endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .scaleEffect(floating ? 1.06 : 0.92)

            // 뒤를 흐르는 원판들. 활동마다 개수·자리·방향이 다르다
            ForEach(Array(style.discs.enumerated()), id: \.offset) { _, disc in
                Circle()
                    .fill(color.opacity(disc.alpha))
                    .frame(width: disc.size, height: disc.size)
                    .offset(x: disc.x, y: disc.y + (floating ? disc.dy : 0))
            }

            if stage != .idle, action.kind == .luck {
                LuckStage(color: color, progress: progress, reward: action.kind.intro.reward)
            } else {
                glyph
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: style.duration).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }

    private var glyph: some View {
        // 원색 아이콘은 **자기 색 그대로** 띄운다. tint 를 걸면 그림이 실루엣으로 뭉갠다
        Group {
            if action.glyphKeepsColor {
                Image(action.glyph)
                    .resizable()
                    .frame(width: 148, height: 148)
            } else {
                Image(action.glyph)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 148, height: 148)
                    // 위아래 색이 같으면 스티커처럼 납작하다
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.62)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }
        }
        .shadow(color: color.opacity(0.45), radius: 26, y: 14)
        .scaleEffect(floating ? 1 + style.pulse : 1 - style.pulse)
        .rotationEffect(.degrees(floating ? style.rotation : -style.rotation))
        .offset(y: floating ? -style.dy : style.dy)
    }
}

/// 말풍선 한 줄 — 버튼 바로 위에서 **누르고 싶게 만드는** 한마디.
/// 꼬리가 버튼을 가리키므로 아래를 향한다
private struct HintBubble: View {
    let text: String
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(MyFisFont.bodySm)
                .foregroundStyle(color)
                .padding(.horizontal, MyFisSpacing.lg)
                .padding(.vertical, MyFisSpacing.md)
                .background(color.opacity(0.16), in: Capsule())

            Triangle()
                .fill(color.opacity(0.16))
                .frame(width: 14, height: 7)
        }
    }

    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}

/// 활동 한 벌의 **말과 움직임**. 활동마다 한 곳에 모아 둔다 —
/// 흩어 두면 뽑기는 들뜨고 체중은 담담해야 하는 **말투 차이**가 금세 뭉개진다.
struct ActivityIntro {
    /// 헤더 가운데 한 단어
    let kicker: String
    /// 제목 위 작은 라벨
    let label: String
    /// 제목 밑 조건 한 줄
    let period: String
    /// 버튼 위 말풍선 — 누르고 싶게 만드는 한마디
    let hint: String
    /// 버튼 글자 — **다음에 일어날 일** (§6.1)
    let cta: String
    /// 그림이 움직이는 결 (§6.25)
    let art: ActivityArtStyle
    /// 재생 중 버튼 글자
    var playing: String = "잠깐만요…"
    /// TODO(서버): 결과는 서버가 정한다. 지금은 자리값
    var reward: String = "+20 P"
    /// 연출이 있는 활동인가 — 없으면 버튼이 그냥 닫는다
    var stagecraft: Bool = false
    /// 연출 길이(초)
    var duration: Double = 2.2
}

/// 그림의 결. **활동마다 다르게 움직인다** — 다 같은 박자로 뜨면 색만 바뀐 같은 화면이 된다.
struct ActivityArtStyle {
    /// 한 번 왕복하는 시간. 짧을수록 들뜬 느낌
    var duration: Double = 2.6
    /// 위아래로 뜨는 폭
    var dy: CGFloat = 10
    /// 기울어지는 각도
    var rotation: Double = 4
    /// 커졌다 작아지는 폭 (불꽃·통통 튀는 것에 쓴다)
    var pulse: CGFloat = 0
    /// 뒤를 흐르는 원판들
    var discs: [Disc] = [
        .init(x: -96, y: -28, size: 86, alpha: 0.16, dy: -24),
        .init(x: 92, y: 30, size: 54, alpha: 0.10, dy: 26),
    ]

    struct Disc {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let alpha: Double
        /// 움직이는 방향과 폭. **글리프와 반대로** 둬야 두 겹으로 보인다
        let dy: CGFloat
    }
}

extension BenefitKind {
    /// 활동별 말과 움직임. 말투를 일부러 다르게 썼다 —
    /// 뽑기·사다리는 들뜨게, 출석·체중은 담담하게, 스트레칭은 부드럽게
    var intro: ActivityIntro {
        switch self {
        case .attend:
            .init(kicker: "출석", label: "매일 첫 걸음",
                  period: "하루 한 번", hint: "지점에 닿으면 바로 눌러요",
                  cta: "출석 체크하기",
                  art: .init(duration: 1.8, dy: 16, rotation: 2,
                             discs: [.init(x: 0, y: 96, size: 120, alpha: 0.12, dy: 8)]))
        case .routine:
            .init(kicker: "루틴", label: "오늘 몫은 오늘",
                  period: "루틴을 끝까지", hint: "5개 중 2개 남았어요",
                  cta: "웨이트 하러 가기",
                  art: .init(duration: 2.2, dy: 8, rotation: 12,
                             discs: [.init(x: -104, y: 0, size: 72, alpha: 0.14, dy: 18),
                                     .init(x: 104, y: 0, size: 72, alpha: 0.14, dy: -18)]))
        case .cardio:
            .init(kicker: "유산소", label: "태운 만큼 쌓여요",
                  period: "10분마다", hint: "20분만 뛰어도 +20 P",
                  cta: "유산소 하러 가기",
                  art: .init(duration: 1.4, dy: 6, rotation: 2, pulse: 0.1,
                             discs: [.init(x: -70, y: 70, size: 46, alpha: 0.12, dy: -40),
                                     .init(x: 78, y: 88, size: 34, alpha: 0.10, dy: -52)]))
        case .stretch:
            .init(kicker: "스트레칭", label: "3분이면 끝나요",
                  period: "하루 한 번", hint: "AI가 오늘 고른 3동작",
                  cta: "스트레칭 시작",
                  art: .init(duration: 3.2, dy: 4, rotation: 9,
                             discs: [.init(x: 0, y: 0, size: 190, alpha: 0.08, dy: 0)]))
        case .water:
            .init(kicker: "물 마시기", label: "하루 여덟 잔",
                  period: "오늘 안에", hint: "지금 세 잔째",
                  cta: "한 잔 마셨어요",
                  art: .init(duration: 1.6, dy: 18, rotation: 0,
                             discs: [.init(x: 0, y: 86, size: 150, alpha: 0.12, dy: -6)]))
        // TODO(연출): 사다리에는 종이 뜯는 연출이 있었다. 주사위 굴리는 연출을 붙이면
        // `stagecraft: true` 로 되돌린다 (`LuckStage` 골격 참고 — 진행값 하나로 walk → reveal)
        case .dice:
            .init(kicker: "주사위", label: "오늘의 주사위",
                  period: "하루 한 번", hint: "꽝은 없어요. 최소 10 P",
                  cta: "주사위 굴리기",
                  art: .init(duration: 2.4, dy: 20, rotation: 8,
                             discs: [.init(x: -88, y: -40, size: 60, alpha: 0.14, dy: 34),
                                     .init(x: 88, y: 40, size: 60, alpha: 0.12, dy: -34)]),
                  playing: "굴리는 중…", reward: "+80 P")
        case .luck:
            .init(kicker: "뽑기", label: "오늘의 운을 시험할 시간",
                  period: "하루 한 번", hint: "오늘의 행운은 최대 500 P",
                  cta: "뽑기 돌리기",
                  art: .init(duration: 2.6, dy: 10, rotation: 16),
                  playing: "돌리는 중…", reward: "+320 P", stagecraft: true, duration: 2.2)
        case .scratch:
            .init(kicker: "카드 긁기", label: "은박 아래 뭐가 있을까",
                  period: "하루 한 번", hint: "최대 300 P",
                  cta: "카드 긁기",
                  art: .init(duration: 2.0, dy: 12, rotation: 6,
                             discs: [.init(x: -74, y: 62, size: 52, alpha: 0.13, dy: -28),
                                     .init(x: 80, y: -54, size: 44, alpha: 0.11, dy: 30)]),
                  playing: "긁는 중…", reward: "+150 P")
        case .quiz:
            .init(kicker: "퀴즈", label: "AI가 낸 오늘 문제",
                  period: "하루 한 문제", hint: "어제는 62%가 맞혔어요",
                  cta: "퀴즈 풀기",
                  art: .init(duration: 1.9, dy: 14, rotation: 3, pulse: 0.06,
                             discs: [.init(x: -84, y: -56, size: 40, alpha: 0.14, dy: -14),
                                     .init(x: 96, y: -20, size: 28, alpha: 0.12, dy: 16),
                                     .init(x: 60, y: 76, size: 52, alpha: 0.10, dy: 20)]))
        case .touch:
            .init(kicker: "함께", label: "같이 운동하는 사람들",
                  period: "같은 지점에 있을 때", hint: "지금 강남점에 12명 있어요",
                  cta: "옆 사람 찾기",
                  art: .init(duration: 2.0, dy: 6, rotation: 3,
                             discs: [.init(x: -110, y: 10, size: 64, alpha: 0.14, dy: 0),
                                     .init(x: 110, y: 10, size: 64, alpha: 0.14, dy: 0)]))
        case .sns:
            .init(kicker: "자랑", label: "오늘의 한 컷",
                  period: "하루 한 번", hint: "#MyFIS 를 달면 바로 인증돼요",
                  cta: "사진 고르기",
                  art: .init(duration: 2.8, dy: 16, rotation: 2,
                             discs: [.init(x: -76, y: 84, size: 52, alpha: 0.13, dy: -56),
                                     .init(x: 82, y: 66, size: 34, alpha: 0.10, dy: -44)]))
        case .weight:
            .init(kicker: "기록", label: "매일 남기는 한 줄",
                  period: "오늘 하루", hint: "어제보다 -0.3 kg",
                  cta: "체중 기록하기",
                  art: .init(duration: 3.4, dy: 6, rotation: 2,
                             discs: [.init(x: 0, y: 92, size: 140, alpha: 0.10, dy: 0)]))
        case .diet:
            .init(kicker: "식단", label: "먹은 걸 남기면",
                  period: "한 끼에 한 번", hint: "AI가 칼로리까지 읽어줘요",
                  cta: "식단 찍기",
                  art: .init(duration: 3.0, dy: 8, rotation: 6,
                             discs: [.init(x: -92, y: 46, size: 58, alpha: 0.12, dy: -18),
                                     .init(x: 88, y: -46, size: 44, alpha: 0.10, dy: 18)]))
        }
    }
}
