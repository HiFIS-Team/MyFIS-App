package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.components.MyFisSectionTitle
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisIconTile
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

// ── 모델 ──────────────────────────────────────────────
//
// **루틴과 출처가 다르다.** 루틴(처방)은 주 단위로 서버가 만들어 보내지만,
// 아래는 운동마다 한 번 쓰면 안 바뀌는 **카탈로그**다 (SPEC §7.7).
//
// - 그림 → WorkoutX API 🔵 아직 안 붙었다. 실물(배경·해상도)을 확인하고 붙인다
// - 글  → **우리가 쓴다.** WorkoutX 의 `instructions` 는 영어·독어·불어·중국어뿐이라
//         한국어가 없다 (SPEC §7.7, 열린 질문 17-2)

/** 운동 하나를 **배우는 데 필요한 것**. 세트·중량은 여기 없다 — 그건 W-01·W-04 몫이다 */
data class WorkoutGuide(
    /** `가슴 · 삼두` */
    val bodyPart: String,
    /** `스미스 머신` — 🔵 M-08 지도가 붙으면 이 값으로 기구를 띄운다 */
    val equipment: String,
    /** `2층 · 머신 구역` — 🔵 지금은 글자다. M-08 이 답할 자리 */
    val place: String,
    /** 번호를 매겨 읽는 짧은 문장들 */
    val steps: List<String>,
    /** 초보자가 다치는 지점 */
    val cautions: List<String>,
)

/**
 * TODO(콘텐츠): 운동 수만큼 쓴다. 지금은 W-01 자리 표시 여섯 개분만 있다.
 *
 * 문장은 **짧게, 시키는 말로** 쓴다 — 땀난 손으로 서서 읽는 글이다 (북극성).
 */
val workoutGuides: Map<Int, WorkoutGuide> = mapOf(
    1 to WorkoutGuide(
        bodyPart = "가슴 · 삼두",
        equipment = "스미스 머신",
        place = "2층 · 머신 구역",
        steps = listOf(
            "바가 가슴 한가운데 오도록 벤치 자리를 맞추고 눕는다",
            "어깨너비보다 조금 넓게 잡고, 바를 돌려 고리를 푼다",
            "가슴에 닿기 직전까지 두 셈에 걸쳐 내린다",
            "발로 바닥을 밀며 한 셈에 밀어 올린다",
        ),
        cautions = listOf(
            "허리를 과하게 젖히지 않는다. 엉덩이는 벤치에 붙인 채로 둔다",
            "팔꿈치를 몸과 직각으로 벌리면 어깨가 상한다. 45도쯤이 안전하다",
        ),
    ),
    2 to WorkoutGuide(
        bodyPart = "가슴 위쪽 · 어깨",
        equipment = "덤벨 · 인클라인 벤치",
        place = "2층 · 프리웨이트 구역",
        steps = listOf(
            "등받이를 30~45도로 세운다",
            "덤벨을 무릎에 올려 두고 반동으로 함께 눕는다",
            "가슴 위쪽이 늘어나는 데까지 내린다",
            "팔꿈치를 다 펴지 말고 살짝 남긴 채 멈춘다",
        ),
        cautions = listOf(
            "등받이를 60도 넘게 세우면 어깨 운동이 된다",
            "덤벨끼리 부딪히지 않는다. 힘이 위로 새어 나간다",
        ),
    ),
    3 to WorkoutGuide(
        bodyPart = "가슴",
        equipment = "체스트 프레스 머신",
        place = "2층 · 머신 구역",
        steps = listOf(
            "손잡이가 겨드랑이 높이에 오도록 의자를 맞춘다",
            "등과 어깨를 등받이에 붙이고 손잡이를 잡는다",
            "팔을 앞으로 밀며 가슴을 모은다",
            "손잡이가 몸에 닿기 직전까지 천천히 되돌린다",
        ),
        cautions = listOf(
            "어깨가 앞으로 말리면 가슴 대신 어깨가 쓰인다",
            "끝까지 되돌려 무게추를 내려놓지 않는다. 긴장이 풀린다",
        ),
    ),
    4 to WorkoutGuide(
        bodyPart = "가슴 안쪽",
        equipment = "케이블 머신",
        place = "2층 · 머신 구역",
        steps = listOf(
            "도르래를 어깨보다 높이 올리고 양쪽 손잡이를 잡는다",
            "한 발을 앞으로 내밀어 몸을 살짝 기울인다",
            "팔꿈치 각도를 그대로 두고 두 손을 배꼽 앞에서 모은다",
            "가슴이 늘어나는 데까지 천천히 벌린다",
        ),
        cautions = listOf(
            "팔꿈치를 폈다 굽혔다 하면 삼두 운동이 된다. 각도는 고정한다",
            "무게가 크면 몸이 끌려간다. 가볍게 들고 범위를 다 쓴다",
        ),
    ),
    5 to WorkoutGuide(
        bodyPart = "가슴 아래 · 삼두",
        equipment = "딥스 바",
        place = "3층 · 프리웨이트 구역",
        steps = listOf(
            "바를 잡고 팔을 펴 몸을 띄운다",
            "상체를 앞으로 살짝 기울인다",
            "팔꿈치가 직각이 될 때까지 내린다",
            "가슴으로 밀어 올린다",
        ),
        cautions = listOf(
            "어깨가 귀에 붙을 만큼 내려가면 어깨가 상한다",
            "힘들면 무릎을 받쳐 주는 보조 딥스 머신을 쓴다",
        ),
    ),
    6 to WorkoutGuide(
        bodyPart = "삼두",
        equipment = "케이블 머신",
        place = "2층 · 머신 구역",
        steps = listOf(
            "도르래를 가슴보다 높이 올리고 바를 어깨너비로 잡는다",
            "팔꿈치를 옆구리에 붙여 고정한다",
            "팔꿈치만 펴서 바를 허벅지 앞까지 내린다",
            "팔꿈치가 직각이 될 때까지 천천히 되돌린다",
        ),
        cautions = listOf(
            "팔꿈치가 앞뒤로 움직이면 등 운동이 섞인다",
            "상체를 숙여 체중으로 누르지 않는다",
        ),
    ),
)

// ── 화면 ──────────────────────────────────────────────

/**
 * SPEC.md W-03 **운동 상세** 🟡 틀 (DESIGN.md §6.36).
 *
 * **배우는 화면이다.** 읽고 닫으면 끝이고 아무것도 바꾸지 않는다 —
 * 레퍼런스에 있던 세트 편집·`삭제`·`대체` 를 전부 뺐다 (2026-09-06, 사용자 지정).
 * 분량은 AI 가 주 단위로 처방하므로 여기서 고치면 그 전제가 무너진다.
 *
 * **아직 껍데기다** — 시연 그림은 WorkoutX(SPEC §7.7)가 붙을 자리를 비워 뒀고,
 * 사용법·주의는 여섯 개분만 손으로 써 뒀다.
 */
@Composable
fun WorkoutDetailScreen(
    exercise: RoutineExercise,
    onBack: () -> Unit,
) {
    val guide = workoutGuides[exercise.id]

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding()
            .navigationBarsPadding(),
    ) {
        // 제목을 본문에서 크게 다루므로 헤더는 비운다 (§6.21 상품 상세와 같다)
        DetailHeader(title = null, onBack = onBack)

        Column(
            Modifier
                .verticalScroll(rememberScrollState())
                .padding(bottom = MyFisSpacing.sectionGap),
        ) {
            Column(Modifier.padding(horizontal = MyFisSpacing.screenHorizontal)) {
                Text(
                    exercise.name,
                    style = MyFisTheme.type.titleLg,
                    color = MyFisColor.TextPrimary,
                )
                if (guide != null) {
                    Text(
                        guide.bodyPart,
                        style = MyFisTheme.type.bodySm,
                        color = MyFisColor.TextSecondary,
                        modifier = Modifier.padding(top = MyFisSpacing.xs),
                    )
                }
            }

            DemoImage(Modifier.padding(top = MyFisSpacing.lg))

            // §6.10 — 세 상태를 세트로 둔다. 🔵 로딩(스켈레톤)·에러는 서버가 붙을 때
            if (guide == null) {
                GuideEmpty(Modifier.padding(top = MyFisSpacing.sectionGap))
                return@Column
            }

            EquipmentCard(
                gear = exercise.gear,
                guide = guide,
                modifier = Modifier
                    .padding(horizontal = MyFisSpacing.screenHorizontal)
                    .padding(top = MyFisSpacing.lg),
            )

            MyFisSectionTitle(
                "사용법",
                Modifier
                    .padding(horizontal = MyFisSpacing.screenHorizontal)
                    .padding(top = MyFisSpacing.sectionGap),
            )
            Column(
                modifier = Modifier
                    .padding(horizontal = MyFisSpacing.screenHorizontal)
                    .padding(top = MyFisSpacing.md),
                verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
            ) {
                guide.steps.forEachIndexed { index, step -> StepRow(index + 1, step) }
            }

            if (guide.cautions.isNotEmpty()) {
                MyFisSectionTitle(
                    "주의할 점",
                    Modifier
                        .padding(horizontal = MyFisSpacing.screenHorizontal)
                        .padding(top = MyFisSpacing.sectionGap),
                )
                CautionCard(
                    guide.cautions,
                    Modifier
                        .padding(horizontal = MyFisSpacing.screenHorizontal)
                        .padding(top = MyFisSpacing.md),
                )
            }
        }
    }
}

/**
 * 시연 그림 자리 — **정사각 · 화면 폭**. 상품 상세(§6.21)와 같은 자리 표시다.
 *
 * TODO(WorkoutX): `gifUrl` 을 여기에 건다 (SPEC §7.7).
 * ⚠️ 그림 배경이 **흰색**일 수 있다 (열린 질문 17-1). 그러면 다크 화면에 흰 정사각형이
 * 그대로 뜨므로, 실물을 본 뒤에 이 칸의 면 처리를 다시 정한다
 */
@Composable
private fun DemoImage(modifier: Modifier = Modifier) {
    Box(
        modifier
            .fillMaxWidth()
            .aspectRatio(1f)
            .background(MyFisColor.Surface2),
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
 * 이 운동에 쓰는 기구 — 타일 + 이름 + 어디 있나.
 *
 * TODO(M-08): 누르면 기구 지도에서 이 기구를 띄운다. **지금은 꺾쇠를 달지 않는다** —
 * 갈 곳이 없는 `›` 는 눌러도 아무 일이 없다 (§6.21 "이동 있는 줄만 ›")
 */
@Composable
private fun EquipmentCard(gear: RoutineGear, guide: WorkoutGuide, modifier: Modifier = Modifier) {
    MyFisCard(modifier) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            MyFisIconTile {
                Icon(
                    painter = painterResource(gear.icon),
                    contentDescription = null,
                    tint = MyFisColor.TextSecondary,
                    modifier = Modifier.size(24.dp),
                )
            }
            Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs)) {
                Text(guide.equipment, style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
                Text(guide.place, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
            }
        }
    }
}

/** 섹션 제목 — `title.md` (§4.2) */

/**
 * 사용법 한 줄. 번호는 **동그라미를 그리지 않는다** — 순서 변경 모드(§6.33)의 번호와
 * 같은 처리다. 새 물건을 만들 이유가 없다 (§8)
 */
@Composable
private fun StepRow(number: Int, text: String) {
    Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
        Text(
            "$number",
            style = MyFisTheme.type.body,
            color = MyFisColor.TextTertiary,
            textAlign = TextAlign.Center,
            modifier = Modifier.width(20.dp),
        )
        Text(text, style = MyFisTheme.type.body, color = MyFisColor.TextPrimary)
    }
}

/**
 * 주의할 점 — **카드에 담는다.** 배경 위에 그냥 두면 사용법의 이어지는 줄로 읽힌다.
 * 색을 쓰지 않는다 (§3.2) — 위계는 표면 밝기가 세운다 (§5.4)
 */
@Composable
private fun CautionCard(cautions: List<String>, modifier: Modifier = Modifier) {
    MyFisCard(modifier) {
        Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
            cautions.forEach { caution ->
                Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
                    Box(
                        Modifier
                            .padding(top = MyFisSpacing.sm)
                            .size(4.dp)
                            .background(MyFisColor.TextTertiary, MyFisRadius.full),
                    )
                    Text(caution, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
                }
            }
        }
    }
}

/** 아직 글을 못 쓴 운동 (§6.10 빈 상태) — 한 줄 설명만 두고 액션은 두지 않는다 */
@Composable
private fun GuideEmpty(modifier: Modifier = Modifier) {
    Text(
        "사용법을 준비하고 있어요",
        style = MyFisTheme.type.body,
        color = MyFisColor.TextTertiary,
        textAlign = TextAlign.Center,
        modifier = modifier.fillMaxWidth().padding(horizontal = MyFisSpacing.screenHorizontal),
    )
}
