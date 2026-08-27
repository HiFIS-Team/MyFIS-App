package com.myfis.app.ui.screens

import androidx.compose.animation.core.animate
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTransformGestures
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
import androidx.compose.material3.BottomSheetScaffold
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.SheetValue
import androidx.compose.material3.Text
import androidx.compose.material3.rememberBottomSheetScaffoldState
import androidx.compose.material3.rememberStandardBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics
import kotlinx.coroutines.launch

/**
 * 홈 헤더의 **핀으로 들어오는 잎 화면** (SPEC M-08 지점 내부 지도).
 *
 * 짜임은 **지도 앱 방식**이다 🟢 (2026-08-27) — 평면도가 화면을 채우고,
 * 찾기 줄은 그 위에 뜨고, 고르는 것들은 **바닥 시트** 안으로 들어간다.
 *
 * ⚠️ 다만 **헤더 밑에서 시작한다.** 네이버·카카오맵이 지도를 끝까지 까는 건 그 화면에
 * **헤더가 없기** 때문이다 — 떠 있는 단추만 있다. 우리는 제목이 있는 진짜 헤더를 쓰는데,
 * 제목을 움직이는 배경 위에 올리려면 그늘을 그만큼 진하게 깔아야 하고
 * **그럴 거면 이미 불투명한 바**다. 떠 있어야 하는 건 헤더가 아니라 **찾기 줄**이다.
 *
 * ⚠️ 처음엔 위에서부터 찾기 줄 → 빠른 고르기 → 자주 쓰는 기구 → 지도로 쌓았는데,
 * 그러면 지도에 **280dp** 밖에 안 남았다. 이 화면의 북극성은 "쉬는 시간 20초 안에"인데
 * 지도를 보려고 스크롤해야 하면 그 자체로 실패다 (SPEC M-08).
 *
 * 시트는 **`BottomSheetScaffold`** 다 — 끌기 · 멈춤 · 그림자를 플랫폼이 준다 (§2 원칙 6).
 *
 * ⚠️ 잎 화면은 셸 밖이라 **바탕색과 상태바 여백을 스스로 넣는다.**
 * 바탕이 없으면 밀려 들어오는 동안 뒤 화면이 비쳐 겹쳐 보이고, 여백이 없으면 헤더가 시계에 겹친다.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BranchScreen(onBack: () -> Unit = {}) {
    val state = rememberBottomSheetScaffoldState(
        bottomSheetState = rememberStandardBottomSheetState(
            initialValue = SheetValue.PartiallyExpanded,
            // 접힌 자리로 못 내려가게 막는다 — 내려가면 지도만 남고 고를 데가 사라진다
            skipHiddenState = true,
        ),
    )

    BottomSheetScaffold(
        scaffoldState = state,
        // 접혔을 때 **빠른 고르기 두 줄이 다 보인다.** 한 줄만 보이게 하면 나머지 넷이
        // 있는 줄 모르고, 더 올리면 지도가 반으로 줄어든다 (손잡이 + 두 줄 + 바닥 여백)
        sheetPeekHeight = 264.dp,
        sheetContainerColor = MyFisColor.Surface1,
        sheetContentColor = MyFisColor.TextPrimary,
        sheetShape = MyFisRadius.sheet,
        sheetShadowElevation = 0.dp,
        containerColor = MyFisColor.BgBase,
        sheetContent = {
            Column(
                Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = MyFisSpacing.screenHorizontal)
                    .padding(bottom = MyFisSpacing.xxxl)
                    .navigationBarsPadding(),
                verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xxl),
            ) {
                PlaceQuickPick()
                FavoriteMachines()
            }
        },
    ) {
        Column(
            Modifier
                .fillMaxSize()
                .background(MyFisColor.BgBase)
                .statusBarsPadding(),
        ) {
            // 헤더는 **불투명한 바**다. 지도가 밑에서 시작한다
            DetailHeader(title = "기구 찾기", onBack = onBack)

            Box(Modifier.fillMaxSize()) {
                // 평면도가 **바탕**이다. 찾기 줄과 시트가 이 위에 얹힌다
                BranchMap(bottomInset = 264.dp)

                // 찾기 줄만 **떠 있다.** 자기 판(`surface.1`)과 라임 테두리가 있어
                // 그늘 없이도 지도 위에서 읽힌다
                BranchSearchBar(
                    Modifier
                        .padding(horizontal = MyFisSpacing.screenHorizontal)
                        .padding(top = MyFisSpacing.sm),
                )
            }
        }
    }
}

/**
 * 평면도 — **화면의 바탕**. 확대 · 이동만 되고 돌리지는 않는다 (SPEC M-08).
 *
 * 처음엔 **화면을 꽉 채운다** 🟢 (2026-08-27 수정). 폭에만 맞췄더니 도면이 화면 가운데
 * 떠 있는 그림처럼 보였다 — 지도 앱은 화면에 빈 데가 없고, 보고 싶은 데로 밀어서 간다.
 *
 * - 처음 배율 = **덮기**(가로 · 세로 중 큰 쪽에 맞춤). 화면에 빈 데가 안 생긴다
 * - 가장 작게 = **전부 보기**. 한 번 오므리면 헬스장 전체가 들어온다
 * - 민 거리는 **가장자리에서 멈춘다.** 안 막으면 도면이 화면 밖으로 사라진다
 *
 * @param bottomInset 시트에 가려지는 높이. **가려질 자리를 빼고 채운다**
 */
@Composable
private fun BranchMap(bottomInset: Dp) {
    val measurer = rememberTextMeasurer()
    val density = LocalDensity.current
    // 0 은 아직 못 정했다는 뜻이다 — 화면 크기를 알아야 정할 수 있다
    var zoom by remember { mutableFloatStateOf(0f) }
    var offset by remember { mutableStateOf(Offset.Zero) }
    // 전부 보고 있는 중인지. 버튼 글자가 이걸 따라 바뀐다
    var showingAll by remember { mutableStateOf(false) }
    // 화면 크기를 그릴 때 알게 되므로, 단추가 쓸 수 있게 받아 둔다
    var fitScale by remember { mutableFloatStateOf(0f) }
    var coverScale by remember { mutableFloatStateOf(0f) }
    val scope = rememberCoroutineScope()
    val interaction = remember { MutableInteractionSource() }

    val zoneTint = MyFisColor.run {
        mapOf(
            PlanTint.GREEN to CategoryGreen, PlanTint.TEAL to CategoryTeal,
            PlanTint.VIOLET to CategoryViolet, PlanTint.BLUE to CategoryBlue,
            PlanTint.ORANGE to CategoryOrange, PlanTint.GOLD to CategoryGold,
            PlanTint.PINK to CategoryPink, PlanTint.GRAY to CategoryGray,
        )
    }
    val toneColor = mapOf(
        PlanTone.BODY to MyFisColor.BorderStrong,
        PlanTone.CAP to MyFisColor.TextSecondary,
        PlanTone.PILLAR to MyFisColor.Surface3,
        PlanTone.PLANT to MyFisColor.CategoryGreen,
    )
    val insetPx = with(density) { bottomInset.toPx() }
    val marginPx = with(density) { MyFisSpacing.xxl.toPx() }

    Box(Modifier.fillMaxSize()) {
    Canvas(
        Modifier
            .fillMaxSize()
            .clipToBounds()
            .pointerInput(Unit) {
                detectTransformGestures { _, pan, gestureZoom, _ ->
                    val visibleW = size.width.toFloat()
                    val visibleH = (size.height - insetPx).coerceAtLeast(1f)
                    val fit = minOf(
                        (visibleW - marginPx * 2) / BranchFloorPlan.WIDTH,
                        (visibleH - marginPx * 2) / BranchFloorPlan.HEIGHT,
                    )
                    val cover = maxOf(
                        visibleW / BranchFloorPlan.WIDTH,
                        visibleH / BranchFloorPlan.HEIGHT,
                    )
                    val next = ((if (zoom > 0f) zoom else cover) * gestureZoom)
                        .coerceIn(fit, cover * 2.5f)
                    zoom = next
                    showingAll = next <= fit * 1.05f
                    // 민 거리를 **가장자리 안**으로 되돌린다.
                    // 도면이 화면보다 작으면 가운데에 못 박는다
                    val slackX =
                        ((BranchFloorPlan.WIDTH * next - visibleW) / 2).coerceAtLeast(0f)
                    val slackY =
                        ((BranchFloorPlan.HEIGHT * next - visibleH) / 2).coerceAtLeast(0f)
                    offset = Offset(
                        (offset.x + pan.x).coerceIn(-slackX, slackX),
                        (offset.y + pan.y).coerceIn(-slackY, slackY),
                    )
                }
            },
    ) {
        val visibleW = size.width
        val visibleH = (size.height - insetPx).coerceAtLeast(1f)
        val cover = maxOf(visibleW / BranchFloorPlan.WIDTH, visibleH / BranchFloorPlan.HEIGHT)
        coverScale = cover
        fitScale = minOf(
            (visibleW - marginPx * 2) / BranchFloorPlan.WIDTH,
            (visibleH - marginPx * 2) / BranchFloorPlan.HEIGHT,
        )
        val s = if (zoom > 0f) zoom else cover
        val originX = (visibleW - BranchFloorPlan.WIDTH * s) / 2 + offset.x
        val originY = (visibleH - BranchFloorPlan.HEIGHT * s) / 2 + offset.y

        fun px(x: Float, y: Float) = Offset(originX + x * s, originY + y * s)
        fun box(x: Float, y: Float, w: Float, h: Float) = px(x, y) to Size(w * s, h * s)

        // ⓪ 바닥 결 — **오므려서 도면이 작아졌을 때 화면이 비지 않게** 한다.
        // 지도 앱의 바깥은 빈 검정이 아니라 늘 뭔가 깔려 있다
        val step = 20 * s
        if (step > 6f) {
            var x = originX.mod(step)
            while (x < size.width) {
                drawLine(MyFisColor.Surface1, Offset(x, 0f), Offset(x, size.height), 1f)
                x += step
            }
            var y = originY.mod(step)
            while (y < size.height) {
                drawLine(MyFisColor.Surface1, Offset(0f, y), Offset(size.width, y), 1f)
                y += step
            }
        }

        // ① 바닥 — **벽 모양 그대로** 칠한다. 네모로 칠하면 꺾인 구석 밖까지 바닥이 나온다
        val shell = Path().apply {
            BranchFloorPlan.outline.forEachIndexed { index, (x, y) ->
                val p = px(x, y)
                if (index == 0) moveTo(p.x, p.y) else lineTo(p.x, p.y)
            }
        }
        drawPath(Path().apply { addPath(shell); close() }, MyFisColor.Surface1)

        // ② 구역 — 옅게 칠하고 테두리를 한 겹
        BranchFloorPlan.zones.forEach { zone ->
            val tint = zoneTint.getValue(zone.tint)
            val (at, boxSize) = box(zone.x, zone.y, zone.w, zone.h)
            val radius = CornerRadius(5 * s, 5 * s)
            drawRoundRect(tint.copy(alpha = 0.14f), at, boxSize, radius)
            drawRoundRect(tint.copy(alpha = 0.45f), at, boxSize, radius, Stroke(1f))
        }

        // ③ 방 — 구역과 달리 **벽으로 막힌 곳**이라 테두리를 진하게 두른다
        BranchFloorPlan.rooms.forEach { room ->
            val tint = zoneTint.getValue(room.tint)
            val (at, boxSize) = box(room.x, room.y, room.w, room.h)
            val radius = CornerRadius(2 * s, 2 * s)
            drawRoundRect(tint.copy(alpha = 0.12f), at, boxSize, radius)
            drawRoundRect(MyFisColor.BorderSubtle, at, boxSize, radius, Stroke(1f))
        }

        // ④ 물건
        BranchFloorPlan.items.forEach { item ->
            val (at, boxSize) = box(item.x, item.y, item.w, item.h)
            drawRoundRect(
                toneColor.getValue(item.tone), at, boxSize,
                CornerRadius(item.radius * s, item.radius * s),
            )
        }

        // ⑤ 바깥 벽 — 물건 위에 그린다. 밑에 깔면 기둥에 먹힌다
        drawPath(
            shell, MyFisColor.BorderStrong,
            style = Stroke(2.5f * s, cap = StrokeCap.Round, join = StrokeJoin.Round),
        )

        // ⑥ 글자
        BranchFloorPlan.zones.forEach { zone ->
            planLabel(measurer, density, zone.title, px(zone.x + zone.w / 2, zone.y + 4),
                10 * s, zoneTint.getValue(zone.tint))
        }
        BranchFloorPlan.rooms.forEach { room ->
            planLabel(measurer, density, room.title,
                px(room.x + room.w / 2, room.y + room.h / 2 - 9), 8 * s,
                MyFisColor.TextSecondary)
        }

        // ⑦ 출입구 — **이름만 둔다.** 벽이 끊긴 자리가 이미 문이라 핀까지 세우면
        // 바로 위 `내 위치` 와 표시가 둘이 되어 어느 쪽이 나인지 헷갈린다
        val ex = BranchFloorPlan.ENTRANCE_X
        val ey = BranchFloorPlan.ENTRANCE_Y
        planLabel(measurer, density, "출입구", px(ex, ey + 6), 8 * s, MyFisColor.TextSecondary)

        // ⑧ 내 자리 — **화면에서 제일 먼저 찾아야 하는 점**이라 라임은 여기 쓴다 (§3.2).
        // 지도 앱의 파란 점과 같은 짜임 — 번짐 · 테두리 · 알맹이 세 겹이라야 배경에서 뜬다
        val mx = BranchFloorPlan.MY_X
        val my = BranchFloorPlan.MY_Y
        drawCircle(MyFisColor.Accent.copy(alpha = 0.18f), 12 * s, px(mx, my))
        drawCircle(MyFisColor.BgBase, 6 * s, px(mx, my))
        drawCircle(MyFisColor.Accent, 4.6f * s, px(mx, my))
        planLabel(measurer, density, "내 위치", px(mx, my - 20), 8 * s, MyFisColor.Accent)
    }

    // 꽉 채우면 헬스장 **전체가 안 보인다.** 한 번에 되돌아올 길을 둔다 —
    // 지도 앱이 `현위치` 단추를 띄워 두는 것과 같은 자리다
    Text(
        if (showingAll) "채우기" else "전체 보기",
        style = MyFisTheme.type.label,
        color = MyFisColor.TextPrimary,
        modifier = Modifier
            .align(Alignment.BottomEnd)
            .padding(end = MyFisSpacing.screenHorizontal, bottom = bottomInset + MyFisSpacing.lg)
            .background(MyFisColor.Surface2, MyFisRadius.full)
            .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.full)
            .tapWithHaptics(interaction) {
                val target = if (showingAll) coverScale else fitScale
                if (target <= 0f) return@tapWithHaptics
                showingAll = !showingAll
                offset = Offset.Zero
                val from = if (zoom > 0f) zoom else coverScale
                scope.launch {
                    animate(from, target, animationSpec = tween(320)) { value, _ -> zoom = value }
                }
            }
            .padding(horizontal = MyFisSpacing.md, vertical = MyFisSpacing.sm),
    )
    }
}

/**
 * 지도 글자. **가로 가운데**에 맞춰 그린다.
 *
 * ⚠️ 지도 글자는 §4.2 스케일 밖이다 — 확대하면 같이 커지므로 크기를 고정할 수 없다.
 * 너무 작아지면 얼룩이 되므로 아예 안 그린다.
 */
private fun DrawScope.planLabel(
    measurer: TextMeasurer,
    density: Density,
    text: String,
    at: Offset,
    sizePx: Float,
    color: Color,
) {
    if (sizePx < 7f) return
    val style = TextStyle(
        color = color,
        fontSize = with(density) { sizePx.toSp() },
        fontWeight = FontWeight.SemiBold,
        textAlign = TextAlign.Center,
        lineHeight = with(density) { (sizePx * 1.25f).toSp() },
    )
    val laid = measurer.measure(AnnotatedString(text), style)
    drawText(laid, topLeft = Offset(at.x - laid.size.width / 2f, at.y))
}

/**
 * 찾기 줄 — **이 화면에서 제일 먼저 눈에 들어와야 하는 것**이라 테두리를 라임으로 두른다.
 *
 * 판을 라임으로 채우지 않는다. 채우면 밑에 올 지도보다 이 줄이 더 세진다 (§3.2 액센트 예산).
 */
@Composable
private fun BranchSearchBar(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(MyFisSize.searchBar)
            .background(MyFisColor.Surface1, MyFisRadius.lg)
            .border(1.5.dp, MyFisColor.Accent, MyFisRadius.lg)
            .padding(horizontal = MyFisSpacing.lg),
        contentAlignment = Alignment.CenterStart,
    ) {
        // TODO: 누르면 기구 검색으로 (M-08). 지금은 자리만 잡는다
        // 물음이 **이 줄의 제목**이라 흐리게 두지 않는다. tertiary 로 두면 꺼진 칸처럼 보인다
        Text(
            "어떤 기구 찾으세요?",
            style = MyFisTheme.type.titleMd,
            color = MyFisColor.TextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

/**
 * 빠른 고르기 여덟 칸 (DESIGN §6.26).
 *
 * **구역**이지 기구 낱개가 아니다 🟢 (2026-08-27). 기구 하나하나는 위 **찾기 줄**이 맡고,
 * 이 판은 지도의 **구역과 1:1** 로 맞춘다 — 스쿼트랙 · 벤치 · 덤벨은 셋 다 프리웨이트존 안이라
 * 나란히 놓을 것이 아니었다. 앞 넷은 운동 구역, 뒤 넷은 편의시설이다.
 */
private enum class BranchPlace(val icon: Int, val title: String) {
    FREE(R.drawable.ic_place_free, "프리웨이트"),
    MACHINE(R.drawable.ic_place_machine, "머신"),
    CARDIO(R.drawable.ic_place_cardio, "유산소"),
    STRETCH(R.drawable.ic_place_stretch, "스트레칭"),
    TOILET(R.drawable.ic_place_toilet, "화장실"),
    SHOWER(R.drawable.ic_place_shower, "샤워실"),
    FITTING(R.drawable.ic_place_fitting, "탈의실"),
    DESK(R.drawable.ic_place_desk, "데스크"),
}

/**
 * **네 칸 × 두 줄.** 한 줄에 다섯을 넣으면 라벨(`프리웨이트`)이 줄어들고,
 * 셋으로 줄이면 판이 커져 밑에 올 지도를 밀어낸다.
 *
 * 여덟 칸뿐이라 `LazyVerticalGrid` 를 쓰지 않는다 — 세로 스크롤이 둘이 되면 지도와 부딪힌다.
 */
@Composable
private fun PlaceQuickPick(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.fillMaxWidth(),
        // 줄 사이는 16 이다. 칸 사이(12)보다 넓어야 라벨이 아래 판에 붙지 않는다
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
    ) {
        BranchPlace.entries.chunked(4).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
                row.forEach { PlaceCell(it.icon, it.title, Modifier.weight(1f)) }
            }
        }
    }
}

/**
 * 아이콘 판 + 라벨. 판의 짜임은 **혜택 행과 같다** (§6.23) — 같은 물건은 같게 그린다.
 *
 * 아이콘은 **여덟이 전부 원색**이라 tint 를 걸지 않는다 (§8).
 * 라임은 안 쓴다 — 이 화면의 액센트는 찾기 줄 테두리 하나다 (§3.2 액센트 예산).
 */
@Composable
private fun PlaceCell(icon: Int, title: String, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        // TODO: 누르면 그 갈래를 지도에서 집는다 (M-08)
        modifier = modifier.tapWithHaptics(interaction) {},
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Box(
            Modifier
                .size(MyFisSize.listRowMin)
                .background(MyFisColor.Surface2, MyFisRadius.tile)
                .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.tile),
            contentAlignment = Alignment.Center,
        ) {
            // ⚠️ 원색 벌은 **`Image`** 로 그린다 — `Icon` 은 tint 로 한 색을 덮어씌운다
            Image(
                painter = painterResource(icon),
                contentDescription = null, // 밑의 라벨이 이름 역할을 한다
                modifier = Modifier.size(28.dp),
            )
        }

        Text(
            title,
            style = MyFisTheme.type.label,
            color = MyFisColor.TextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

/**
 * 자주 쓰는 기구 — **꽂아 둔 기구로 바로 가는 자리** (DESIGN §6.27).
 *
 * 짜임은 **카카오 T `자주 쓰는 서비스`** 에서 가져왔다 (사용자 지정) —
 * 카드 하나에 제목 + `편집`, 그 밑에 칸 넷. 빈 칸은 **압정**으로 자리를 보여 준다.
 *
 * ⚠️ 레퍼런스는 칸이 다섯인데 **넷으로 줄였다.** 위 빠른 고르기가 4열이라 다섯을 두면
 * 판이 어긋나 두 묶음이 따로 노는 것처럼 보인다.
 */
@Composable
private fun FavoriteMachines(modifier: Modifier = Modifier) {
    // ⚠️ 여기 이름은 **기구**다. 위 빠른 고르기는 구역(`프리웨이트`)인데
    // 여기까지 구역 이름을 쓰면 "자주 쓰는 기구"라는 제목과 어긋난다
    // TODO: 꽂아 둔 기구를 서버에서 받는다 (M-08). 지금은 보여 주기용이다
    val pinned = listOf(
        R.drawable.ic_place_free to "벤치프레스",
        R.drawable.ic_place_cardio to "러닝머신",
    )
    val interaction = remember { MutableInteractionSource() }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(MyFisColor.Surface1, MyFisRadius.md)
            .padding(MyFisSpacing.cardPadding),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
    ) {
        Row(
            Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Text(
                "자주 쓰는 기구",
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
                modifier = Modifier.weight(1f),
            )
            // TODO: 꽂기/빼기 편집으로 (M-08)
            Text(
                "편집",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.tapWithHaptics(interaction) {},
            )
        }

        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
            repeat(4) { index ->
                if (index < pinned.size) {
                    val (icon, title) = pinned[index]
                    PlaceCell(icon, title, Modifier.weight(1f))
                } else {
                    EmptyPinSlot(Modifier.weight(1f))
                }
            }
        }
    }
}

/**
 * 빈 칸. **자리를 비워 두지 않고 압정을 놓는다** — 비워 두면 칸이 몇 개인지 안 보이고,
 * 꽂을 수 있다는 것도 안 보인다.
 */
@Composable
private fun EmptyPinSlot(modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        // TODO: 누르면 기구 고르기로 (M-08)
        modifier = modifier.tapWithHaptics(interaction) {},
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Box(
            Modifier
                .size(MyFisSize.listRowMin)
                .background(MyFisColor.Surface2, MyFisRadius.tile)
                .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.tile),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_place_pin),
                contentDescription = null, // 밑의 라벨이 이름 역할을 한다
                // 찬 칸(28 원색)보다 작고 흐리다. 같은 무게로 두면 빈 칸이 먼저 읽힌다
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(24.dp),
            )
        }

        Text("추가", style = MyFisTheme.type.label, color = MyFisColor.TextTertiary, maxLines = 1)
    }
}
