package com.myfis.app.ui.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * P-07 **함께 마일리지 받기** — 지금 같은 지점에 있는 회원을 눌러 서로 적립한다.
 *
 * 레퍼런스는 **토스 친구 초대 레이더**다 — 동심원을 깔고 사람을 흩어 놓은 뒤 가운데에 나를 둔다.
 * 목록으로 그리면 *누구인지* 가 앞서지만, 레이더로 그리면 ***지금 여기 같이 있다*** 가 앞선다.
 * 이 화면이 파는 건 사람이 아니라 **같은 공간에 있다는 사실**이다.
 *
 * 액센트는 **가운데 나 + 말풍선 숫자 2곳뿐**이다 (§3.2). 주변 사람은 카테고리 색을 쓴다 —
 * 전부 회색으로 두면 "아무도 없는 방"처럼 읽히고, 전부 라임이면 누구를 눌러야 할지 사라진다.
 */
@Composable
fun TouchScreen(onClose: () -> Unit) {
    val members = remember { mutableStateListOf(*nearbyMemberPlaceholder.toTypedArray()) }
    val remaining = (DAILY_LIMIT - members.count { it.received }).coerceAtLeast(0)

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(
            title = "함께 마일리지 받기",
            onBack = onClose,
            backIcon = R.drawable.ic_header_close,
            backDescription = "닫기",
        )

        // 사람 수가 먼저다 — 지금 갈 만한지가 여기서 정해진다
        Text(
            "지금 강남점에 12명",
            style = MyFisTheme.type.label,
            color = MyFisColor.TextSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth().padding(top = MyFisSpacing.lg),
        )

        Box(
            Modifier
                .weight(1f)
                .fillMaxWidth()
                // 바깥 고리는 화면 밖으로 흘러나간다 — 방이 화면보다 넓다는 뜻이다
                .clipToBounds(),
            contentAlignment = Alignment.Center,
        ) {
            Rings()

            members.forEachIndexed { i, member ->
                MemberDot(
                    member = member,
                    modifier = Modifier.offset(x = member.dx.dp, y = member.dy.dp),
                    onTap = {
                        if (!member.received && remaining > 0) {
                            members[i] = member.copy(received = true)
                        }
                    },
                )
            }

            Bubble(remaining, Modifier.offset(x = 10.dp, y = (-96).dp))

            // 가운데 나
            Box(
                Modifier.size(64.dp).background(MyFisColor.Accent, CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Text("나", style = MyFisTheme.type.titleSm, color = MyFisColor.OnAccent)
            }
        }

        Text(
            "얼굴을 누르면 둘 다 +10 P 받아요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth().padding(bottom = MyFisSpacing.giant),
        )
    }
}

/** 동심원 — 바깥으로 갈수록 옅어진다. 멀수록 흐릿하게 잡히는 신호처럼 보이게 */
@Composable
private fun Rings() {
    Canvas(Modifier.fillMaxSize()) {
        val c = androidx.compose.ui.geometry.Offset(size.width / 2f, size.height / 2f)
        listOf(78f, 140f, 202f, 264f).forEachIndexed { i, radius ->
            drawCircle(
                color = MyFisColor.BorderSubtle.copy(alpha = 0.85f - i * 0.17f),
                radius = radius.dp.toPx(),
                center = c,
                style = androidx.compose.ui.graphics.drawscope.Stroke(width = 1.dp.toPx()),
            )
        }
    }
}

/** 남은 횟수 — 숫자만 라임이라 한 눈에 걸린다 */
@Composable
private fun Bubble(remaining: Int, modifier: Modifier = Modifier) {
    Row(
        modifier
            .background(MyFisColor.Surface2, CircleShape)
            .padding(horizontal = MyFisSpacing.lg, vertical = MyFisSpacing.md),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("오늘", style = MyFisTheme.type.bodySm, color = MyFisColor.TextPrimary)
        Text("${remaining}명", style = MyFisTheme.type.bodySm, color = MyFisColor.Accent)
        Text("더 받을 수 있어요", style = MyFisTheme.type.bodySm, color = MyFisColor.TextPrimary)
    }
}

@Composable
private fun MemberDot(member: NearbyMember, modifier: Modifier, onTap: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    // 딤이 아니라 **크기**로 눌림을 알린다 (DESIGN §7 — iOS `.myFisIcon` 과 같은 값)
    val scale by animateFloatAsState(if (pressed) 0.86f else 1f, MyFisMotion.fast(), label = "dot")

    Column(
        modifier = modifier.then(
            if (member.received) Modifier else Modifier.tapWithHaptics(interaction, onTap),
        ),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            Modifier
                .scale(scale)
                .size(56.dp)
                .background(if (member.received) MyFisColor.Surface2 else member.color, CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                member.nickname.take(1),
                style = MyFisTheme.type.titleSm,
                // 카테고리 색은 전부 밝은 파스텔이라 글자는 검정이다 (§3.2)
                color = if (member.received) MyFisColor.TextTertiary else MyFisColor.OnAccent,
            )
        }
        Text(
            if (member.received) "받았어요" else member.nickname,
            style = MyFisTheme.type.caption,
            color = if (member.received) MyFisColor.TextTertiary else MyFisColor.TextSecondary,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
    }
}

/** 하루에 받을 수 있는 사람 수. **무제한이면 의미가 없다** (SPEC P-07) */
private const val DAILY_LIMIT = 5

/** 지금 같은 지점에 있는 회원. **닉네임 + 아바타만** 쓴다 — 실명·사진을 쓰지 않는다 (SPEC P-07) */
data class NearbyMember(
    val id: Int,
    val nickname: String,
    val color: Color,
    /** 레이더 가운데(= 나)에서의 자리 */
    val dx: Int,
    val dy: Int,
    val received: Boolean = false,
)

// TODO(서버): 지점에 있는 회원 목록은 서버가 준다 (SPEC §8). 자리는 서버 값으로 흩는다
val nearbyMemberPlaceholder = listOf(
    NearbyMember(1, "민준", MyFisColor.CategoryViolet, -60, -176),
    NearbyMember(2, "지호", MyFisColor.CategoryBlue, 140, -52),
    NearbyMember(3, "서연", MyFisColor.CategoryOrange, -140, -30),
    NearbyMember(4, "도윤", MyFisColor.CategoryPink, 100, 100, received = true),
    NearbyMember(5, "하은", MyFisColor.CategoryTeal, -60, 160),
)
