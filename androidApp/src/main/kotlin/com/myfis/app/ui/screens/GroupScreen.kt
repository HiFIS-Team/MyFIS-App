package com.myfis.app.ui.screens

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.MyFisUnderlineTabs
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisIconTile
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md G-01 모임 (DESIGN.md §6.29).
 *
 * 레퍼런스는 **당근 커뮤니티 › 모임**이다 — 가로 모임 줄 → 세그먼트 → 카테고리 갈래 → 필터 칩 → 목록,
 * 그리고 떠 있는 `모임 만들기`. **구조만 가져오고 표면은 우리 것을 쓴다** (§3.2).
 *
 * 이 탭이 답하는 질문은 하나 — **"지금 우리 지점에 들어갈 만한 모임이 뭐가 있나"**.
 *
 * ⚠️ **1순위가 숫자가 아니다** (§2 원칙 1 의 예외). 여기는 계기판이 아니라 **탐색 화면**이고
 * 답이 글이다 — 모임 이름이 제일 크다. 홈·유산소와 성격이 다르다.
 *
 * **원본과 달라진 것 세 가지**
 * - **사진을 안 쓴다.** 모임 사진이 서버에 없고, 없이 옮기면 회색 정사각 목록이 된다 →
 *   갈래 아이콘 타일(§6.26)로 바꿨다. 당근은 *모르는 동네 모임*이라 분위기를 봐야 하지만
 *   우리는 **같은 지점 사람들**이라 분위기보다 언제·몇 명이 먼저다
 * - 원본 맨 위 다섯 갈래(동네생활·모임·카페…)는 우리 IA 에 없다 → 뺐다
 * - 원본은 색이 여섯 곳(주황 버튼·주황 점·파란 화살표·이모지·사진)이다. 우리는 **라임 두 곳**이 상한이라
 *   `모임 만들기` 와 **안 읽은 점**에만 준다. 고른 것은 색이 아니라 밑줄·판 밝기로 알린다
 */
@Composable
fun GroupScreen(
    /** TODO: G-03 모임 개설이 붙으면 연결한다 */
    onCreate: () -> Unit = {},
    /** TODO: G-02 모임 상세가 붙으면 연결한다 */
    onGroup: (GroupItem) -> Unit = {},
    onSearch: () -> Unit = {},
) {
    var segment by rememberSaveable { mutableStateOf(GroupSegment.BROWSE) }
    var category by rememberSaveable { mutableStateOf(GroupCategory.ALL) }
    var sort by rememberSaveable { mutableStateOf(GroupSort.NONE) }
    var order by rememberSaveable { mutableStateOf(GroupOrder.RECOMMENDED) }

    val rows = groupPlaceholder.filter { category == GroupCategory.ALL || it.category == category }

    Column(Modifier.fillMaxSize()) {
        GroupHeader(onSearch)

        Box(Modifier.weight(1f)) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    // 알약이 마지막 줄을 가리지 않게 그만큼 비워 둔다 (유산소와 같은 규칙)
                    .padding(bottom = MyFisSize.buttonSecondary + MyFisSpacing.xxxl),
            ) {
                MyGroupRail(groupRailPlaceholder, onGroup)

                SegmentBar(
                    segment, { segment = it },
                    Modifier
                        .padding(horizontal = MyFisSpacing.screenHorizontal)
                        .padding(top = MyFisSpacing.lg),
                )

                MyFisUnderlineTabs(
                    items = GroupCategory.entries,
                    selected = category,
                    onSelect = { category = it },
                    title = { it.label },
                    modifier = Modifier.padding(top = MyFisSpacing.md),
                )

                SortChips(sort, order, { sort = it }, { order = it }, Modifier.padding(top = MyFisSpacing.md))

                Spacer(Modifier.height(MyFisSpacing.xs))
                rows.forEach { group ->
                    GroupRow(group) { onGroup(group) }
                }
            }

            // 이 화면의 액션은 이 하나뿐 (§2 원칙 5) — **오른쪽 아래**, 엄지가 닿는 자리다 (원칙 2).
            // 원본(당근)도 우하단이고 유산소(§6.28)도 같은 자리다
            MyFisPrimaryButton(
                text = "＋ 모임 만들기",
                onClick = onCreate,
                pill = true,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = MyFisSpacing.screenHorizontal, bottom = MyFisSpacing.md),
            )
        }
    }
}

/**
 * **화면 이름 한 줄** 🟢 (2026-09-04, 사용자 지정).
 *
 * 전에는 `{지점}의 모임` 이었다 — 모임이 지점에 매여 있다고 봤기 때문인데,
 * **활동 지역(§6.30)이 들어오면서 그 전제가 없어졌다.** 지점을 헤더에 계속 걸어 두면
 * 목록이 지점 것만인 줄 읽힌다.
 * 원본 헤더의 셋(검색·알림·메뉴) 중 알림은 셸이 이미 들고 있고 메뉴는 우리에게 없다 → 검색만 남긴다
 */
@Composable
private fun GroupHeader(onSearch: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            "모임",
            style = MyFisTheme.type.titleMd,
            color = MyFisColor.TextPrimary,
        )
        Spacer(Modifier.weight(1f))
        HeaderIcon(R.drawable.ic_header_search, "모임 검색", onSearch)
    }
}

/**
 * 내가 든 모임과 추천을 옆으로 미는 줄 (원본 맨 위 줄).
 *
 * **여기만 아바타를 쓴다.** 아래 목록과 같은 타일이면 같은 것을 두 번 보여주는 셈이라,
 * 위는 `72` 원판 + 이름 두 줄로 **얼굴처럼** 세우고 아래는 줄 목록으로 둔다.
 */
@Composable
private fun MyGroupRail(groups: List<GroupItem>, onTap: (GroupItem) -> Unit) {
    Row(
        Modifier
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = MyFisSpacing.md),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
    ) {
        groups.forEach { group ->
            val interaction = remember { MutableInteractionSource() }
            Column(
                modifier = Modifier
                    .width(RailAvatar)
                    .tapWithHaptics(interaction) { onTap(group) },
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box {
                    // 목록과 **같은 타일**이다 — 크기만 다르다 (§6.26 이 크기를 받는다)
                    MyFisIconTile(size = RailAvatar) {
                        Icon(
                            painter = painterResource(group.category.icon),
                            contentDescription = null,
                            tint = MyFisColor.TextSecondary,
                            modifier = Modifier.size(30.dp),
                        )
                    }
                    RailBadge(group, Modifier.align(Alignment.BottomEnd).offset(x = 3.dp, y = 3.dp))
                }
                Spacer(Modifier.height(MyFisSpacing.sm))
                Text(
                    group.name,
                    style = MyFisTheme.type.caption,
                    color = MyFisColor.TextSecondary,
                    textAlign = TextAlign.Center,
                    // 두 줄로 고정해야 줄의 바닥이 서로 같다 (상품 카드 §6.12 와 같은 판단)
                    minLines = 2,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }
}

/**
 * 든 모임이면 **안 읽은 점**, 아니면 `＋`(들어가기). 원본과 같은 규칙이다.
 * 라임을 쓰는 두 번째이자 마지막 자리다 — 점 하나라 면적이 거의 없다 (§3.2)
 */
@Composable
private fun RailBadge(group: GroupItem, modifier: Modifier = Modifier) {
    if (group.joined) {
        if (group.unread) {
            Box(
                modifier
                    .size(14.dp)
                    .background(MyFisColor.BgBase, MyFisRadius.full)
                    .padding(2.5.dp)
                    .background(MyFisColor.Accent, MyFisRadius.full),
            )
        }
    } else {
        // 바탕색 고리가 아바타에서 뱃지를 떼어 놓는다. 그림은 iOS 와 **같은 에셋**이다 (§10)
        Box(
            modifier
                .size(27.dp)
                .background(MyFisColor.BgBase, MyFisRadius.full),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_plus_circle),
                contentDescription = null,
                tint = MyFisColor.TextPrimary,
                modifier = Modifier.size(22.dp),
            )
        }
    }
}

/**
 * `둘러보기 · 일정 · 내 모임` — 원본의 알약 세그먼트.
 *
 * 원본은 `홈`이지만 우리 앱에는 **홈 탭이 따로 있어** 같은 이름을 두 뜻으로 쓸 수 없다 → `둘러보기`.
 * 고른 칸은 색이 아니라 **판 밝기**로 알린다 (§5.4 다크에서 위계는 표면 밝기다)
 */
@Composable
private fun SegmentBar(
    selected: GroupSegment,
    onSelect: (GroupSegment) -> Unit,
    modifier: Modifier = Modifier,
) {
    val tabs = GroupSegment.entries
    val index = tabs.indexOf(selected).coerceAtLeast(0)

    BoxWithConstraints(
        modifier
            .fillMaxWidth()
            .background(MyFisColor.Surface1, MyFisRadius.full)
            .padding(MyFisSpacing.xs),
    ) {
        val slot = maxWidth / tabs.size
        // **고른 칸이 미끄러져 간다** 🟢 (2026-09-04, 사용자 지정) — 갈래 줄 밑줄(§6.29)과 같은 규칙.
        // 칸마다 판을 켰다 끄면 **어디서 어디로 갔는지가 안 보인다.**
        // 판 하나를 두고 **자리를 옮긴다**. 고르는 동작이라 `fast`(120ms) — §7
        val x by animateDpAsState(slot * index, MyFisMotion.fast(), label = "segment")

        Box(
            Modifier
                .offset(x = x)
                .width(slot)
                .height(MyFisSize.buttonSecondary)
                .background(MyFisColor.BgBase, MyFisRadius.full),
        )

        Row(Modifier.fillMaxWidth()) {
            tabs.forEach { item ->
                val interaction = remember { MutableInteractionSource() }
                Box(
                    Modifier
                        .weight(1f)
                        .height(MyFisSize.buttonSecondary)
                        .tapWithHaptics(interaction) { onSelect(item) },
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        item.label,
                        style = MyFisTheme.type.titleSm,
                        color = if (item == selected) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                        maxLines = 1,
                    )
                }
            }
        }
    }
}

/**
 * `추천 ⌄ · 인기 · 요즘 뜨는 · 이번 주 열리는` — 원본의 필터 칩 줄.
 *
 * **첫 칩만 여는 칩이다** — 나머지는 켜고 끄는 것.
 * 여는 판은 **네이티브 메뉴 그대로** 쓴다 (§2 원칙 6) — 직접 그리면 두 판이 어긋나고,
 * 바깥을 눌러 닫는 것부터 다시 만들어야 한다.
 *
 * 원본은 칩마다 이모지가 붙지만(📈 · 🏪) **우리는 안 붙인다** — 열 줄 남짓한 목록 위에서
 * 이모지 둘은 라임보다 먼저 눈에 띄어 위계를 뒤집는다 (§2 원칙 3)
 */
@Composable
private fun SortChips(
    selected: GroupSort,
    order: GroupOrder,
    onSelect: (GroupSort) -> Unit,
    onOrder: (GroupOrder) -> Unit,
    modifier: Modifier = Modifier,
) {
    var open by remember { mutableStateOf(false) }

    Row(
        modifier = modifier
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Box {
            SortChip(order.label, selected = true, chevron = true) { open = true }
            DropdownMenu(
                expanded = open,
                onDismissRequest = { open = false },
                containerColor = MyFisColor.Surface2,
                shape = MyFisRadius.md,
            ) {
                GroupOrder.entries.forEach { item ->
                    DropdownMenuItem(
                        text = {
                            Text(
                                item.label,
                                style = MyFisTheme.type.body,
                                color = if (item == order) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                            )
                        },
                        onClick = { onOrder(item); open = false },
                    )
                }
            }
        }
        GroupSort.chips.forEach { item ->
            SortChip(item.label, selected = item == selected, chevron = false) {
                onSelect(if (selected == item) GroupSort.NONE else item)
            }
        }
    }
}

@Composable
private fun SortChip(label: String, selected: Boolean, chevron: Boolean, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            // 칩은 `36` 이라 그대로 두면 터치 타겟이 `48` 에 못 미친다 (§5.3).
            // **보이는 높이는 그대로 두고 누르는 넓이만** 위아래로 벌린다
            .height(MyFisSize.minTouchTarget)
            .tapWithHaptics(interaction, onClick),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Row(
            modifier = Modifier
                .height(MyFisSize.chip)
                .background(
                    if (selected) MyFisColor.Surface2 else Color.Transparent,
                    MyFisRadius.full,
                )
                .then(
                    if (selected) Modifier
                    else Modifier.border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.full),
                )
                .padding(horizontal = MyFisSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
        ) {
            Text(
                label,
                style = MyFisTheme.type.bodySm,
                color = if (selected) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                maxLines = 1,
            )
            if (chevron) {
                Icon(
                    painter = painterResource(R.drawable.ic_chevron_down),
                    contentDescription = null,
                    tint = MyFisColor.TextPrimary,
                    modifier = Modifier.size(14.dp),
                )
            }
        }
    }
}

/**
 * 모임 한 줄 — 타일 + 이름 + 한 줄 소개 + 메타.
 *
 * **메타가 원본과 다르다.** 원본은 `📍동네 · 👤122명` 인데, 같은 지점 사람들끼리는
 * 동네가 전부 같아 알려 주는 게 없다 → **언제 모이는지**를 그 자리에 넣었다.
 * 들어갈지 말지를 가르는 건 거리가 아니라 **요일·시간**이다
 */
@Composable
private fun GroupRow(group: GroupItem, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .tapWithHaptics(interaction, onClick)
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = MyFisSpacing.md),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
    ) {
        MyFisIconTile {
            Icon(
                painter = painterResource(group.category.icon),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier.size(26.dp),
            )
        }

        Column {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
            ) {
                Text(
                    group.name,
                    style = MyFisTheme.type.titleSm,
                    color = MyFisColor.TextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                if (group.joined) {
                    Text(
                        "참여 중",
                        style = MyFisTheme.type.caption,
                        color = MyFisColor.TextSecondary,
                        modifier = Modifier
                            .background(MyFisColor.Surface2, MyFisRadius.full)
                            .padding(horizontal = MyFisSpacing.sm, vertical = 2.dp),
                    )
                }
            }
            Text(
                group.summary,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(top = 2.dp),
            )
            GroupMeta(group, Modifier.padding(top = MyFisSpacing.xs))
        }
    }
}

/** 언제 · 몇 명. 구분은 가운뎃점이 아니라 **세로선**이다 — 점은 시간 글자에 묻힌다 (§6.12 와 같은 규칙) */
@Composable
private fun GroupMeta(group: GroupItem, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(3.dp),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_quest_attend),
            contentDescription = null,
            tint = MyFisColor.TextTertiary,
            modifier = Modifier.size(13.dp),
        )
        Text(group.schedule, style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary, maxLines = 1)
        Box(
            Modifier
                .padding(horizontal = 2.dp)
                .width(1.dp)
                .height(10.dp)
                .background(MyFisColor.BorderStrong),
        )
        Icon(
            painter = painterResource(R.drawable.ic_tab_my),
            contentDescription = null,
            tint = MyFisColor.TextTertiary,
            modifier = Modifier.size(12.dp),
        )
        Text("${group.members}명", style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary, maxLines = 1)
    }
}

private val RailAvatar = 72.dp

// MARK: - 모델

/** 세 세그먼트 (SPEC G-01) */
enum class GroupSegment(val label: String) {
    BROWSE("둘러보기"), SCHEDULE("일정"), MINE("내 모임")
}

/**
 * 모임 갈래 — **운동 반 · 친목 반** 🟢 (2026-09-04, 사용자 지정).
 *
 * 처음엔 `러닝 · 웨이트 · 클래스 · 대회` 넷이었는데 **운동만 담겼다.**
 * 이 탭은 *운동 모임*이 아니라 **같은 헬스장 사람들이 친해지는 자리**라
 * 밥·정보·나들이가 갈 데가 없었다 → 넷을 더했다.
 *
 * 원본(당근)은 `운동 · 동네친구 · 아웃도어/여행 · 자기계발 …` 열둘인데,
 * 그건 **동네 전체**를 훑을 때 쓰는 잣대다. 한 지점 모임은 열 개 남짓이라
 * 열둘이면 갈래당 한 개도 안 된다 — **여덟이 우리 크기다.**
 *
 * 그림은 새로 그리지 않고 **있는 것에서 골랐다** (§8: 28px 에서 뭘로 읽히는지).
 *
 * ⚠️ **이 목록이 앱의 유일한 갈래 벌이다.** 모임 개설(G-03) 칩도 이걸 그대로 쓴다
 */
enum class GroupCategory(val label: String, val icon: Int) {
    ALL("전체", R.drawable.ic_tab_group),
    WEIGHT("웨이트", R.drawable.ic_tab_weight),
    RUNNING("러닝", R.drawable.ic_tab_cardio),
    /**
     * ⚠️ `ic_place_stretch`(요가 매트)는 **원색 두 톤 지도용**이라
     * 한 색으로 누르면 둥근 덩어리가 된다 (2026-09-04 확인, §8)
     */
    CLASS("클래스", R.drawable.ic_benefit_stretch),

    /** 밖으로 나간다 — 핀이 그 뜻을 제일 짧게 낸다 */
    OUTDOOR("아웃도어", R.drawable.ic_place_pin),

    /** 잔 두 개. 밥·커피 모임이라 먹는 그림이어야 한다 */
    SOCIAL("친목", R.drawable.ic_tab_store),
    DIET("식단", R.drawable.ic_home_diet),
    INFO("정보공유", R.drawable.ic_quest_board),
    CONTEST("대회", R.drawable.ic_tab_ranking),
    ;

    companion object {
        /** 만들 때 고를 수 있는 것 — `전체` 는 목록 갈래 줄에만 있는 자리다 */
        val pickable get() = entries.filter { it != ALL }
    }
}

/**
 * **여는 칩** — 목록을 무슨 차례로 볼지 (SPEC G-01) 🟢 (2026-09-04, 사용자 지정).
 *
 * 전에는 `추천` 이 켜고 끄는 칩이었는데, **차례는 켜고 끄는 게 아니라 하나를 고르는 것**이다.
 * 그래서 여는 칩으로 바꾸고 목록을 달았다
 */
enum class GroupOrder(val label: String) {
    RECOMMENDED("추천"), LATEST("최신순")
}

/**
 * **켜고 끄는 칩** — 목록을 좁힌다 (SPEC G-01).
 * `NONE` 은 아무것도 안 켠 상태다 — 칩은 다시 누르면 꺼진다
 */
enum class GroupSort(val label: String) {
    NONE(""), POPULAR("인기"), RISING("요즘 뜨는"), THIS_WEEK("이번 주 열리는")
    ;

    companion object {
        /** 칩으로 그리는 것만. `NONE` 은 상태이지 칩이 아니다 */
        val chips get() = listOf(POPULAR, RISING, THIS_WEEK)
    }
}

/** 모임 하나 (SPEC G-01) */
data class GroupItem(
    val id: Int,
    val category: GroupCategory,
    val name: String,
    /** 한 줄 소개 */
    val summary: String,
    /** `화·목 저녁` 처럼 **언제 모이는지** */
    val schedule: String,
    val members: Int,
    /** 내가 든 모임인가 */
    val joined: Boolean = false,
    /** 안 읽은 글이 있나 — 든 모임에서만 뜻이 있다 */
    val unread: Boolean = false,
)

/** TODO(서버): 모임·멤버·일정은 서버가 준다 (SPEC §8). 하드코딩하지 않는다 */
const val groupBranchPlaceholder = "광주 상무"

val groupPlaceholder = listOf(
    GroupItem(1, GroupCategory.RUNNING, "아침 러닝 크루", "출근 전에 한 바퀴 돌고 가요", "매일 06:00", 24, joined = true, unread = true),
    GroupItem(2, GroupCategory.WEIGHT, "스쿼트 100개 클럽", "하루 100개, 인증만 하면 끝", "매일 자유", 51, joined = true),
    GroupItem(3, GroupCategory.CLASS, "필라테스 같이 들어요", "3인 이상 모이면 그룹 할인", "화·목 20:00", 12),
    GroupItem(4, GroupCategory.SOCIAL, "운동 끝나고 한 잔", "단백질 쉐이크든 맥주든", "금 21:00", 37),
    GroupItem(5, GroupCategory.DIET, "도시락 같이 싸요", "일요일에 한 주치 준비", "일 14:00", 19),
    GroupItem(6, GroupCategory.OUTDOOR, "주말 등산", "무등산부터 시작해요", "토 07:00", 26),
    GroupItem(7, GroupCategory.WEIGHT, "3대 500 가자", "스쿼트·벤치·데드 합계 올리기", "월·수·금 19:00", 33),
    GroupItem(8, GroupCategory.CONTEST, "가을 바디 챌린지", "8주 뒤 인바디로 순위 가려요", "10월 1일 시작", 87),
    GroupItem(9, GroupCategory.INFO, "보충제·장비 정보방", "뭐 살지 물어보는 곳", "아무 때나", 64),
    GroupItem(10, GroupCategory.CLASS, "초보 요가", "처음 오신 분 환영해요", "일 10:00", 9),
)

/** 가로 줄 — **든 모임이 앞**, 그다음이 추천이다 */
val groupRailPlaceholder = groupPlaceholder.sortedByDescending { it.joined }
