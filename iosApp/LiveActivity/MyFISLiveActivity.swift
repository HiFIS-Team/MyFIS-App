import ActivityKit
import SwiftUI
import WidgetKit

/// 운동 세션(W-04)의 **잠금화면 · 다이내믹 아일랜드** (DESIGN §6.37 · SPEC W-04).
///
/// 앱과 **다른 프로세스**다. 그릴 값은 앱이 `WorkoutActivityAttributes.ContentState` 로 보내고,
/// 시간은 시각으로 받아 시스템이 흘린다 — 앱이 멈춰 있어도 숫자가 선다.
///
/// - **잠금화면 바탕은 리퀴드 글래스**다 🟢 (2026-09-15, 사용자 지적 · 폰에서 후보를 보고 정함) — `liquidGlassBackground()`.
///   유리는 배경화면에 따라 밝아질 수 있어 **글자는 시스템 색**(`.primary` · `.secondary`)이다
/// - **아일랜드는 시스템이 검정으로 고정한다** — 거기서는 우리 흰 글자 토큰을 쓴다
/// - **표식은 메인 FS 로고 하나다** 🟢 (2026-09-15, 사용자 지정 — *"우리 메인 로고로 해야지"*)
/// - `이전` · `나가기` 는 없다 — 좁은 자리에서 잘못 누르기 쉽고, 잠금화면에서 세션이 끝나면 안 된다
/// - Pretendard 는 확장 `Info.plist` 의 `UIAppFonts` 로 올린다. 위젯은 시스템이 그리므로 런타임 등록이 닿지 않는다
@main
struct MyFISLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        WorkoutLiveActivity()
    }
}

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            WorkoutLockScreen(state: context.state)
                .liquidGlassBackground()
        } dynamicIsland: { context in
            let state = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: MyFisSpacing.sm) {
                        FSWordmark(height: 16)
                        Text(state.isFinished ? "운동 세션" : state.stageLabel)
                            .font(MyFisFont.label)
                            .foregroundStyle(MyFisColor.textSecondary)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ElapsedClock(state: state, alignment: .trailing)
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .frame(width: 56, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                        SessionTitle(state: state)
                            .foregroundStyle(MyFisColor.textPrimary)
                        HStack(spacing: MyFisSpacing.md) {
                            SessionValue(state: state)
                                .foregroundStyle(MyFisColor.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            SessionControls(state: state, surface: .island)
                        }
                    }
                }
            } compactLeading: {
                HStack(spacing: MyFisSpacing.xs) {
                    FSWordmark(height: 12)
                    Text(state.progress)
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textPrimary)
                }
            } compactTrailing: {
                // 웜업이면 **남은 시간**, 운동이면 **총 경과** — 그 단계에서 가장 궁금한 숫자
                Group {
                    if state.isWarmup && !state.isFinished {
                        WarmupClock(state: state, alignment: .trailing)
                    } else {
                        ElapsedClock(state: state, alignment: .trailing)
                    }
                }
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textPrimary)
                .frame(width: 44, alignment: .trailing)
            } minimal: {
                FSWordmark(height: 10)
            }
            .keylineTint(MyFisColor.accent)
        }
    }
}

// MARK: - 잠금화면

/// 시스템 유리 위 네 줄 — 로고·마디·경과 / 이름 / 값·버튼 / 다음. 높이 한도 160pt
private struct WorkoutLockScreen: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
            HStack(spacing: MyFisSpacing.sm) {
                FSWordmark(height: 16)
                Text(state.isFinished ? "운동 세션" : state.stageLabel)
                    .font(MyFisFont.label)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: MyFisSpacing.sm)
                ElapsedClock(state: state, alignment: .trailing)
                    .font(MyFisFont.label)
                    .foregroundStyle(.primary)
                    .frame(width: 56, alignment: .trailing)
            }
            SessionTitle(state: state)
                .foregroundStyle(.primary)
            HStack(spacing: MyFisSpacing.md) {
                SessionValue(state: state)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SessionControls(state: state, surface: .glass)
            }
            Text(nextLine)
                .font(MyFisFont.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(MyFisSpacing.lg)
        // 버튼 뒤 **1초쯤 천천히 바뀌던** 시스템 글자 전환을 줄인다 (2026-09-15 실기)
        .contentTransition(.identity)
    }

    private var nextLine: String {
        if state.isFinished { return "이걸로 끝이에요" }
        return state.nextTitle.map { "다음 · \($0)" } ?? "마지막이에요"
    }
}

// MARK: - 조각

/// 운동 이름 — 색은 부르는 쪽이 정한다 (유리 위 시스템 색 / 아일랜드 흰 글자)
private struct SessionTitle: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        Text(state.isFinished ? "오늘 운동을 마쳤어요" : state.title)
            .font(MyFisFont.titleSm)
            .lineLimit(1)
    }
}

/// 1순위 숫자 — 웜업은 **남은 시간**, 운동은 **처방**, 끝났으면 **총 시간**. **왼쪽 정렬**이다.
///
/// ⚠️ 앱 값 판은 `metric.lg`(40)지만 여기는 `metric.md`(28)다 — `7.5kg × 15회` 옆에 버튼 둘이 서야 해서
/// 40 이면 좁은 폰에서 넘친다
private struct SessionValue: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        Group {
            if let seconds = state.finishedSeconds {
                Text(timerText(seconds))
            } else if state.isWarmup {
                WarmupClock(state: state, alignment: .leading)
            } else {
                Text(state.load ?? "")
            }
        }
        .font(MyFisFont.metricMd)
        .lineLimit(1)
    }
}

/// 버튼이 앉는 자리 — 유리 위와 아일랜드(검정) 위는 판 색이 다르다
private enum ControlSurface {
    case glass, island
}

/// `⏸`/`▶` · `⏭` — 앱 프로세스에서 세션 시계를 만진다 (`LiveActivityIntent`). 끝났으면 그리지 않는다
private struct SessionControls: View {
    let state: WorkoutActivityAttributes.ContentState
    let surface: ControlSurface

    var body: some View {
        if !state.isFinished {
            HStack(spacing: MyFisSpacing.sm) {
                // 뒤집기가 아니라 **값**을 싣는다 — 늦게 바뀌어 두 번 눌러도 멈춤이 풀리지 않는다
                Button(intent: SessionPlayIntent(playing: state.pausedAt != nil)) {
                    ControlGlyph(name: state.pausedAt == nil ? "ic_session_pause" : "ic_session_play",
                                 surface: surface)
                }
                .accessibilityLabel(state.pausedAt == nil ? "일시정지" : "이어서 하기")
                Button(intent: SessionNextIntent()) {
                    ControlGlyph(name: "ic_session_next", surface: surface)
                }
                .accessibilityLabel("다음")
            }
            .buttonStyle(.plain)
        }
    }
}

/// 라이브 액티비티 버튼 (DESIGN §6.1) — 44 정사각 · `radius.md` · 글리프 24.
/// 유리 위에서는 **시스템 채움**(`.fill.tertiary`), 아일랜드에서는 `surface.2`
private struct ControlGlyph: View {
    let name: String
    let surface: ControlSurface

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        let glyph = Image(name)
            .renderingMode(.template)
            .resizable()
            .frame(width: 24, height: 24)
            .frame(width: MyFisSize.minTouchTarget, height: MyFisSize.minTouchTarget)
        switch surface {
        case .glass:
            glyph
                .foregroundStyle(.primary)
                .background(.fill.tertiary, in: shape)
        case .island:
            glyph
                .foregroundStyle(MyFisColor.textPrimary)
                .background(MyFisColor.surface2, in: shape)
        }
    }
}

/// **메인 FS 로고** — 잠금화면 · 아일랜드 모두 이것 하나다 🟢 (2026-09-15, 사용자 지정 — *"우리 메인 로고로 해야지"*).
/// ⚠️ 한때 잠금화면에만 코인을 썼다 (밝은 유리 위 라임 대비를 걱정해서) — 사용자가 되돌렸다
private struct FSWordmark: View {
    let height: CGFloat

    var body: some View {
        Image("ic_logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
    }
}

/// 총 경과 — 시스템이 흘린다. 멈춰 있으면 멈춘 시각에 서 있다.
///
/// ⚠️ 시스템 시계 글자는 **자리 폭을 끝까지 차지한다** — 정렬을 부르는 쪽이 준다 (값 자리는 왼쪽, 아일랜드는 오른쪽).
/// 앞자리 0 이 없다 (`0:04`). 앱 헤더는 `00:04` — 모양은 못 바꾼다
private struct ElapsedClock: View {
    let state: WorkoutActivityAttributes.ContentState
    let alignment: TextAlignment
    /// 라이브 액티비티가 떠 있을 수 있는 최대 시간
    private static let cap: TimeInterval = 8 * 60 * 60

    var body: some View {
        Group {
            if let seconds = state.finishedSeconds {
                Text(timerText(seconds))
            } else if let paused = state.pausedAt {
                // 멈췄으면 **글자로 적는다** — 시스템 시계의 `pauseTime` 에 맡기지 않는다 (아래 `WarmupClock`)
                Text(timerText(Int(paused.timeIntervalSince(state.elapsedFrom))))
            } else {
                Text(timerInterval: state.elapsedFrom...state.elapsedFrom.addingTimeInterval(Self.cap),
                     countsDown: false, showsHours: false)
            }
        }
        .monospacedDigit()
        .multilineTextAlignment(alignment)
    }
}

/// 웜업 남은 시간 — 시스템이 흘린다. ⚠️ 앱이 멈춰 있으면 0 에서 서고, 다음 웜업으로는 **앱이 깨어나야** 넘어간다
private struct WarmupClock: View {
    let state: WorkoutActivityAttributes.ContentState
    let alignment: TextAlignment

    var body: some View {
        if let from = state.warmupFrom, let until = state.warmupUntil {
            Group {
                if let paused = state.pausedAt {
                    // ⚠️ **거꾸로 세는 시스템 시계는 `pauseTime` 을 줘도 서지 않았다** (2026-09-15 폰 실기 —
                    // 같은 카드의 경과 시계는 섰다). 멈췄으면 남은 초를 글자로 적는다 (앱과 같은 올림)
                    Text(timerText(max(0, Int(until.timeIntervalSince(paused).rounded(.up)))))
                } else {
                    Text(timerInterval: from...until, countsDown: true, showsHours: false)
                }
            }
            .monospacedDigit()
            .multilineTextAlignment(alignment)
        }
    }
}

private extension View {
    /// 잠금화면 바탕 — **iOS 26 리퀴드 글래스** 🟢 (2026-09-15, 폰에서 후보 넷을 띄워 보고 정했다).
    ///
    /// - ⚠️ **칠(`activityBackgroundTint`)을 안 쓰면 시스템이 검은 판을 깔았다** — 같은 화면의 음악 카드는 유리였다
    /// - 칠을 투명으로 두고 `glassEffect` 를 판으로 깐다. 공식 문서에 방법이 없어 `system` · `clear` · `tint` · `glass`
    ///   넷을 폰에서 나란히 봤고 `glass` 가 음악 카드와 같았다
    /// - iOS 17 ~ 25 는 시스템 기본 바탕 그대로 둔다
    @ViewBuilder
    func liquidGlassBackground() -> some View {
        if #available(iOS 26.0, *) {
            self
                .background { Color.clear.glassEffect(.regular, in: Rectangle()) }
                .activityBackgroundTint(.clear)
        } else {
            self
        }
    }
}

/// 시스템 시계와 **같은 모양**(`0:22` · `12:34`)으로 적는다 — 멈춤 · 끝남에서 글자로 바뀌어도 모양이 튀지 않게
private func timerText(_ seconds: Int) -> String {
    "\(seconds / 60):" + String(format: "%02d", seconds % 60)
}
