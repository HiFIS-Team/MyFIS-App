import SwiftUI

/// SPEC.md G-03 모임 개설 **2단계 — 모임 소개** (DESIGN.md §6.32).
///
/// 레퍼런스는 **당근 모임 만들기 2단계**. 1단계(§6.30)가 *무엇을* 묻는다면 여기는 *어떤 모임인지* 묻는다.
///
/// **AI 도움받기가 이 화면의 주인공이다.** 소개 글은 쓰기 어려워서 대개 비어 있거나 한 줄로 끝난다 —
/// 우리 앱은 이미 AI 가 루틴을 짜고 식단을 읽으므로(§6.13 · SPEC W-·H-03) 여기서도 같은 손을 빌린다.
///
/// **원본과 다른 것**
/// - 원본의 `Beta` 뱃지는 **주황·보라 그라디언트**다. 우리는 색이 하나고 그라디언트는 진행바만 쓴다(§3.2 · §5.4)
///   → 판은 중립(`surface.3`)으로 두고 **AI 봇 그림**을 앞에 세웠다.
///   그 그림은 이미 `AI 퀴즈`(§6.23)가 쓰는 얼굴이라 **앱 안에서 AI 는 늘 같은 얼굴**이 된다
/// - 원본 `TIP` 뱃지는 파랑이다. 색을 하나 더 만들지 않고 중립으로 뒀다 —
///   이 화면의 라임은 **토글과 `모임 만들기` 둘**이 이미 쓰고 있다 (§3.2 상한)
struct GroupIntroScreen: View {
    var onClose: () -> Void = {}
    var onBack: () -> Void = {}
    var onCreate: (String) -> Void = { _ in }

    @State private var intro = ""
    @State private var useAI = MyFisDebug.groupIntroAI

    private static let limit = 500

    private var ready: Bool { !intro.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("모임을 소개해주세요")
                        .font(MyFisFont.titleLg)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .padding(.bottom, MyFisSpacing.xl)

                    aiToggle

                    if useAI {
                        aiLoading
                            .padding(.top, MyFisSpacing.xxl)
                    } else {
                        editor
                            .padding(.top, MyFisSpacing.xxl)
                        tip
                            .padding(.top, MyFisSpacing.xl)
                    }
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
            }

            // **`이전` 이 좁고 `모임 만들기` 가 넓다** — 나란히 두되 무게를 다르게 준다.
            // 같은 폭으로 두면 되돌아가는 길과 끝내는 길이 같은 값으로 읽힌다
            HStack(spacing: MyFisSpacing.md) {
                MyFisSecondaryButton(title: "이전", action: onBack)
                    .frame(width: 96)
                MyFisPrimaryButton(title: "모임 만들기", isEnabled: ready) { onCreate(intro) }
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.bottom, MyFisSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        HStack(spacing: 0) {
            HeaderIcon("ic_header_close", "닫기", action: onClose)
            Spacer(minLength: 0)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }

    /// 켜고 끄는 줄은 **네이티브 스위치 그대로** 쓴다 — 직접 그리면 두 판이 어긋난다
    private var aiToggle: some View {
        MyFisCard {
            HStack(spacing: MyFisSpacing.md) {
                BetaBadge()
                Text("AI로 소개 도움받기")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                Spacer(minLength: MyFisSpacing.md)
                Toggle("", isOn: $useAI)
                    .labelsHidden()
                    .tint(MyFisColor.accent)
            }
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.sm) {
            Text("모임 소개")
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.textPrimary)

            ZStack(alignment: .topLeading) {
                if intro.isEmpty {
                    Text("어떤 활동을 하는지 적어 주세요. 소개가 잘 쓰인 모임에 사람이 모입니다.")
                        .font(MyFisFont.body)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .padding(.horizontal, MyFisSpacing.lg)
                        .padding(.vertical, MyFisSpacing.lg + 2)
                }
                TextEditor(text: $intro)
                    .font(MyFisFont.body)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .tint(MyFisColor.accent)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, MyFisSpacing.md)
                    .padding(.vertical, MyFisSpacing.md)
                    .onChange(of: intro) { _, new in
                        if new.count > Self.limit { intro = String(new.prefix(Self.limit)) }
                    }
            }
            .frame(height: 200)
            .background(
                MyFisColor.surface2,
                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
            )

            // 남은 글자가 아니라 **쓴 글자**를 센다 — 한도는 벽이지 목표가 아니다
            Text("\(intro.count)/\(Self.limit)")
                .font(MyFisFont.caption.monospacedDigit())
                .foregroundStyle(MyFisColor.textTertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    /// **빈 칸 앞에서 뭘 쓸지 모르는 게 진짜 문제다.** 그래서 질문으로 준다
    private var tip: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            HStack(spacing: MyFisSpacing.sm) {
                Text("TIP")
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .padding(.horizontal, MyFisSpacing.sm)
                    .padding(.vertical, 2)
                    .background(MyFisColor.surface3, in: Capsule())
                Text("이런 내용을 적으면 좋아요")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }

            MyFisCard {
                VStack(alignment: .leading, spacing: MyFisSpacing.sm) {
                    ForEach(Self.tips, id: \.self) { line in
                        HStack(alignment: .top, spacing: MyFisSpacing.sm) {
                            Text("・")
                            Text(line)
                            Spacer(minLength: 0)
                        }
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                    }
                }
            }
        }
    }

    /// **스켈레톤이다** (§6.7 로딩) — 스피너를 쓰지 않는다. 레이아웃이 튀지 않는다
    private var aiLoading: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            HStack(spacing: MyFisSpacing.sm) {
                Image("ic_benefit_quiz")
                    .resizable()
                    .frame(width: 22, height: 22)
                Text("모임 소개에 필요한 질문을 만들고 있어요")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
            }
            SkeletonBar(ratio: 1)
            SkeletonBar(ratio: 0.55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private static let tips = [
        "주로 어떤 활동을 하나요?",
        "언제, 어디에서 모이나요?",
        "어떤 분들과 함께하고 싶나요?",
        "지켜야 할 규칙이 있나요? (가입 조건 · 출석 · 나가는 기준)",
    ]
}

/// `Beta` 뱃지 — **AI 는 앱 안에서 늘 같은 얼굴이다** (`AI 퀴즈` §6.23 과 같은 그림).
///
/// ⚠️ 봇 그림에 `renderingMode(.template)` 을 걸지 않는다 — 파랑·남색·시안 세 색이 있어야
/// 얼굴이 되고, 한 색으로 누르면 실루엣만 남는다 (§8)
private struct BetaBadge: View {
    var body: some View {
        HStack(spacing: MyFisSpacing.xs) {
            Image("ic_benefit_quiz")
                .resizable()
                .frame(width: 14, height: 14)
            Text("Beta")
                .font(MyFisFont.caption)
                .foregroundStyle(MyFisColor.textSecondary)
        }
        .padding(.horizontal, MyFisSpacing.sm)
        .padding(.vertical, 3)
        .background(MyFisColor.surface3, in: Capsule())
    }
}

/// 로딩 자리막이 (§6.7) — 폭만 다르게 두 줄이면 "글이 올 자리"로 읽힌다
private struct SkeletonBar: View {
    let ratio: CGFloat

    var body: some View {
        GeometryReader { geo in
            Capsule()
                .fill(MyFisColor.surface2)
                .frame(width: geo.size.width * ratio)
        }
        .frame(height: 28)
    }
}
