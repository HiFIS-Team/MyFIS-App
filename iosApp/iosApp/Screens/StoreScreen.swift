import SwiftUI

/// SPEC.md S-01 스토어 홈. (레퍼런스: 무신사)
///
/// 홈과 헤더가 다르다 — 스토어에서 필요한 건 지점·알림이 아니라 **검색 · 장바구니 · 마이**다.
struct StoreScreen: View {
    var onSearch: () -> Void = {}
    var onCart: () -> Void = {}
    var onMy: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            StoreHeader(onSearch: onSearch, onCart: onCart, onMy: onMy)
            // TODO: 보유 마일리지 · 카테고리 · 상품 그리드가 붙으면 교체한다 (SPEC S-01).
            PlaceholderScreen(
                id: "S-01",
                title: "스토어",
                description: "마일리지로 굿즈·음료 교환"
            )
        }
    }
}

/// 스토어 헤더 (DESIGN.md §6.9).
///
/// 검색이 폭을 다 먹고 오른쪽에 장바구니 · 마이만 둔다.
/// **워드마크를 넣지 않는다** — 검색이 들어오면 가운데 자리가 없다.
private struct StoreHeader: View {
    let onSearch: () -> Void
    let onCart: () -> Void
    let onMy: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            SearchField(onTap: onSearch)
                .padding(.leading, MyFisSpacing.sm)
                .padding(.trailing, MyFisSpacing.xs)
            HeaderIcon("ic_header_cart", "장바구니", onCart)
            HeaderIcon("ic_header_my", "마이", onMy)
        }
        .frame(height: 56)
        // 아이콘의 터치 영역이 화면 여백만큼 튀어나오므로 그만큼 당겨 준다 (§6.9)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }
}

/// 누르면 검색 화면으로 간다. 여기서 바로 입력받지 않는다 —
/// 헤더에서 키보드가 올라오면 목록이 반쯤 가린 채로 타이핑하게 된다.
private struct SearchField: View {
    let onTap: () -> Void

    private let height: CGFloat = 40

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MyFisSpacing.sm) {
                Image("ic_header_search")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("상품 검색")
                    .font(MyFisFont.bodySm)
                Spacer(minLength: 0)
            }
            .foregroundStyle(MyFisColor.textTertiary)
            .padding(.horizontal, MyFisSpacing.md)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(MyFisColor.surface2, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("상품 검색")
    }
}
