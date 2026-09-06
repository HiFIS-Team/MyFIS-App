package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisIconTile
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSecondaryButton
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSmallButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics
import kotlinx.coroutines.delay

// ── 모델 ──────────────────────────────────────────────

/** 세션의 두 마디 — 웜업은 **시간**으로, 운동은 **분량**으로 센다 */
enum class SessionStage { WARMUP, WORKOUT }

/**
 * 세션의 한 단계.
 *
 * 웜업이면 [seconds] 가, 운동이면 [exercise] 가 찬다. 둘 다 차는 일은 없다.
 */
data class SessionStep(
    val title: String,
    val stage: SessionStage,
    val seconds: Int? = null,
    val exercise: RoutineExercise? = null,
)

/** 웜업 한 개에 주는 시간 — 다섯 개로 [ROUTINE_WARMUP_MINUTES] 분이 된다 */
private val warmupSeconds = ROUTINE_WARMUP_MINUTES * 60 / routineWarmupPlaceholder.size

/**
 * TODO(서버): 루틴 API 가 붙으면 이 순서를 받아온다.
 *
 * **W-01 과 같은 목록을 쓴다** — 웜업 다섯 개가 먼저고 그다음이 운동이다 (금지 6).
 */
val workoutSessionSteps: List<SessionStep> =
    routineWarmupPlaceholder.map {
        SessionStep(it, SessionStage.WARMUP, seconds = warmupSeconds)
    } + routineExercisesPlaceholder.map {
        SessionStep(it.name, SessionStage.WORKOUT, exercise = it)
    }

private fun mmss(seconds: Int): String = "%02d:%02d".format(seconds / 60, seconds % 60)

// ── 화면 ──────────────────────────────────────────────

/**
 * SPEC.md W-04 **운동 세션** 🟡 틀 (DESIGN.md §6.37).
 *
 * 레퍼런스는 사용자가 준 다른 앱의 세션 화면이다 — **재생기**다.
 * 위에서 아래로 *지금 뭘 하나 · 어떻게 하나 · 얼마나 남았나 · 다음은 뭔가 · 조작*.
 *
 * **원본에서 뺀 것**
 * - 위쪽 `⏸` — 아래 재생 버튼과 **같은 일을 두 번** 말한다. 조작은 아래 한 줄이 다 맡는다
 * - 톱니(설정) — 갈 곳이 없다. 갈 곳이 생기면 그때 단다
 * - 민트 점 · 민트 `다음 운동` 라벨 — 원본은 색이 다섯 곳이다. 우리는 **재생 버튼 하나**뿐이다 (§3.2)
 *
 * ⚠️ **연출을 넣지 않는다** (ui-design 스킬) — 운동 중 화면은 북극성과 충돌한다.
 */
@Composable
fun WorkoutSessionScreen(
    onExit: () -> Unit,
    /** 마지막 단계를 넘기면 — TODO(W-05): 완료 화면으로 간다 */
    onFinish: () -> Unit = onExit,
) {
    val steps = workoutSessionSteps
    var index by remember { mutableStateOf(0) }
    var remain by remember { mutableStateOf(steps[0].seconds ?: 0) }
    var elapsed by remember { mutableStateOf(0) }
    var playing by remember { mutableStateOf(true) }
    // TODO(W-04): 음성 렙 카운트가 붙으면 이 스위치가 그걸 끈다
    var voice by remember { mutableStateOf(true) }

    val step = steps[index]
    val next = steps.getOrNull(index + 1)

    fun moveTo(target: Int) {
        if (target > steps.lastIndex) {
            onFinish()
            return
        }
        val safe = target.coerceAtLeast(0)
        index = safe
        remain = steps[safe].seconds ?: 0
    }

    // **세트 사이에 화면이 꺼지면 매번 깨워야 한다** (SPEC W 공통 규칙)
    val view = LocalView.current
    DisposableEffect(Unit) {
        view.keepScreenOn = true
        onDispose { view.keepScreenOn = false }
    }

    // 재생 중일 때만 흐른다. 웜업은 남은 시간이 0 이 되면 **스스로 넘어간다**
    LaunchedEffect(playing, index) {
        while (playing) {
            delay(1000)
            elapsed += 1
            if (steps[index].seconds != null) {
                if (remain > 1) remain -= 1 else moveTo(index + 1)
            }
        }
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding()
            .navigationBarsPadding(),
    ) {
        SessionHeader(
            elapsed = elapsed,
            voice = voice,
            onVoice = { voice = !voice },
            onExit = onExit,
        )

        Column(
            Modifier
                .weight(1f)
                .padding(horizontal = MyFisSpacing.screenHorizontal),
        ) {
            Text(
                stageLabel(steps, index),
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
            )
            Text(
                step.title,
                style = MyFisTheme.type.titleLg,
                color = MyFisColor.TextPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(top = MyFisSpacing.xs),
            )

            // 시연 그림은 **남는 자리를 다 쓴다.** 이 화면은 스크롤하지 않는다 —
            // 운동 중에는 손이 젖어 있고, 필요한 것이 전부 한 판에 있어야 한다
            DemoStage(Modifier.weight(1f).padding(top = MyFisSpacing.lg))

            // 자리를 **늘 잡아 둔다.** 웜업이 끝날 때 버튼만 사라지면 아래가 통째로 들썩인다
            Box(
                Modifier
                    .fillMaxWidth()
                    .padding(top = MyFisSpacing.md)
                    .height(MyFisSize.chip),
                contentAlignment = Alignment.CenterEnd,
            ) {
                if (step.stage == SessionStage.WARMUP) {
                    MyFisSmallButton(
                        text = "웜업 생략",
                        onClick = { moveTo(routineWarmupPlaceholder.size) },
                    )
                }
            }

            StepPanel(step, remain, Modifier.padding(top = MyFisSpacing.lg))
            NextCard(next, Modifier.padding(top = MyFisSpacing.lg))
        }

        Controls(
            playing = playing,
            onPlay = { playing = !playing },
            onPrev = { moveTo(index - 1) },
            onNext = { moveTo(index + 1) },
            modifier = Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.lg, bottom = MyFisSpacing.xxl),
        )
    }
}

/** `웜업 스트레칭 1 / 5` · `운동 2 / 6` — 지금 몇 번째인지 (마디 안에서 센다) */
private fun stageLabel(steps: List<SessionStep>, index: Int): String {
    val stage = steps[index].stage
    val within = steps.take(index + 1).count { it.stage == stage }
    val total = steps.count { it.stage == stage }
    val name = if (stage == SessionStage.WARMUP) "웜업 스트레칭" else "운동"
    return "$name $within / $total"
}

/**
 * `←` · **총 경과 시간** · 음성 가이드.
 *
 * 잎 화면이라 [com.myfis.app.ui.shell.DetailHeader] 를 쓰고 싶지만, 그건 *왼쪽 아이콘 ·
 * 가운데 제목 · 오른쪽 아이콘* 셋뿐이다. 여기는 **왼쪽 아이콘 옆에 숫자**가 붙는다 —
 * 높이(56)와 좌우 여백은 그대로 맞춰서 다른 잎과 줄이 어긋나지 않게 한다 (§6.9)
 */
@Composable
private fun SessionHeader(
    elapsed: Int,
    voice: Boolean,
    onVoice: () -> Unit,
    onExit: () -> Unit,
) {
    val back = remember { MutableInteractionSource() }
    val chip = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier.size(MyFisSize.minTouchTarget).tapWithHaptics(back, onExit),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_tab_back),
                contentDescription = "세션 나가기",
                tint = MyFisColor.TextPrimary,
                modifier = Modifier.size(24.dp),
            )
        }
        // 자릿수가 늘어도(`59:59` → `1:00:00`) 안 흔들려야 한다 — metric 은 tnum 이다
        Text(
            mmss(elapsed),
            style = MyFisTheme.type.metricMd,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(start = MyFisSpacing.sm),
        )

        Spacer(Modifier.weight(1f))

        // 끈 상태는 **색으로 죽인다** — 투명도를 쓰지 않는다 (§9 이탈 #2)
        Row(
            modifier = Modifier
                .height(MyFisSize.chip)
                .background(
                    if (voice) MyFisColor.Surface2 else MyFisColor.Surface1,
                    MyFisRadius.full,
                )
                .tapWithHaptics(chip, onVoice)
                .padding(horizontal = MyFisSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_session_voice),
                contentDescription = if (voice) "음성 가이드 끄기" else "음성 가이드 켜기",
                tint = if (voice) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                modifier = Modifier.size(18.dp),
            )
            Text(
                "음성 가이드",
                style = MyFisTheme.type.label,
                color = if (voice) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
            )
        }
    }
}

/**
 * 시연 그림 자리 — W-03(§6.36)과 **같은 자리 표시**다.
 *
 * TODO(WorkoutX): `gifUrl` 을 건다 (SPEC §7.7). ⚠️ 배경이 흰색일 수 있다 (열린 질문 17-1)
 */
@Composable
private fun DemoStage(modifier: Modifier = Modifier) {
    Box(
        modifier
            .fillMaxWidth()
            .background(MyFisColor.Surface2, MyFisRadius.lg),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_tab_weight),
            contentDescription = null,
            tint = MyFisColor.Surface3,
            modifier = Modifier.size(96.dp),
        )
    }
}

/**
 * 이 화면의 **1순위** (§2 원칙 1) — 웜업은 *남은 시간*, 운동은 *분량*이다.
 *
 * 마디마다 재는 것이 다르다. 웜업은 시간이 끝나면 저절로 넘어가고,
 * 운동은 몇 번을 드느냐가 전부라 시계가 할 말이 없다
 */
@Composable
private fun StepPanel(step: SessionStep, remain: Int, modifier: Modifier = Modifier) {
    // 숫자 카드(§6.3)와 같은 판이다 — 직접 그리지 않고 `MyFisCard` 를 쓴다 (금지 1)
    MyFisCard(modifier) {
        Box(
            Modifier.fillMaxWidth().padding(vertical = MyFisSpacing.xs),
            contentAlignment = Alignment.Center,
        ) {
            if (step.stage == SessionStage.WARMUP) {
                Text(mmss(remain), style = MyFisTheme.type.metricXl, color = MyFisColor.TextPrimary)
            } else {
                val exercise = step.exercise
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
                ) {
                    // 라벨 위 · 값 아래 — 숫자 카드(§6.3)와 같은 읽는 순서다
                    Text(
                        "${exercise?.sets ?: 0}세트",
                        style = MyFisTheme.type.label,
                        color = MyFisColor.TextSecondary,
                    )
                    Text(
                        listOfNotNull(exercise?.load, "${exercise?.reps ?: 0}회").joinToString(" × "),
                        style = MyFisTheme.type.metricLg,
                        color = MyFisColor.TextPrimary,
                    )
                }
            }
        }
    }
}

/** 다음에 뭐가 오는지. 마지막이면 **자리는 그대로 두고 말만 바꾼다** — 카드가 사라지면 아래가 튄다 */
@Composable
private fun NextCard(next: SessionStep?, modifier: Modifier = Modifier) {
    MyFisCard(modifier) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            MyFisIconTile(dimmed = next == null) {
                Icon(
                    painter = painterResource(
                        next?.exercise?.gear?.icon ?: RoutineGear.STRETCH.icon,
                    ),
                    contentDescription = null,
                    tint = MyFisColor.TextSecondary,
                    modifier = Modifier.size(24.dp),
                )
            }
            Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs)) {
                Text(
                    if (next == null) "마지막" else "다음",
                    style = MyFisTheme.type.label,
                    color = MyFisColor.TextSecondary,
                )
                Text(
                    next?.title ?: "이걸로 끝이에요",
                    style = MyFisTheme.type.titleSm,
                    color = MyFisColor.TextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }
}

/**
 * 조작 한 줄 — 이전 · 재생/일시정지 · 다음.
 *
 * **재생이 세션 전체를 멈춘다** (총 경과 시간과 웜업 시계가 같이 선다).
 * 원본은 이걸 위아래 두 곳에 뒀는데 같은 일을 두 번 말하는 것이라 아래로 모았다.
 *
 * 가운데만 Primary 다 — 이 화면에서 **액센트는 이 하나뿐**이다 (§3.2)
 */
@Composable
private fun Controls(
    playing: Boolean,
    onPlay: () -> Unit,
    onPrev: () -> Unit,
    onNext: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
        MyFisSecondaryButton(
            text = "이전",
            onClick = onPrev,
            tall = true,
            icon = R.drawable.ic_session_prev,
            modifier = Modifier.weight(1f),
        )
        MyFisPrimaryButton(
            text = if (playing) "일시정지" else "이어서 하기",
            onClick = onPlay,
            icon = if (playing) R.drawable.ic_session_pause else R.drawable.ic_session_play,
            modifier = Modifier.weight(1f),
        )
        MyFisSecondaryButton(
            text = "다음",
            onClick = onNext,
            tall = true,
            icon = R.drawable.ic_session_next,
            modifier = Modifier.weight(1f),
        )
    }
}
