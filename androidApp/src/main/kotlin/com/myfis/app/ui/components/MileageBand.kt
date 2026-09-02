package com.myfis.app.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.screens.toMileage
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * 보유 마일리지 — **구분선 하나 위에 칩이 얹혀 있다.**
 *
 * 라벨("내 마일리지")은 없다. 동전 아이콘이 이미 무슨 숫자인지 말한다.
 * 값 표기가 `n P` 라 **아이콘도 동전 안에 P** 를 넣어 둘이 같은 말을 하게 했다.
 *
 * P 는 칠하지 않고 **구멍으로 뚫는다** (`evenOdd`) — 그래야 라임 위 글자가 검정이 된다 (§3.2).
 *
 * **라임은 동전 하나뿐이다.** 값은 앱 전체와 같은 표기를 쓴다 (§3.3 `MileageText`) —
 * 포인트 숫자를 라임으로 칠하면 같은 값이 화면마다 다르게 읽힌다.
 *
 * 스크롤해도 남는다 (SPEC S 공통 규칙).
 */
@Composable
fun MileageBand(balance: Int, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = MyFisSpacing.md),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(MyFisColor.BorderSubtle),
        )
        // 칩은 배경이 불투명해서 선 가운데를 덮는다 — 선이 칩을 통과하는 것처럼 보인다
        MileageChip(balance)
    }
}

/**
 * 마일리지 칩 — **동전 + 값 한 덩어리** (§6.12).
 *
 * 스토어 띠(`MileageBand`)와 혜택 헤더(§6.23)가 **같은 것을 쓴다.**
 * 같은 값을 화면마다 다르게 그리면 같은 값으로 안 읽힌다.
 */
@Composable
fun MileageChip(balance: Int, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            // 높이는 여백이 아니라 **값으로 못 박는다** (§5.2). 전에는 상하 `7` 이었는데
            // 그 값이 §5.1 스케일 밖이었다 — 결과 높이는 그대로 36 이다 (2026-08-27)
            .height(MyFisSize.chip)
            .background(MyFisColor.Surface2, MyFisRadius.full)
            .padding(start = MyFisSpacing.sm, end = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Image(
            painter = painterResource(R.drawable.ic_coin),
            contentDescription = null, // 옆 숫자가 이름 역할을 한다
            modifier = Modifier.size(22.dp),
        )
        MileageText(
            balance,
            style = MyFisTheme.type.titleSm,
            modifier = Modifier.padding(start = MyFisSpacing.xs),
        )
    }
}
