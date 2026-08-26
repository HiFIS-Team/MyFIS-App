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
    /// TODO: 활동 화면이 붙으면 연결한다 (P-05 ~ P-13)
    var onStart: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: action.introKicker, onBack: onClose,
                         backIcon: "ic_header_close", backLabel: "닫기")

            ScrollView {
                VStack(spacing: 0) {
                    // 작은 라벨이 제목 위에 붙어야 머리가 두 단으로 잡힌다 (레퍼런스와 같은 구성)
                    Text(action.introLabel)
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

                    Text(action.introPeriod)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .padding(.top, MyFisSpacing.md)

                    illustration
                        .padding(.top, MyFisSpacing.giant)

                    HintBubble(text: action.introHint, color: action.kind.color)
                        .padding(.top, MyFisSpacing.giant)
                }
                .font(MyFisFont.display)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.xxxl)
                .padding(.bottom, MyFisSpacing.xxxl)
            }

            MyFisPrimaryButton(title: action.introCta, action: onStart)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var illustration: some View {
        ActivityArt(action: action)
            .frame(height: 260)
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

    /// 동작 줄이기가 켜져 있으면 멈춰 둔다 (§7)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false

    private var color: Color { action.kind.color }

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

            // 뒤를 흐르는 원판 둘. 서로 **반대로** 움직여야 한 덩어리로 안 보인다
            Circle()
                .fill(color.opacity(0.16))
                .frame(width: 86, height: 86)
                .offset(x: -96, y: floating ? -52 : -28)
            Circle()
                .fill(color.opacity(0.10))
                .frame(width: 54, height: 54)
                .offset(x: 92, y: floating ? 56 : 30)

            Image(action.icon)
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
                .shadow(color: color.opacity(0.45), radius: 26, y: 14)
                .rotationEffect(.degrees(floating ? 4 : -4))
                .offset(y: floating ? -10 : 10)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
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

extension BenefitAction {
    /// 헤더 가운데 — 활동이 아니라 **갈래**를 적는다 (제목은 본문이 크게 맡는다)
    var introKicker: String {
        switch kind {
        case .stamp, .ladder, .luck, .quiz: "이벤트"
        case .touch, .sns: "함께 하기"
        case .attend, .routine, .cardio, .stretch: "운동"
        case .weight, .diet: "기록"
        }
    }

    /// 제목 위 작은 라벨 — 무슨 판에서 벌어지는 일인지
    var introLabel: String {
        switch kind {
        case .stamp, .ladder, .luck, .quiz: "마일리지 미니 이벤트"
        case .touch, .sns: "같이 하면 더 받는 적립"
        case .attend, .routine, .cardio, .stretch: "운동하고 받는 마일리지"
        case .weight, .diet: "매일 남기는 기록"
        }
    }

    /// TODO(서버): 기간·조건은 서버가 준다
    var introPeriod: String {
        switch kind {
        case .stamp: "이번 주 7일 채우기"
        case .ladder, .luck, .quiz: "하루 한 번"
        case .touch: "같은 지점에 있을 때"
        default: "오늘 하루"
        }
    }

    var introHint: String {
        switch kind {
        case .stamp: "이번 주 4일째 채우는 중"
        case .ladder: "오늘의 사다리, 최대 200 P"
        case .luck: "오늘의 행운은 최대 500 P"
        case .quiz: "AI가 오늘 낸 문제 한 개"
        case .touch: "지금 강남점에 12명 있어요"
        case .sns: "#MyFIS 로 올리면 인증돼요"
        default: "오늘 아직 안 받았어요"
        }
    }

    /// 버튼 글자는 **다음에 일어날 일**을 적는다 (§6.1)
    var introCta: String {
        switch kind {
        case .stamp: "도장 찍기"
        case .ladder: "사다리 타기"
        case .luck: "뽑기 돌리기"
        case .quiz: "퀴즈 풀기"
        case .touch: "옆 사람 찾기"
        case .sns: "사진 고르기"
        case .attend: "출석 체크하기"
        case .routine: "웨이트 하러 가기"
        case .cardio: "유산소 하러 가기"
        case .stretch: "스트레칭 시작"
        case .weight: "체중 기록하기"
        case .diet: "식단 찍기"
        }
    }
}
