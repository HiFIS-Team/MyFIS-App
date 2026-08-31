package com.myfis.app.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md P-05 물 마시기 (DESIGN.md §6.25 활동 화면).
 *
 * 레퍼런스는 **토스 `물 마시는 습관 만들기`** 다 (사용자 지정).
 * 짜임만 가져오고 표면은 우리 것으로 옮긴다 — 원본은 **라이트 + 민트·노랑·파랑**이지만
 * 우리는 다크 + 라임 하나다 (§9 이탈 #1 · §3.2).
 *
 * ⚠️ **양을 쌓는 화면이 아니라 시간 미션 화면이다.** 아침·점심·저녁 정해진 때에 한 번씩 —
 * 다음 때까지 남은 시간이 이 화면의 답이다.
 */
@Composable
fun WaterScreen(
    /** 걸려 있는 미션 시각 (시각 고르기에서 저장한 값) */
    times: Map<String, String> = waterDefaultTimes,
    onClose: () -> Unit = {},
    onChangeTime: () -> Unit = {},
) {
    Column(
        Modifier
            .fillMaxSize()
            // **흰 바탕** — 혜택과 그 활동 화면만 밝다 (§9 이탈 #1, 2026-08-28 개정)
            .background(MyFisColor.LightBgBase)
            // 잎 화면이라 상태바 자리를 비운다 — 없으면 헤더가 시계 위에 깔린다
            .statusBarsPadding()
            .navigationBarsPadding(),
    ) {
        // 다른 잎 화면과 **같은 뒤로가기**를 쓴다 (2026-08-28 사용자 지정).
        // 이 화면은 옆에서 밀려 들어오므로 `X`(덮개)보다 `←` 가 방향과 맞는다
        DetailHeader(title = "물 마시기", onBack = onClose, light = true)

        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(bottom = MyFisSpacing.xxxl),
        ) {
            Drop()

            // **배경 빛** (§9 이탈 #5, 2026-08-28 등재) — 평평한 검정 위에 글리프만 두면
            // 화면이 죽어 보인다. 랜딩이 빛을 까는 것과 같은 이유다.
            //
            // ⚠️ 덮는 자리는 **제목부터 카드까지**다. 물방울 위와 알림 줄 아래는 빛이 없다 —
            // 화면 전체에 깔면 띠가 아니라 그냥 다른 배경색이 된다.
            // ⚠️ 움직이지 않는다 — 기다리는 화면이라 숨쉬면 시선을 계속 끈다
            Column(
                Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.verticalGradient(
                            0f to Color.Transparent,
                            0.18f to MyFisColor.CategoryCyan.copy(alpha = 0.12f),
                            0.82f to MyFisColor.CategoryCyan.copy(alpha = 0.12f),
                            1f to Color.Transparent,
                        ),
                    )
                    .padding(bottom = MyFisSpacing.xl),
            ) {
                Head(onChangeTime)
                NextMission(times, modifier = Modifier.padding(top = MyFisSpacing.sectionGap))
            }

            AlarmRow(modifier = Modifier.padding(top = MyFisSpacing.cardGap))
            StreakCard(modifier = Modifier.padding(top = MyFisSpacing.cardGap))
        }

        // **하단 고정** (§2 원칙 2 · 5). 아직 때가 아니면 비활성이다 —
        // 비활성에 alpha 를 쓰지 않는다. 색 토큰을 바꾼다 (§9 이탈 #2, 버튼이 이미 그렇게 한다)
        Column(
            Modifier
                .background(MyFisColor.LightBgBase)
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(vertical = MyFisSpacing.md),
        ) {
            // TODO: 미션 시각이 되면 켠다 (SPEC P-05)
            MyFisPrimaryButton(
                "6시간 40분 뒤 마실 수 있어요",
                onClick = {},
                enabled = false,
                light = true,
                // 활동 화면의 Primary 는 **그 활동의 색**이다 (2026-08-28)
                fill = MyFisColor.LightAccentCyan,
                onFill = MyFisColor.LightBgBase,
            )
        }
    }
}

/**
 * 물방울 + 제목 + 남은 시간.
 *
 * **주인공은 글이다** — 원본과 같다. 이 화면은 아직 할 게 없는 상태로 열리므로
 * 숫자를 크게 둘 자리가 없다 (§2 원칙 1 의 예외를 여기 적어 둔다).
 */
@Composable
private fun Drop() {
    // 원색 벌이라 tint 하지 않는다 (§8) — 갈래 색(cyan)은 그림이 이미 들고 있다
    Image(
        painter = painterResource(R.drawable.ic_benefit_water_color),
        contentDescription = null, // 아래 제목이 이름 역할을 한다
        modifier = Modifier
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .padding(top = MyFisSpacing.sectionGap, bottom = MyFisSpacing.xl)
            .size(72.dp),
    )
}

@Composable
private fun Head(onChangeTime: () -> Unit) {
    Column(
        Modifier
            .fillMaxWidth()
            // **배경 빛** (§9 이탈 #5, 2026-08-28 등재) — 평평한 검정 위에 글리프만 두면
            // 화면이 죽어 보인다. 랜딩이 빛을 까는 것과 같은 이유다.
            //
            // ⚠️ 동그란 빛이 아니라 **화면 폭을 가로지르는 띠**다. 글리프 뒤에 원을 두면
            // 물건에 후광이 생겨 그림이 커 보이는데, 이 화면이 원하는 건 **바탕이 덜 평평한 것**이다.
            // ⚠️ 움직이지 않는다 — 기다리는 화면이라 숨쉬면 시선을 계속 끈다
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        // ⚠️ **한 줄로 둔다.** `display`(32) 로는 `물 마시는 습관을 / 만들어요` 로 깨져
        // 제목이 문장의 반 토막처럼 보였다 (2026-08-28). `title.lg`(24) 가 §4.2 의 "화면 제목" 이다
        Text(
            "물 마시는 습관을 만들어요",
            style = MyFisTheme.type.titleLg,
            color = MyFisColor.LightTextPrimary,
            maxLines = 1,
        )
        Text(
            "6시간 40분 뒤 참여할 수 있어요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.LightTextSecondary,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        TimeChip(onChangeTime, Modifier.padding(top = MyFisSpacing.xl))
    }
}

/** `시간 바꾸기` — 알약 칩 (§5.2 `size.chip`). 액센트를 쓰지 않는다 */
@Composable
private fun TimeChip(onClick: () -> Unit, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .height(MyFisSize.chip)
            .background(MyFisColor.LightSurface2, MyFisRadius.full)
            .tapWithHaptics(interaction, onClick)
            .padding(horizontal = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_header_notification),
            contentDescription = null,
            tint = MyFisColor.LightTextSecondary,
            modifier = Modifier.size(18.dp),
        )
        Text("시간 바꾸기", style = MyFisTheme.type.label, color = MyFisColor.LightTextPrimary)
    }
}

/**
 * 다음 미션 카드 — 안내 두 줄 + 세 때.
 *
 * 원본의 세 칸에는 이모지가 있지만 우리는 **시각을 주인공으로** 둔다 (§2 원칙 1).
 * 이모지를 우리 아이콘으로 바꾸면 아침·점심·저녁을 그릴 벌을 셋 새로 만들어야 하고,
 * 둥근 네모 안에 글자만 남으면 **꺼진 입력 칸처럼** 보인다 (§8)
 */
@Composable
private fun NextMission(times: Map<String, String>, modifier: Modifier = Modifier) {
    MyFisCard(modifier.padding(horizontal = MyFisSpacing.screenHorizontal), light = true) {
        Text(
            "다음 미션까지 6시간 40분 남았어요",
            style = MyFisTheme.type.body,
            color = MyFisColor.LightTextPrimary,
        )
        Text(
            "놓쳐도 다음 미션 전까지 다시 할 수 있어요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.LightTextTertiary,
            modifier = Modifier.padding(top = 2.dp),
        )
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.lg),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            MissionSlot("⛅", "아침", times["아침"].orEmpty(), Modifier.weight(1f))
            MissionSlot("🌞", "점심", times["점심"].orEmpty(), Modifier.weight(1f))
            MissionSlot("🌙", "저녁", times["저녁"].orEmpty(), Modifier.weight(1f))
        }
    }
}

/**
 * 때 한 칸 — 그림 · 이름 · 시각.
 *
 * 그림은 **이모지**다 (사용자 지정). 해·구름·달 벌을 셋 새로 그리는 대신 시스템 글꼴에 맡긴다 —
 * 둥근 네모 안에 글자만 남으면 **꺼진 입력 칸처럼** 보인다 (§8).
 * ⚠️ 크기는 `display`(32) 를 빌려 쓴다. 이모지에 날글꼴 크기를 주면 §4.2 토큰 밖이 된다
 */
@Composable
private fun MissionSlot(emoji: String, label: String, time: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .background(MyFisColor.LightSurface2, MyFisRadius.md)
            .padding(vertical = MyFisSpacing.lg),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(emoji, style = MyFisTheme.type.display)
        Text(
            label,
            style = MyFisTheme.type.titleSm,
            color = MyFisColor.LightTextPrimary,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        Text(
            time,
            style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.LightTextSecondary,
            modifier = Modifier.padding(top = 2.dp),
        )
    }
}

/**
 * `알림 켜고 +10 P 받기` — **이 화면의 라임 한 곳**이다.
 *
 * 판을 라임으로 채우지 않고 **테두리만** 두른다 — 채우면 위 카드보다 이 줄이 세진다
 * (§6.26 찾기 줄과 같은 판단). 하단 버튼은 지금 비활성이라 라임이 아니다
 */
@Composable
private fun AlarmRow(modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    // 판을 라임으로 **채우지 않고 테두리만** 두른다 — 채우면 위 카드보다 이 줄이 세진다 (§6.26).
    //
    // ⚠️ 흰 면에서 라임 테두리는 **밝기 대비가 1.27:1** 로 WCAG 비문자 기준(3:1) 밑이다.
    //    그래도 쓰는 이유는 채도가 높아 **색으로는 읽히고**, 이 테두리가 뜻을 나르는 게 아니라
    //    강조만 하기 때문이다 — 글자와 화살표가 정보를 다 지고 있다 (2026-08-28 확인)
    MyFisCard(
        modifier
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            // TODO: 알림 권한 요청 · 적립 (SPEC P-05)
            .tapWithHaptics(interaction) {}
            .border(1.5.dp, MyFisColor.LightAccentCyan, MyFisRadius.md),
        light = true,
    ) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Icon(
                painter = painterResource(R.drawable.ic_header_notification),
                contentDescription = null,
                tint = MyFisColor.LightTextPrimary,
                modifier = Modifier.size(24.dp),
            )
            Column(
                Modifier
                    .weight(1f)
                    .padding(start = MyFisSpacing.md),
            ) {
                Text("알림 켜고 +10 P 받기", style = MyFisTheme.type.body, color = MyFisColor.LightTextPrimary)
                Text(
                    "물 마실 시간을 알려드려요",
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.LightTextTertiary,
                    modifier = Modifier.padding(top = 2.dp),
                )
            }
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.LightTextTertiary,
                modifier = Modifier
                    .size(18.dp)
                    .graphicsLayer { rotationZ = -90f },
            )
        }
    }
}

/**
 * 7일 도장판 — **며칠째인지**를 보여 준다.
 *
 * ⚠️ 원본은 오늘 칸과 `n일차` 를 민트로 칠하지만 우리는 **표면 밝기로** 표시한다.
 * 이 화면의 라임은 위 `알림 켜고` 테두리 하나뿐이다 (§2 원칙 3 — 화면당 두 곳).
 * 시각 고르기(P-05)에서 고른 칩을 표시한 방법과 같다.
 */
@Composable
private fun StreakCard(modifier: Modifier = Modifier) {
    // TODO(서버): 며칠째인지 서버가 준다 (SPEC P-05)
    val day = 1

    MyFisCard(modifier.padding(horizontal = MyFisSpacing.screenHorizontal), light = true) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                "7일 성공하면 보상을 드려요",
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.LightTextPrimary,
                modifier = Modifier.weight(1f),
            )
            Text(
                "${day}일차",
                style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.LightTextPrimary,
            )
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.lg),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // 앞 여섯 칸은 날짜, 마지막 한 칸은 **선물**이다 — 일곱 번째 날이 아니라 보상 자리다
            (1..6).forEach { n -> DayDot(label = "$n", reached = n <= day) }
            DayDot(label = "🎁", reached = false)
        }

        Text(
            "하루 2번 이상 마시면 1일 성공이에요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.LightTextTertiary,
            modifier = Modifier.padding(top = MyFisSpacing.md),
        )
    }
}

/** 도장 한 칸. 지나온 날은 판을 한 단계 올리고 테두리를 두른다 (§5.4) */
@Composable
private fun DayDot(label: String, reached: Boolean) {
    Box(
        modifier = Modifier
            .size(MyFisSize.chip)
            .background(
                if (reached) MyFisColor.LightSurface3 else MyFisColor.LightSurface2,
                MyFisRadius.full,
            )
            .border(
                width = if (reached) 1.5.dp else 1.dp,
                // 지나온 칸은 **라임 테두리**. 칠은 그대로 둔다 — 채우면 일곱 칸이 시끄럽다
                color = if (reached) MyFisColor.LightAccentCyan else Color.Transparent,
                shape = MyFisRadius.full,
            ),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = MyFisTheme.type.body.copy(fontFeatureSettings = "tnum"),
            color = if (reached) MyFisColor.LightTextPrimary else MyFisColor.LightTextTertiary,
        )
    }
}
