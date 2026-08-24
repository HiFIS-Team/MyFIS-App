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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisGhostButton
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
        DetailHeader("알림", onBack)

        if (items.isEmpty()) EmptyState() else NotificationList(items)
    }
}

@Composable
private fun NotificationList(items: List<MyFisNotification>) {
    LazyColumn(Modifier.fillMaxSize()) {
        items(items, key = { it.id }) { item ->
            NotificationRow(item)
            if (item != items.last()) {
                // §6.5 구분선은 좌측 인덴트 없이 전체 너비
                Box(
                    Modifier
                        .fillMaxWidth()
                        .height(1.dp)
                        .background(MyFisColor.BorderSubtle),
                )
            }
        }
    }
}

/**
 * 알림 한 행.
 *
 * 미확인 점은 **행 맨 왼쪽**에 둔다 (SPEC H-02). 읽은 행도 같은 폭을 비워 둬야
 * 아이콘 세로줄이 어긋나지 않는다.
 */
@Composable
private fun NotificationRow(item: MyFisNotification) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = MyFisSize.listRowMin)
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.lg,
            ),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        // TODO: kind.destination 화면이 붙으면 행을 눌러 이동한다.
        // 지금 눌러도 갈 곳이 없어 일부러 반응을 넣지 않았다.
    ) {
        Box(
            Modifier
                .padding(top = 8.dp)
                .size(6.dp)
                .background(
                    color = if (item.isUnread) MyFisColor.Accent else Color.Transparent,
                    shape = CircleShape,
                ),
        )

        Icon(
            painter = painterResource(item.kind.icon),
            contentDescription = null,
            tint = MyFisColor.TextSecondary,
            modifier = Modifier.size(22.dp),
        )

        Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs)) {
            Text(item.title, style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
            Text(item.body, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
            Text(
                item.time,
                style = MyFisTheme.type.caption,
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(top = 2.dp),
            )
        }
    }
}

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
