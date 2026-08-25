package com.myfis.app.ui.components

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
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * 보유 마일리지 — **구분선 하나 위에 칩이 얹혀 있다.**
 *
 * 라벨("내 마일리지")은 없다. 동전 아이콘이 이미 무슨 숫자인지 말한다.
 * 값 표기가 `n P` 라 **아이콘도 동전 안에 P** 를 넣어 둘이 같은 말을 하게 했다.
 *
 * P 는 칠하지 않고 **구멍으로 뚫는다** (`evenOdd`) — 그래야 라임 위 글자가 검정이 된다 (§3.2).
 * 값은 흰색이다. 라임이 둘이면 어느 쪽이 중요한지 알 수 없다.
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
        Row(
            modifier = Modifier
                .background(MyFisColor.Surface2, MyFisRadius.full)
                .padding(
                    start = MyFisSpacing.sm,
                    end = MyFisSpacing.md,
                    top = 7.dp,
                    bottom = 7.dp,
                ),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_mileage_fill),
                contentDescription = null, // 옆 숫자가 이름 역할을 한다
                tint = MyFisColor.Accent,
                modifier = Modifier.size(22.dp),
            )
            Text(
                balance.toMileage(),
                style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextPrimary,
                modifier = Modifier.padding(start = MyFisSpacing.xs),
            )
        }
    }
}
