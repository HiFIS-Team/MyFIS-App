package com.myfis.app.ui.screens

import androidx.annotation.DrawableRes
import com.myfis.app.R

/**
 * 스토어 자리값 데이터. SPEC.md §5 S-01.
 *
 * TODO(서버): 상품·마일리지 API 가 아직 없다. 화면을 먼저 세우려고 자리값을 둔다.
 * 붙으면 이 파일의 `*Placeholder` 만 지우면 된다.
 */
enum class StoreCategory(val label: String) {
    ALL("전체"),
    DRINK("음료수"),
    CAFFEINE("카페인"),
    PROTEIN("프로틴"),
    GOODS("굿즈"),
}

/** 상단 배너 한 장 */
data class StoreBanner(
    val id: Int,
    val title: String,
    val body: String,
    @DrawableRes val icon: Int,
)

/**
 * 마일리지를 모으는 길 하나. SPEC.md §5 P-03 ~ P-10 과 1:1 이다.
 *
 * TODO: 스토어에 잠깐 뒀다가 뺐다 (자리를 필터에 내줬다). **혜택 탭 P-04 미니 이벤트 허브**가 쓸 자리다.
 */
data class StoreQuest(
    val id: Int,
    val label: String,
    @DrawableRes val icon: Int,
    val reward: Int,
    /** TODO: 해당 화면이 붙으면 연결한다 */
    val destination: String,
)

/** 교환 상품 하나 */
data class StoreItem(
    val id: Int,
    val name: String,
    val price: Int,
    val category: StoreCategory,
    /** 이 상품을 본 사람 수 */
    val views: Int,
    val rating: Double,
    val reviewCount: Int,
    val soldOut: Boolean = false,
)

/** TODO(서버): `MileageAccount.balance` */
const val mileageBalancePlaceholder = 1_240

val storeBannerPlaceholder = listOf(
    StoreBanner(1, "쌓인 마일리지로\n한 잔 바꾸기", "아메리카노 400 P 부터", R.drawable.ic_tab_store),
    StoreBanner(2, "이번 주 새 굿즈\n스포츠 타월", "1,200 P · 지점 수령", R.drawable.ic_tab_benefit),
    StoreBanner(3, "출석 5일 채우면\n보너스 500 P", "이번 주 3일 남았어요", R.drawable.ic_quest_attend),
)

val storeQuestPlaceholder = listOf(
    StoreQuest(1, "출석 체크", R.drawable.ic_quest_attend, 50, "P-03"),
    StoreQuest(2, "출석판", R.drawable.ic_quest_board, 10, "P-05"),
    StoreQuest(3, "카드긁기", R.drawable.ic_header_membership, 30, "P-06"),
    StoreQuest(4, "스트레칭", R.drawable.ic_tab_cardio, 20, "P-09"),
    StoreQuest(5, "체중 기록", R.drawable.ic_quest_scale, 10, "P-08"),
    StoreQuest(6, "인스타 인증", R.drawable.ic_quest_camera, 100, "P-10"),
)

val storeItemPlaceholder = listOf(
    StoreItem(1, "이온음료 500ml", 300, StoreCategory.DRINK, 12_400, 4.6, 218),
    StoreItem(2, "제로 콜라 250ml", 250, StoreCategory.DRINK, 8_300, 4.4, 96),
    StoreItem(3, "아메리카노", 400, StoreCategory.CAFFEINE, 23_100, 4.8, 512),
    StoreItem(4, "콜드브루", 500, StoreCategory.CAFFEINE, 6_400, 4.7, 143),
    StoreItem(5, "프로틴 쉐이크", 600, StoreCategory.PROTEIN, 31_000, 4.5, 874),
    StoreItem(6, "단백질 바", 700, StoreCategory.PROTEIN, 15_200, 4.3, 331),
    StoreItem(7, "MyFIS 스포츠 타월", 1_200, StoreCategory.GOODS, 4_100, 4.9, 64),
    StoreItem(8, "쉐이커 보틀", 1_500, StoreCategory.GOODS, 9_800, 4.6, 205),
    StoreItem(9, "헬스 장갑", 2_400, StoreCategory.GOODS, 2_700, 4.2, 38, soldOut = true),
    StoreItem(10, "요가 매트", 5_000, StoreCategory.GOODS, 5_600, 4.7, 121),
)

/** `1,240 P` */
fun Int.toMileage(): String = "%,d P".format(this)

/** `1.2만 명` · `724 명` — 만 단위부터는 자릿수를 줄인다. 정확한 수보다 "많다"가 읽히면 된다 */
fun Int.toViewCount(): String = when {
    this >= 10_000 -> "%s만 명".format("%.1f".format(this / 10_000.0).removeSuffix(".0"))
    else -> "%,d 명".format(this)
}

/**
 * 리뷰 한 건. SPEC.md §5 S-02.
 *
 * TODO(서버): 리뷰 API 가 붙으면 지운다.
 */
data class StoreReview(
    val id: Int,
    val author: String,
    val date: String,
    val rating: Int,
    val body: String,
    val helpful: Int,
)

/** TODO(서버): 리뷰 API 가 붙으면 지운다 */
val storeReviewPlaceholder = listOf(
    StoreReview(1, "김*훈", "8월 20일", 5, "운동 끝나고 바로 마시기 딱 좋아요. 데스크에서 받는 것도 금방이고요", 3),
    StoreReview(2, "이*연", "8월 17일", 4, "가볍게 마시기 좋은데 차가운 게 남아 있을 때가 더 좋아요", 1),
    StoreReview(3, "박*수", "8월 11일", 5, "마일리지로 바꾸니까 운동 가는 맛이 있네요", 7),
)
