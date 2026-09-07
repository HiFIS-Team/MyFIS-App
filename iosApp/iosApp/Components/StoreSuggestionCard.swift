import SwiftUI

/// 추천 상품 한 장 — 정사각 그림 자리 + 이름 + 마일리지.
///
/// 상품 상세(§6.21 `함께 보면 좋아요`)와 내 교환(§6.20 `바꿀 만한 것`)이
/// **같은 것을 각자 그리고 있었다** (2026-09-08 실측). 둘이 어긋나 있던 것도 있다 —
/// 자리값 아이콘이 한쪽은 `40`, 다른 쪽은 `44` 였다. 합치면서 `44` 로 맞췄다.
///
/// **크기는 부르는 쪽이 정한다** — 가로 캐러셀은 폭을 못 박고(`108`), 격자는 열이 나눈다.
///
/// ⚠️ 모델(`StoreItem`)을 받지 않고 **값만 받는다** — 안드로이드와 같은 규칙이다.
struct StoreSuggestionCard: View {
    let name: String
    let price: Int
    /// 폭을 못 박을 때만 준다. `nil` 이면 부모가 나눠 준 폭을 다 쓴다
    var width: CGFloat?
    var action: () -> Void = {}

    var body: some View {
        // TODO: 상세 → 상세 이동이 붙으면 연결한다
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .background(MyFisColor.surface2)
                    .overlay {
                        // TODO(서버): 상품 이미지가 오면 교체한다
                        Image("ic_tab_store")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(MyFisColor.surface3)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
                Text(name)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(1)
                    .padding(.top, MyFisSpacing.sm)
                MileageText(price)
                    .font(MyFisFont.titleSm)
                    .padding(.top, 2)
            }
            .frame(maxWidth: width ?? .infinity, alignment: .leading)
        }
        .buttonStyle(.myFisTap)
    }
}
