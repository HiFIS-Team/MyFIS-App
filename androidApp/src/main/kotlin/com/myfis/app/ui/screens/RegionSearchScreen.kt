package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.StoreSearchShell
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSmallButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md G-03 모임 개설 — **활동 지역 설정** (DESIGN.md §6.31).
 *
 * 개설 화면(§6.30)의 `검색` 칩으로 들어오는 잎이다. 레퍼런스는 **당근 활동 지역 설정**.
 *
 * **칩 넷으로는 부족해서 있는 화면이다.** 개설 화면은 지점 둘레 동네만 보여 주는데,
 * 이 탭의 취지가 *회원이 헬스장에만 묶이지 않는 것* 이라 **딴 동네도 고를 수 있어야** 한다.
 */
@Composable
fun RegionSearchScreen(onBack: () -> Unit = {}, onPick: (String) -> Unit = {}) {
    var query by rememberSaveable { mutableStateOf("") }
    val keyword = query.trim()
    val results = if (keyword.isEmpty()) {
        groupNearbyRegionPlaceholder
    } else {
        groupNearbyRegionPlaceholder.filter { it.contains(keyword) }
    }

    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        DetailHeader(title = "활동 지역 설정", onBack = onBack)

        // 스토어 검색과 **같은 판**이다 (§6.9) — 두 화면이 각자 그리면 그날로 어긋난다
        StoreSearchShell(Modifier.padding(horizontal = MyFisSpacing.screenHorizontal)) {
            Box(Modifier.weight(1f), contentAlignment = Alignment.CenterStart) {
                BasicTextField(
                    value = query,
                    onValueChange = { query = it },
                    singleLine = true,
                    textStyle = MyFisTheme.type.body.copy(color = MyFisColor.TextPrimary),
                    cursorBrush = SolidColor(MyFisColor.Accent),
                    modifier = Modifier.fillMaxWidth(),
                    decorationBox = { field ->
                        if (query.isEmpty()) {
                            Text(
                                "동명(읍,면)으로 검색 (ex. 치평동)",
                                style = MyFisTheme.type.body,
                                color = MyFisColor.TextTertiary,
                            )
                        }
                        field()
                    },
                )
            }
            if (query.isNotEmpty()) {
                val clear = remember { MutableInteractionSource() }
                Icon(
                    painter = painterResource(R.drawable.ic_header_clear),
                    contentDescription = "지우기",
                    tint = MyFisColor.TextTertiary,
                    modifier = Modifier.size(18.dp).tapWithHaptics(clear) { query = "" },
                )
            }
        }

        // **찾는 것보다 빠른 길이다.** 대개 지금 서 있는 동네가 답이라 목록보다 위에 둔다
        val here = remember { MutableInteractionSource() }
        Row(
            Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.md)
                .height(MyFisSize.minTouchTarget)
                .tapWithHaptics(here) {}
                .padding(horizontal = MyFisSpacing.screenHorizontal),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_header_branch),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier.size(18.dp),
            )
            Text("현재 위치로 찾기", style = MyFisTheme.type.body, color = MyFisColor.TextSecondary)
        }

        if (results.isEmpty()) {
            // 빈 상태 — **무엇을 하라고 알려 준다.** 없다는 말만 두면 화면이 막다른 길이 된다
            Column(
                Modifier.fillMaxWidth().padding(top = MyFisSpacing.giant),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    "검색 결과가 없어요.\n동네 이름을 다시 확인해주세요.",
                    style = MyFisTheme.type.body,
                    color = MyFisColor.TextTertiary,
                    textAlign = TextAlign.Center,
                )
                Spacer(Modifier.height(MyFisSpacing.xl))
                MyFisSmallButton(text = "다시 검색하기", onClick = { query = "" })
            }
        } else {
            Column(
                Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(bottom = MyFisSpacing.xxxl),
            ) {
                Text(
                    if (keyword.isEmpty()) "근처 동네" else "'$query' 검색 결과",
                    style = MyFisTheme.type.titleSm,
                    color = MyFisColor.TextPrimary,
                    modifier = Modifier
                        .padding(horizontal = MyFisSpacing.screenHorizontal)
                        .padding(vertical = MyFisSpacing.md),
                )
                results.forEach { region ->
                    val interaction = remember { MutableInteractionSource() }
                    Row(
                        Modifier
                            .fillMaxWidth()
                            .height(MyFisSize.listRowMin)
                            .tapWithHaptics(interaction) { onPick(region) }
                            .padding(horizontal = MyFisSpacing.screenHorizontal),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
                    ) {
                        Icon(
                            painter = painterResource(R.drawable.ic_place_pin),
                            contentDescription = null,
                            tint = MyFisColor.TextTertiary,
                            modifier = Modifier.size(16.dp),
                        )
                        Text(
                            groupRegionFullName(region),
                            style = MyFisTheme.type.body,
                            color = MyFisColor.TextPrimary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
            }
        }
    }
}
