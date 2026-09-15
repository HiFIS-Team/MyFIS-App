import ActivityKit
import SwiftUI
import WidgetKit

/// 운동 세션(W-04)의 **잠금화면 · 다이내믹 아일랜드** (DESIGN §6.37 · SPEC W-04).
///
/// 앱과 **다른 프로세스**다. 그릴 값은 앱이 `WorkoutActivityAttributes.ContentState` 로 보내고,
/// 시간은 시각으로 받아 시스템이 흘린다 — 앱이 멈춰 있어도 숫자가 선다.
///
/// - 라임은 **웨이트 표식 하나**다 (§3.2). 버튼은 `surface.2` 판에 흰 글리프
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
                .activityBackgroundTint(MyFisColor.bgBase)
                .activitySystemActionForegroundColor(MyFisColor.textPrimary)
        } dynamicIsland: { context in
            let state = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: MyFisSpacing.sm) {
                        WeightMark(size: 20)
                        Text(state.isFinished ? "운동 세션" : state.stageLabel)
                            .font(MyFisFont.label)
                            .foregroundStyle(MyFisColor.textSecondary)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ElapsedClock(state: state)
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .frame(width: 56, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                        SessionTitle(state: state)
                        HStack(spacing: MyFisSpacing.md) {
                            SessionValue(state: state)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            SessionControls(state: state)
                        }
                    }
                }
            } compactLeading: {
                HStack(spacing: MyFisSpacing.xs) {
                    WeightMark(size: 16)
                    Text(state.progress)
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textPrimary)
                }
            } compactTrailing: {
                // 웜업이면 **남은 시간**, 운동이면 **총 경과** — 그 단계에서 가장 궁금한 숫자
                Group {
                    if state.isWarmup && !state.isFinished {
                        WarmupClock(state: state)
                    } else {
                        ElapsedClock(state: state)
                    }
                }
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textPrimary)
                .frame(width: 44, alignment: .trailing)
            } minimal: {
                WeightMark(size: 16)
            }
            .keylineTint(MyFisColor.accent)
        }
    }
}

// MARK: - 잠금화면

/// 높이 한도 160pt 안에 네 줄 — 표식·마디·경과 / 이름 / 값·버튼 / 다음
private struct WorkoutLockScreen: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
            HStack(spacing: MyFisSpacing.sm) {
                WeightMark(size: 18)
                Text(state.isFinished ? "운동 세션" : state.stageLabel)
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .lineLimit(1)
                Spacer(minLength: MyFisSpacing.sm)
                ElapsedClock(state: state)
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .frame(width: 56, alignment: .trailing)
            }
            SessionTitle(state: state)
            HStack(spacing: MyFisSpacing.md) {
                SessionValue(state: state)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SessionControls(state: state)
            }
            Text(nextLine)
                .font(MyFisFont.caption)
                .foregroundStyle(MyFisColor.textSecondary)
                .lineLimit(1)
        }
        .padding(MyFisSpacing.lg)
    }

    private var nextLine: String {
        if state.isFinished { return "이걸로 끝이에요" }
        return state.nextTitle.map { "다음 · \($0)" } ?? "마지막이에요"
    }
}

// MARK: - 조각

private struct SessionTitle: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        Text(state.isFinished ? "오늘 운동을 마쳤어요" : state.title)
            .font(MyFisFont.titleSm)
            .foregroundStyle(MyFisColor.textPrimary)
            .lineLimit(1)
    }
}

/// 1순위 숫자 — 웜업은 **남은 시간**, 운동은 **처방**, 끝났으면 **총 시간**.
///
/// ⚠️ 앱 값 판은 `metric.lg`(40)지만 여기는 `metric.md`(28)다 — `7.5kg × 15회` 옆에 버튼 둘이 서야 해서
/// 40 이면 좁은 폰에서 넘친다
private struct SessionValue: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        Group {
            if let seconds = state.finishedSeconds {
                Text(clockText(seconds))
            } else if state.isWarmup {
                WarmupClock(state: state)
            } else {
                Text(state.load ?? "")
            }
        }
        .font(MyFisFont.metricMd)
        .foregroundStyle(MyFisColor.textPrimary)
        .lineLimit(1)
    }
}

/// `⏸`/`▶` · `⏭` — 앱 프로세스에서 세션 시계를 만진다 (`LiveActivityIntent`). 끝났으면 그리지 않는다
private struct SessionControls: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        if !state.isFinished {
            HStack(spacing: MyFisSpacing.sm) {
                Button(intent: SessionToggleIntent()) {
                    ControlGlyph(name: state.pausedAt == nil ? "ic_session_pause" : "ic_session_play")
                }
                .accessibilityLabel(state.pausedAt == nil ? "일시정지" : "이어서 하기")
                Button(intent: SessionNextIntent()) {
                    ControlGlyph(name: "ic_session_next")
                }
                .accessibilityLabel("다음")
            }
            .buttonStyle(.plain)
        }
    }
}

/// 라이브 액티비티 버튼 (DESIGN §6.1) — 44 정사각 · `surface.2` · `radius.md` · 글리프 24
private struct ControlGlyph: View {
    let name: String

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(MyFisColor.textPrimary)
            .frame(width: MyFisSize.minTouchTarget, height: MyFisSize.minTouchTarget)
            .background(MyFisColor.surface2,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
    }
}

/// 웨이트 표식 — 이 화면의 **유일한 라임**
private struct WeightMark: View {
    let size: CGFloat

    var body: some View {
        Image("ic_tab_weight")
            .renderingMode(.template)
            .resizable()
            .frame(width: size, height: size)
            .foregroundStyle(MyFisColor.accent)
    }
}

/// 총 경과 — 시스템이 흘린다. 멈춰 있으면 멈춘 시각에 서 있다.
///
/// ⚠️ 시스템 시계라 앞자리 0 이 없다 (`0:04`). 앱 헤더는 `00:04` — 모양은 못 바꾼다
private struct ElapsedClock: View {
    let state: WorkoutActivityAttributes.ContentState
    /// 라이브 액티비티가 떠 있을 수 있는 최대 시간
    private static let cap: TimeInterval = 8 * 60 * 60

    var body: some View {
        Group {
            if let seconds = state.finishedSeconds {
                Text(clockText(seconds))
            } else {
                Text(timerInterval: state.elapsedFrom...state.elapsedFrom.addingTimeInterval(Self.cap),
                     pauseTime: state.pausedAt, countsDown: false, showsHours: false)
            }
        }
        .monospacedDigit()
        .multilineTextAlignment(.trailing)
    }
}

/// 웜업 남은 시간 — 시스템이 흘린다. ⚠️ 앱이 멈춰 있으면 0 에서 서고, 다음 웜업으로는 **앱이 깨어나야** 넘어간다
private struct WarmupClock: View {
    let state: WorkoutActivityAttributes.ContentState

    var body: some View {
        if let from = state.warmupFrom, let until = state.warmupUntil {
            Text(timerInterval: from...until, pauseTime: state.pausedAt, countsDown: true, showsHours: false)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
    }
}

private func clockText(_ seconds: Int) -> String {
    String(format: "%02d:%02d", seconds / 60, seconds % 60)
}
