package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.Chevron
import com.myfis.app.ui.components.MileageText
import com.myfis.app.ui.components.MyFisDivider
import com.myfis.app.ui.components.MyFisListRow
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSmallButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md Y-01 마이 (DESIGN.md §6.38).
 *
 * 레퍼런스는 **버핏그라운드 MY** 다 (2026-09-07, 사용자 지정 — *"아얘 이 디자인이랑 똑같이 만들어"*).
 * 구조를 그대로 옮기고 **표면만 우리 토큰**으로 바꾼다 (§3.2).
 *
 * 위에서부터 — 프로필 한 줄 → **멤버십 덩어리**(만료 경고 · 회원권 카드 · 관리 · 구매)
 * → 구분선으로 나뉜 **글자 줄 묶음**(결제 · 기록 · 안내) → 맨 아래 로그아웃 · 탈퇴.
 *
 * ⚠️ **1순위가 숫자가 아니다** (§2 원칙 1 의 예외 — 모임 §6.29 와 같은 사유).
 * 여기는 계기판이 아니라 **찾아 들어가는 목록**이고, 답이 "어디로 가지" 다.
 * 그래도 회원권만은 숫자로 말한다 — 만료 경고 줄과 카드의 `남음` 이 그 몫이다.
 */
@Composable
fun MyScreen(
    onProfile: () -> Unit = {},
    onMembership: () -> Unit = {},
    onPurchase: () -> Unit = {},
    onSettings: () -> Unit = {},
) {
    val profile = myProfilePlaceholder
    val membership = myMembershipPlaceholder

    Column(Modifier.fillMaxSize()) {
        MyHeader(profile, onProfile, onSettings)

        Column(
            Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(bottom = MyFisSpacing.xxxl),
        ) {
            SectionTitle("멤버십", profile.branch, Modifier.padding(top = MyFisSpacing.lg))

            if (membership.daysLeft <= EXPIRY_SOON_DAYS) {
                ExpiryRow(onExtend = onPurchase)
            }

            MembershipCard(
                membership,
                Modifier.padding(
                    start = MyFisSpacing.screenHorizontal,
                    end = MyFisSpacing.screenHorizontal,
                    top = MyFisSpacing.sm,
                ),
            )

            MyFisListRow(
                "멤버십 관리",
                value = "유효 멤버십 ${membership.count}개",
                modifier = Modifier.padding(top = MyFisSpacing.sm),
                // TODO(M-06): 내 멤버십 화면이 붙으면 연결한다
                onClick = onMembership,
            )

            MyFisDivider(Modifier.padding(vertical = MyFisSpacing.md))

            // **이 화면에서 돈이 되는 유일한 줄**이라 라임을 여기 쓴다 (§3.2 액센트 2곳 예산)
            MyFisListRow(
                "멤버십 구매하기",
                titleColor = MyFisColor.Accent,
                chevron = true,
                // TODO(M-01 → M-03): 지점 선택 → 멤버십 구성으로 이어진다
                onClick = onPurchase,
                trailing = { MyFisSmallButton("지점 선택", onClick = onPurchase) },
            )

            MyFisDivider(Modifier.padding(vertical = MyFisSpacing.md))

            GroupLabel("결제")
            // TODO(M-07): 결제 내역이 붙으면 연결한다
            MyFisListRow("결제 내역", chevron = true, onClick = {})
            MyFisListRow("결제 수단 관리", chevron = true, onClick = {})
            // TODO(S-04): 교환권이 붙으면 연결한다
            MyFisListRow("교환권", value = "1장", onClick = {})
            // TODO(P-02): 마일리지 내역이 붙으면 연결한다. 표기는 앱 전체가 같은 것을 쓴다 (§3.3)
            MyFisListRow(
                "마일리지",
                onClick = {},
                chevron = true,
                trailing = {
                    MileageText(mileageBalancePlaceholder, style = MyFisTheme.type.bodySm)
                },
            )

            MyFisDivider(Modifier.padding(vertical = MyFisSpacing.md))

            GroupLabel("기록")
            // TODO(W-06 · C-05 · S-05): 각 기록 화면이 붙으면 연결한다
            MyFisListRow("운동 기록", chevron = true, onClick = {})
            MyFisListRow("유산소 기록", chevron = true, onClick = {})
            MyFisListRow("교환 내역", chevron = true, onClick = {})

            MyFisDivider(Modifier.padding(vertical = MyFisSpacing.md))

            // **설정 항목은 여기 없다** — 헤더 톱니(Y-03)가 가져갔다 (§6.38).
            // 알림 설정 · 약관 · 공개 범위 · 회원 탈퇴가 전부 그쪽이다
            GroupLabel("센터 안내")
            // TODO: 공지사항 · 고객 의견(🔵)이 붙으면 연결한다
            MyFisListRow("공지사항", chevron = true, onClick = {})
            MyFisListRow("고객 의견", chevron = true, onClick = {})
            MyFisListRow("앱 버전", value = APP_VERSION, chevron = false)

            MyFisDivider(Modifier.padding(vertical = MyFisSpacing.md))

            // 물러난 줄이라 `text.secondary` 다. **원본과 같이 한 줄만 남는다** —
            // 회원 탈퇴는 설정(Y-03)이 맡는다
            MyFisListRow("로그아웃", titleColor = MyFisColor.TextSecondary, onClick = {})
        }
    }
}

/**
 * 마이 헤더 (§6.9) — **왼쪽이 프로필, 오른쪽이 톱니**다 🟢 (2026-09-07, 사용자 지정).
 *
 * 화면 이름을 적지 않는다. 대신 왼쪽 자리를 **"누구인지"** 가 쓴다 —
 * 스토어·혜택의 마일리지 칩이 그 자리에서 하는 일과 같다.
 * 톱니 하나만 두니 왼쪽이 통째로 비어 **줄로 안 읽혔다** (사용자 지적).
 *
 * 알림(H-02)은 넣지 않는다 — 홈 헤더가 이미 들고 있어 길만 둘이 된다.
 */
@Composable
private fun MyHeader(profile: MyProfile, onProfile: () -> Unit, onSettings: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            // 아이콘 터치 영역만큼 빼서 글리프가 화면 여백(20) 선에 선다 (§6.9)
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Row(
            modifier = Modifier
                .clip(MyFisRadius.full)
                // TODO(Y-02): 프로필 수정 화면이 붙으면 연결한다
                .tapWithHaptics(interaction, onProfile)
                .padding(horizontal = MyFisSpacing.sm, vertical = MyFisSpacing.xs),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Avatar(profile.nickname)
            Text(
                profile.nickname,
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
                modifier = Modifier.padding(start = MyFisSpacing.sm),
            )
            Chevron(Modifier.padding(start = 2.dp), size = 16.dp)
        }

        Spacer(Modifier.weight(1f))
        // TODO(Y-03): 설정 화면이 붙으면 연결한다
        HeaderIcon(R.drawable.ic_header_settings, "설정", onSettings)
    }
}

/** TODO(서버): 프로필 사진이 오면 교체한다. 지금은 닉네임 첫 글자다 */
@Composable
private fun Avatar(nickname: String) {
    Box(
        Modifier
            .size(AVATAR)
            .clip(MyFisRadius.full)
            .background(MyFisColor.Surface2),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            nickname.take(1),
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextSecondary,
        )
    }
}

/** 묶음 제목 ↔ 오른쪽 곁말 (`멤버십` ↔ 지점 이름) */
@Composable
private fun SectionTitle(title: String, trailing: String?, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        if (trailing != null) {
            Text(trailing, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
        }
    }
}

/** 글자 줄 묶음의 머리 — 제목이 아니라 **꼬리표**라 `label` 이다 (§4.2) */
@Composable
private fun GroupLabel(text: String) {
    Text(
        text,
        style = MyFisTheme.type.label,
        color = MyFisColor.TextTertiary,
        modifier = Modifier.padding(
            start = MyFisSpacing.screenHorizontal,
            end = MyFisSpacing.screenHorizontal,
            top = MyFisSpacing.sm,
            bottom = MyFisSpacing.sm,
        ),
    )
}

/** 만료가 코앞일 때만 나오는 줄. **여기서만 danger 를 쓴다** — 상태 표시다 (§3.1) */
@Composable
private fun ExpiryRow(onExtend: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = MyFisSize.listRowMin)
            .tapWithHaptics(interaction, onExtend)
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // 느낌표는 **동그란 색 판 안에** 넣어 쓴다 — 토스트(§6.35)와 같은 판·같은 비율이다
        Box(
            Modifier
                .size(MyFisSpacing.xxl)
                .clip(MyFisRadius.full)
                .background(MyFisColor.Danger),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_alert),
                contentDescription = null,
                tint = MyFisColor.OnAccent,
                modifier = Modifier.size(ALERT_GLYPH),
            )
        }
        Text(
            "곧 만료되는 멤버십이 있어요",
            style = MyFisTheme.type.body,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(start = MyFisSpacing.sm),
        )
        Spacer(Modifier.weight(1f))
        Text("연장하기", style = MyFisTheme.type.body, color = MyFisColor.TextPrimary)
        Chevron(Modifier.padding(start = MyFisSpacing.xs))
    }
}

/**
 * 회원권 한 장 (원본의 `1일 이용권` 카드).
 *
 * 머리 줄이 **무엇을 얼마나** 남겼는지 말하고, 아래 두 칸이 **아직 안 산 것**을 판다.
 * 원본은 두 칸이 따로 판이고 버튼이 테두리형인데, 우리는 **테두리 버튼이 없다** (§6.1 5종) —
 * 카드 위에 세로 실선으로 나누고 `Small`(surface.2) 을 쓴다. 면이 하나 줄어 더 조용하다.
 */
@Composable
private fun MembershipCard(membership: MyMembership, modifier: Modifier = Modifier) {
    MyFisCard(modifier) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            // 카드에서 제일 먼저 읽혀야 하는 값이라 **한 단계 키운다** (§4.2 title.md,
            // 2026-09-07 사용자 지정). `title.sm` 이면 옆 `5일 남음` 과 무게가 비슷해 보였다
            Text(membership.name, style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
            Spacer(Modifier.weight(1f))
            Text(
                "${membership.daysLeft}일 남음",
                style = MyFisTheme.type.bodySm,
                color = if (membership.daysLeft <= EXPIRY_SOON_DAYS) {
                    MyFisColor.Danger
                } else {
                    MyFisColor.TextSecondary
                },
            )
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.lg),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
        ) {
            AddonSlot("락커", membership.locker, Modifier.weight(1f))
            AddonSlot("운동복", membership.apparel, Modifier.weight(1f))
        }
    }
}

/**
 * 산 것은 상태를 보여 주고, 안 산 것은 판다 (M-03 으로 간다).
 *
 * **카드 안의 `surface.2` 블록**이다 (§6.2 — 카드 안에 카드를 넣지 않는다).
 * 그래서 버튼은 `Small` 의 **테두리 변형**이다 — 같은 면끼리면 버튼이 판에 녹는다
 */
@Composable
private fun AddonSlot(label: String, state: String?, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface2)
            .padding(horizontal = MyFisSpacing.md, vertical = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(label, style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        if (state == null) {
            // TODO(M-03): 멤버십 구성 화면이 붙으면 연결한다
            MyFisSmallButton("구매하기", onClick = {}, outlined = true)
        } else {
            Text(state, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
        }
    }
}

/** 프로필 아바타 — **헤더 줄(56) 안**에 서므로 `32` 다. 톱니(24)와 무게가 맞는 크기 */
private val AVATAR = 32.dp

/** 느낌표 판 안의 글리프 — 토스트(§6.35)와 같은 값이다 */
private val ALERT_GLYPH = 14.dp

/** 며칠 남았을 때부터 `만료 임박` 인가 */
private const val EXPIRY_SOON_DAYS = 7

/** TODO: 빌드 정보에서 읽어 온다 */
private const val APP_VERSION = "0.1.0 (1)"

/** TODO(서버): 프로필 API 가 붙으면 지운다 (SPEC Y-01) */
internal data class MyProfile(val nickname: String, val branch: String)

internal val myProfilePlaceholder = MyProfile(nickname = "은후", branch = "MyFIS 역삼점")

/** TODO(서버): 내 멤버십 API 가 붙으면 지운다 (SPEC M-06) */
internal data class MyMembership(
    val name: String,
    val daysLeft: Int,
    /** 배정된 락커 번호. `null` 이면 안 샀다 */
    val locker: String?,
    /** 운동복 수령 상태. `null` 이면 안 샀다 */
    val apparel: String?,
    val count: Int,
)

internal val myMembershipPlaceholder = MyMembership(
    name = "3개월 회원권",
    daysLeft = 5,
    locker = null,
    apparel = null,
    count = 1,
)
