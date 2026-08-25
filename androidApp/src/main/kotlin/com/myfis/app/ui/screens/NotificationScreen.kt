package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisGhostButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * SPEC.md §5 H-02 알림함 — 놓친 알림을 확인한다.
 *
 * 헤더의 알림 아이콘에서 **오른쪽에서 왼쪽으로 밀려 들어온다** (셸의 NavHost 가 그린다).
 * 탭 목적지가 아니라 잎 화면이라 하단 탭 바까지 통째로 덮는다.
 *
 * 들어오면 전체 읽음 처리한다 (개별 읽음은 관리하지 않는다). 다만 이번 방문 동안에는
 * 미확인 점을 그대로 둔다 — 뭐가 새로 온 건지 보여야 들어온 보람이 있다.
 */
@Composable
fun NotificationScreen(
    onBack: () -> Unit,
    items: List<MyFisNotification> = notificationPlaceholder,
) {
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        // TODO: Y-03 설정이 붙으면 연결한다
        DetailHeader("알림", onBack, actionIcon = R.drawable.ic_header_settings, onAction = {})

        if (items.isEmpty()) EmptyState() else NotificationList(items)
    }
}

@Composable
private fun NotificationList(items: List<MyFisNotification>) {
    val unread = items.filter { it.isUnread }
    val read = items.filterNot { it.isUnread }

    LazyColumn(Modifier.fillMaxSize()) {
        // 안 읽은 알림은 **한 덩어리로 밝게 깐다.** 점을 하나씩 찍는 것보다
        // "여기까지가 새 거" 가 한눈에 들어온다 (DESIGN.md §6.19)
        if (unread.isNotEmpty()) {
            item {
                Column(
                    Modifier
                        .fillMaxWidth()
                        .background(MyFisColor.Surface1)
                        .padding(vertical = MyFisSpacing.sm),
                ) {
                    unread.forEach { NotificationRow(it) }
                }
            }
        }

        if (read.isNotEmpty()) {
            item {
                Text(
                    "지난 알림",
                    style = MyFisTheme.type.titleMd,
                    color = MyFisColor.TextPrimary,
                    modifier = Modifier.padding(
                        start = MyFisSpacing.screenHorizontal,
                        end = MyFisSpacing.screenHorizontal,
                        top = MyFisSpacing.xxl,
                        bottom = MyFisSpacing.sm,
                    ),
                )
            }
            items(read, key = { it.id }) { NotificationRow(it) }
        }

        item { RetentionNote() }
        item { Spacer(Modifier.height(MyFisSpacing.xxxl)) }
    }
}

/**
 * 목록 끝의 보관 기간 안내.
 *
 * **선 사이에 글을 앉힌다** — 목록이 여기서 끝났다는 걸 알려 주면서
 * "왜 옛날 알림이 없지" 라는 질문을 미리 막는다.
 */
@Composable
private fun RetentionNote() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = MyFisSpacing.xxl),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            Modifier
                .weight(1f)
                .height(1.dp)
                .background(MyFisColor.BorderSubtle),
        )
        Text(
            "${NotificationRetentionDays}일 전 알림까지 확인할 수 있어요",
            style = MyFisTheme.type.caption,
            color = MyFisColor.TextTertiary,
            modifier = Modifier.padding(horizontal = MyFisSpacing.md),
        )
        Box(
            Modifier
                .weight(1f)
                .height(1.dp)
                .background(MyFisColor.BorderSubtle),
        )
    }
}

/** TODO(서버): 보관 기간은 서버 정책을 따른다 (SPEC H-02) */
private const val NotificationRetentionDays = 7

/**
 * 알림 한 행 (DESIGN.md §6.19).
 *
 * 왼쪽 아이콘 타일 · 제목 · 본문 · 오른쪽 위 시각. 구분선은 두지 않는다 —
 * 행마다 선을 그으면 목록이 표처럼 보이고, 묶음(안 읽음 블록)이 안 읽힌다.
 */
@Composable
private fun NotificationRow(item: MyFisNotification) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = MyFisSize.listRowMin)
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.md,
            ),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        // TODO: kind.destination 화면이 붙으면 행을 눌러 이동한다.
        // 지금 눌러도 갈 곳이 없어 일부러 반응을 넣지 않았다.
    ) {
        // 종류마다 색이 다르다. 배경은 같은 색을 옅게 깔아 **타일 자체가 튀지는 않게** 한다
        Box(
            Modifier
                .size(TileSize)
                .clip(MyFisRadius.md)
                .background(item.kind.color.copy(alpha = 0.16f)),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(item.kind.icon),
                contentDescription = null, // 옆 제목이 이름 역할을 한다
                tint = item.kind.color,
                modifier = Modifier.size(22.dp),
            )
        }

        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            Row(verticalAlignment = Alignment.Top) {
                Text(
                    item.title,
                    style = MyFisTheme.type.titleSm,
                    color = MyFisColor.TextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f),
                )
                Text(
                    item.time,
                    style = MyFisTheme.type.caption,
                    color = MyFisColor.TextTertiary,
                    modifier = Modifier.padding(start = MyFisSpacing.sm, top = 2.dp),
                )
            }
            // 건수 배지는 **본문 첫 줄 오른쪽**에 붙인다. 본문은 그 아래로 흘러내린다
            Row(verticalAlignment = Alignment.Top) {
                Text(
                    item.body,
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextSecondary,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f, fill = false),
                )
                item.count?.let { count ->
                    Spacer(Modifier.weight(1f))
                    // 같은 종류가 여러 건 묶였을 때만. 액센트는 쓰지 않는다 — 건수는 강조할 값이 아니다
                    Text(
                        "${count}건",
                        style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
                        color = MyFisColor.TextSecondary,
                        modifier = Modifier
                            .padding(start = MyFisSpacing.sm)
                            .background(MyFisColor.Surface3, MyFisRadius.sm)
                            .padding(horizontal = MyFisSpacing.sm, vertical = 2.dp),
                    )
                }
            }
        }
    }
}

private val TileSize = 44.dp

/** §6.10 빈 상태 — 한 줄 설명 + 액션 1개. 일러스트는 넣지 않는다. */
@Composable
private fun EmptyState() {
    Column(
        Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text("알림이 없어요", style = MyFisTheme.type.titleMd, color = MyFisColor.TextSecondary)
        Spacer(Modifier.height(MyFisSpacing.xl))
        // TODO: Y-03 설정이 붙으면 연결한다.
        MyFisGhostButton("알림 설정", onClick = {}, modifier = Modifier.width(120.dp))
    }
}

@Preview(backgroundColor = 0xFF000000, showBackground = true)
@Composable
private fun NotificationScreenPreview() {
    MyFisTheme { NotificationScreen(onBack = {}) }
}
