package com.myfis.app.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import com.myfis.app.R

/**
 * DESIGN.md §4 타이포그래피.
 *
 * metric* 은 숫자 전용 스케일이다. 변하는 숫자는 반드시 tabular("tnum")를 켠다 —
 * 세트 카운트가 바뀔 때 자릿수 때문에 레이아웃이 흔들리면 안 된다.
 */
/**
 * Pretendard Std (KS X 1001 서브셋, OFL-1.1 — LICENSES/OFL-Pretendard.txt).
 * 한글·영문·숫자가 한 가족이라 섞인 문장에서 무게감이 어긋나지 않는다.
 * 서브셋에 없는 희귀 음절은 시스템 폰트로 폴백된다.
 */
private val MyFisFontFamily = FontFamily(
    Font(R.font.pretendard_regular, FontWeight.Normal),
    Font(R.font.pretendard_medium, FontWeight.Medium),
    Font(R.font.pretendard_semibold, FontWeight.SemiBold),
    Font(R.font.pretendard_bold, FontWeight.Bold),
)

private const val TABULAR = "tnum"

/**
 * 워드마크 전용 서체 — Kanit Bold Italic (OFL-1.1, LICENSES/OFL-Kanit.txt).
 * 기울어져 있어 움직이는 느낌이 난다. 본문 서체(Pretendard)와 별개이며 **로고에만 쓴다.**
 */
private val WordmarkFontFamily = FontFamily(Font(R.font.kanit_bold_italic, FontWeight.Bold))

@Immutable
data class MyFisTypography(
    val metricXl: TextStyle,
    val metricLg: TextStyle,
    val metricMd: TextStyle,
    /** 활동 랜딩(§6.25) 제목 전용 — 두 줄짜리 큰 문장 */
    val display: TextStyle,
    val titleLg: TextStyle,
    val titleMd: TextStyle,
    val titleSm: TextStyle,
    val body: TextStyle,
    val bodySm: TextStyle,
    val label: TextStyle,
    val caption: TextStyle,
    /** 워드마크(MyFIS) 전용. 로고 외에는 쓰지 않는다 */
    val wordmark: TextStyle,
)

internal val myFisTypography = MyFisTypography(
    metricXl = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 56.sp,
        lineHeight = 60.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = (-0.02).em,
        fontFeatureSettings = TABULAR,
    ),
    metricLg = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 40.sp,
        lineHeight = 44.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = (-0.02).em,
        fontFeatureSettings = TABULAR,
    ),
    metricMd = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 28.sp,
        lineHeight = 32.sp,
        fontWeight = FontWeight.SemiBold,
        letterSpacing = (-0.02).em,
        fontFeatureSettings = TABULAR,
    ),
    display = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 32.sp,
        lineHeight = 42.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = (-0.02).em,
    ),
    titleLg = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        fontWeight = FontWeight.Bold,
    ),
    titleMd = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 20.sp,
        lineHeight = 28.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    titleSm = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 17.sp,
        lineHeight = 24.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    body = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        fontWeight = FontWeight.Normal,
    ),
    bodySm = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        fontWeight = FontWeight.Normal,
    ),
    label = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 13.sp,
        lineHeight = 16.sp,
        fontWeight = FontWeight.Medium,
    ),
    caption = TextStyle(
        fontFamily = MyFisFontFamily,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        fontWeight = FontWeight.Normal,
    ),
    wordmark = TextStyle(
        fontFamily = WordmarkFontFamily,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = (-0.01).em,
    ),
)
