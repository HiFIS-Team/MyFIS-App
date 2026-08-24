package com.myfis.app.ui.shell

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 화면 상단 헤더.
 *
 * - 왼쪽: 지점 (누르면 지점 선택 M-01)
 * - 오른쪽: 멤버십 (M-06) · 알림 (H-02)
 *
 * 아이콘은 §8 아웃라인 1.5px 규칙을 따른다. 하단 탭과 달리 시스템 컴포넌트가 아니므로
 * 두 플랫폼이 같은 벡터를 쓴다.
 */
@Composable
fun AppHeader(
    onBranch: () -> Unit = {},
    onMembership: () -> Unit = {},
    onNotification: () -> Unit = {},
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        contentAlignment = Alignment.Center,
    ) {
        // 워드마크는 양옆 아이콘 개수와 무관하게 **화면 정중앙**에 둔다.
        // Row 안에 넣으면 좌우 아이콘 폭에 따라 중심이 밀린다.
        Wordmark()

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            HeaderIcon(R.drawable.ic_header_branch, "지점", onBranch)

            Box(Modifier.weight(1f))

            Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs)) {
                HeaderIcon(R.drawable.ic_header_membership, "멤버십", onMembership)
                HeaderIcon(R.drawable.ic_header_notification, "알림", onNotification)
            }
        }
    }
}

@Composable
private fun HeaderIcon(icon: Int, description: String, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Box(
        modifier = Modifier
            // 터치 타겟 48dp (DESIGN.md §5.3). 아이콘은 24dp 지만 영역은 넉넉히 잡는다
            .size(44.dp)
            .tapWithHaptics(interaction, onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(icon),
            contentDescription = description,
            tint = MyFisColor.TextPrimary,
            modifier = Modifier
                .size(24.dp)
                .graphicsLayer {
                    scaleX = press
                    scaleY = press
                },
        )
    }
}
