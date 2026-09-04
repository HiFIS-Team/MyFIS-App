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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.res.painterResource
import com.myfis.app.ui.components.MileageText
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.MyFisListRow
import com.myfis.app.ui.components.MyFisRowDivider
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisProgress
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

// TODO(서버): 회원권·교환권 API 가 붙으면 지운다 (SPEC M-06 · S-05)
private const val myNickname = "은후"
private const val myBranch = "광주 상무점"
private const val myMembership = "3개월 회원권"
private const val myTotalDays = 90
private const val myDaysLeft = 42
private const val myPeriod = "2026. 7. 1 ~ 2026. 10. 15"
private const val myLocker = "12번"
private const val myWear = "이용 중"
private const val myCoupons = 1
private const val myExchanges = 2

/** 만료가 코앞이면 카드 **위에** 한 줄이 뜬다 (§6.35) */
private const val myWarnWithin = 7

/**
 * 아바타 색 — **닉네임에서 계산한다** (P-07 레이더와 같은 규칙).
 *
 * ⚠️ 무작위가 아니다. 다시 그릴 때마다 색이 바뀌면 *내 색*이 아니게 된다 —
 * 출석 도장 기울기(§6.11)와 같은 이유로 **글자에서 뽑는다.** 두 플랫폼이 같은 식을 쓴다.
 * **라임은 팔레트에서 뺐다** — 그건 진행바(액센트)의 몫이라 얼굴 색으로 쓰면 예산이 겹친다
 */
private val myAvatarPalette = listOf(
    MyFisColor.CategoryViolet, MyFisColor.CategoryBlue, MyFisColor.CategoryCoral,
    MyFisColor.CategoryGreen, MyFisColor.CategoryGold, MyFisColor.CategoryTeal,
)

private val myAvatarColor: Color
    get() = myAvatarPalette[myNickname.sumOf { it.code } % myAvatarPalette.size]

/**
 * SPEC.md Y-01 마이 (DESIGN.md §6.35).
 *
 * 레퍼런스 셋을 **각각 다른 이유로** 뜯어 왔다 (사용자 지정).
 * - **버핏그라운드 MY** → 화면의 뼈대. *회원권이 주인공*이고 락커·운동복이 그 카드 안에 산다
 * - **마이배민** → *값이 있는 것들*(마일리지·교환권·쿠폰)을 한 카드에 모아 숫자를 오른쪽에 세운다
 * - **토스 설정** → 항목을 카드로 묶고 카드 사이를 띄워 그룹을 만든다. 다크에서 구분선보다 잘 읽힌다
 *
 * **회원권이 주인공인 이유** — 헬스장 앱 마이에 오는 이유가 *"며칠 남았지"* 다.
 * 마일리지를 주인공으로 두는 안도 있었지만 잔액은 홈·혜택·스토어가 **이미 세 번** 보여준다.
 */
@Composable
fun MyScreen(onSettings: () -> Unit = {}, daysLeft: Int = myDaysLeft) {
    Column(Modifier.fillMaxSize()) {
        MyHeader(onSettings)

        Column(
            modifier = Modifier
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.sm, bottom = MyFisSpacing.xxxl),
        ) {
            ProfileCard()

            MySectionTitle("멤버십")
            if (daysLeft <= myWarnWithin) ExpiryLine()
            MembershipCard(daysLeft)

            MySectionTitle("내 것")
            MyThingsCard()

            MySectionTitle("기록")
            RecordsCard()
        }
    }
}

/**
 * 다른 탭(§6.28 · §6.29 · §6.33)과 같은 꼴 — 화면 이름 `title.lg` + 오른쪽 아이콘.
 * **설정은 톱니 하나로 뺐다** (사용자 지정) — 자주 가는 곳이 아니라 목록을 먹을 이유가 없다
 */
@Composable
private fun MyHeader(onSettings: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("마이", style = MyFisTheme.type.titleLg, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        HeaderIcon(R.drawable.ic_header_settings, "설정", onSettings)
    }
}

@Composable
private fun MySectionTitle(text: String) {
    Text(
        text,
        style = MyFisTheme.type.titleMd,
        color = MyFisColor.TextPrimary,
        modifier = Modifier.padding(top = MyFisSpacing.sectionGap, bottom = MyFisSpacing.md),
    )
}

/** 프로필 — **사진을 쓰지 않는다.** 색 원 + 닉네임 첫 글자 (SPEC P-07 프라이버시) */
@Composable
private fun ProfileCard() {
    // TODO(Y-02): 누르면 프로필 수정으로 간다
    MyFisCard {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
        ) {
            Box(
                modifier = Modifier.size(MyFisSize.listRowMin).background(myAvatarColor, CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    myNickname.take(1),
                    style = MyFisTheme.type.titleMd,
                    color = MyFisColor.BgBase,
                )
            }
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
            ) {
                Text(myNickname, style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
                Text(myBranch, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
            }
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(20.dp).rotate(-90f),
            )
        }
    }
}

/**
 * 만료 경고 — **카드 위 한 줄**이다. 카드 안에 넣으면 카드가 시끄러워진다 (버핏그라운드와 같은 자리).
 * 아이콘을 만들지 않았다 — `danger` 글자가 이미 경고다 (§8 은 그림을 늘리지 말라고 한다)
 */
@Composable
private fun ExpiryLine() {
    // TODO(M-04): 연장 결제로 간다
    Row(
        modifier = Modifier.fillMaxWidth().padding(bottom = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
    ) {
        Text(
            "곧 만료되는 회원권이 있어요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.Danger,
            modifier = Modifier.weight(1f),
        )
        Text("연장하기", style = MyFisTheme.type.bodySm, color = MyFisColor.TextPrimary)
    }
}

/** 이 화면의 주인공 (§2 원칙 1) — **남은 날이 제일 큰 숫자**다 */
@Composable
private fun MembershipCard(daysLeft: Int) {
    // TODO(M-06): 누르면 회원권 관리로 간다
    MyFisCard(shape = MyFisRadius.lg) {
        Text(myMembership, style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)

        Row(
            modifier = Modifier.padding(top = MyFisSpacing.sm),
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Text(
                "$daysLeft",
                style = MyFisTheme.type.metricLg,
                color = if (daysLeft <= myWarnWithin) MyFisColor.Danger else MyFisColor.TextPrimary,
            )
            Text(
                "일 남음",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.padding(bottom = MyFisSpacing.sm),
            )
        }

        MyFisProgress(
            daysLeft.toFloat() / myTotalDays,
            Modifier.padding(top = MyFisSpacing.sm),
        )

        Text(
            myPeriod,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
            modifier = Modifier.padding(top = MyFisSpacing.md),
        )

        // 락커·운동복은 **회원권에 딸린 것**이라 같은 카드 안에 산다 (버핏그라운드와 같은 판단)
        MyFisRowDivider(Modifier.padding(vertical = MyFisSpacing.lg))

        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Attachment("락커", myLocker)
            Spacer(Modifier.weight(1f))
            Attachment("운동복", myWear)
        }
    }
}

@Composable
private fun Attachment(label: String, value: String) {
    Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm)) {
        Text(label, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
        Text(value, style = MyFisTheme.type.bodySm, color = MyFisColor.TextPrimary)
    }
}

/** **값이 있는 것들을 한 덩어리로** (마이배민에서 가져온 것) — 흩어져 있으면 세 번 찾아야 한다 */
@Composable
private fun MyThingsCard() {
    // TODO(P-02 · S-05): 각각 내역 화면으로 간다
    MyFisCard {
        // 포인트 표기는 앱 전체가 한 규칙을 쓴다 (§3.3) — 글자로 찍지 않는다
        MyFisListRow("마일리지", accessory = {
            MileageText(benefitBalancePlaceholder, style = MyFisTheme.type.bodySm)
        })
        MyFisRowDivider()
        MyFisListRow("교환권", "${myExchanges}장")
        MyFisRowDivider()
        MyFisListRow("쿠폰", "${myCoupons}장")
    }
}

/**
 * 기록은 **자리만 잡는다** (사용자 지정) — 누르면 아직 안 간다.
 * `체성분 기록` 은 인바디 연동(SPEC §7.6)이 붙으면 채워진다
 */
@Composable
private fun RecordsCard() {
    // TODO(W-06 · C-05 · M-07): 각각 기록 화면으로 간다
    MyFisCard {
        MyFisListRow("운동 기록")
        MyFisRowDivider()
        MyFisListRow("유산소 기록")
        MyFisRowDivider()
        MyFisListRow("체성분 기록")
        MyFisRowDivider()
        MyFisListRow("결제 내역")
    }
}
