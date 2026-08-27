package com.myfis.app.ui.screens

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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 홈 헤더의 **핀으로 들어오는 잎 화면** (SPEC M-08 지점 내부 지도).
 *
 * 지금은 **맨 위 찾기 줄만** 있다. 밑에 들어갈 것(평면도 · 기구 핀)은 아직 미정이다.
 *
 * 줄의 짜임은 **카카오 T 홈**에서 가져왔다 (사용자 지정) —
 * 큰 알약 하나에 **왼쪽은 물음, 오른쪽은 바로 가는 칸 둘**. 색은 우리 것을 쓴다.
 *
 * ⚠️ 잎 화면은 셸 밖이라 **바탕색과 상태바 여백을 스스로 넣는다.**
 * 바탕이 없으면 밀려 들어오는 동안 뒤 화면이 비쳐 겹쳐 보이고, 여백이 없으면 헤더가 시계에 겹친다.
 */
@Composable
fun BranchScreen(onBack: () -> Unit = {}) {
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(title = null, onBack = onBack)

        BranchSearchBar(
            Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.sm),
        )
    }
}

/**
 * 찾기 줄 — **이 화면에서 제일 먼저 눈에 들어와야 하는 것**이라 테두리를 라임으로 두른다.
 *
 * 판을 라임으로 채우지 않는다. 채우면 밑에 올 지도보다 이 줄이 더 세진다 (§3.2 액센트 예산).
 */
@Composable
private fun BranchSearchBar(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(MyFisSize.searchBar)
            .background(MyFisColor.Surface1, MyFisRadius.lg)
            .border(1.5.dp, MyFisColor.Accent, MyFisRadius.lg)
            .padding(horizontal = MyFisSpacing.lg),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        // TODO: 누르면 기구 검색으로 (M-08). 지금은 자리만 잡는다
        // 물음이 **이 줄의 제목**이라 흐리게 두지 않는다. tertiary 로 두면 꺼진 칸처럼 보인다
        Text(
            "어떤 기구 찾으세요?",
            style = MyFisTheme.type.titleMd,
            color = MyFisColor.TextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f),
        )

        QuickSlot("루틴")
        // 칸 둘을 가르는 선. 붙여 두면 글자 넷이 한 덩어리로 읽힌다
        Box(
            Modifier
                .width(1.dp)
                .height(16.dp)
                .background(MyFisColor.BorderSubtle),
        )
        QuickSlot("즐겨찾기")
    }
}

/** `⊕ 루틴` 처럼 **한 번에 가는 칸**. 아직 등록 전이라 `⊕` 를 달고 있다 */
@Composable
private fun QuickSlot(title: String) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        // TODO: 등록/이동을 연결한다
        modifier = Modifier.tapWithHaptics(interaction) {},
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(2.dp),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_plus_circle),
            contentDescription = null, // 옆 글자가 이름 역할을 한다
            tint = MyFisColor.TextSecondary,
            modifier = Modifier.size(18.dp),
        )
        Text(title, style = MyFisTheme.type.bodySm, color = MyFisColor.TextPrimary, maxLines = 1)
    }
}
