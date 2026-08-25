import SwiftUI

/// SPEC.md S-07 상품 검색 (DESIGN.md §6.9).
///
/// **검색은 화면을 띄운다** — 헤더의 검색 자리를 누르면 이 화면이 밀려 들어와 셸을 덮는다.
/// 안드로이드와 같은 방식이다. 검색은 목록을 훑는 일과 다른 일이라 자리를 따로 준다.
///
/// 들어오면 **키보드가 바로 올라온다.** 검색하러 들어온 사람에게 한 번 더 누르게 하지 않는다.

/// 필드 껍데기 — 누르는 자리(버튼)와 치는 자리(입력)가 **같은 판**이어야 바뀔 때 안 튄다
private struct SearchPill<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            Image("ic_header_search")
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(MyFisColor.textTertiary)
            content
        }
        .padding(.horizontal, MyFisSpacing.md)
        .frame(height: 40)
        .background(MyFisColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
    }
}

/// 상품 검색 화면 — 뒤로 + 입력 필드 + 결과.
struct StoreSearchScreen: View {
    var onBack: () -> Void = {}
    var onItem: (StoreItem) -> Void = { _ in }
    var balance: Int = StorePlaceholder.balance

    @State private var query = MyFisDebug.initialSearchQuery
    /// TODO(서버): 찜은 계정에 붙는다. 지금은 화면이 들고 있다
    @State private var liked: Set<Int> = []

    var body: some View {
        VStack(spacing: 0) {
            // 헤더 자리를 필드가 다 쓴다 (§6.9)
            HStack(spacing: 0) {
                HeaderIcon("ic_tab_back", "뒤로", action: onBack)
                StoreSearchInput(text: $query)
                    .padding(.leading, MyFisSpacing.sm)
            }
            .frame(height: MyFisSize.header)
            .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)

            StoreSearchResults(
                query: $query,
                balance: balance,
                liked: liked,
                onLike: { id in
                    if liked.contains(id) { liked.remove(id) } else { liked.insert(id) }
                },
                onItem: onItem
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

/// 검색 필드. 들어오면 **키보드가 바로 올라온다.**
///
/// 포커스는 **자기가 잡는다** — 셸에 `@FocusState` 를 두면 내비 바 안까지 닿지 않는다 (확인함).
struct StoreSearchInput: View {
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        SearchPill {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("상품 검색")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                }
                TextField("", text: $text)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .tint(MyFisColor.accent)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .focused($focused)
            }

            // 옆에 `취소` 가 있어도 지우개는 둔다 — 검색어만 바꿔 다시 치는 일이 더 잦다
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image("ic_header_clear")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.myFisTap)
                .foregroundStyle(MyFisColor.textTertiary)
                .accessibilityLabel("지우기")
            }
        }
        .onAppear { focused = true }
    }
}

/// 검색 모드의 본문 — 추천 검색어 · 결과 · 결과 없음.
struct StoreSearchResults: View {
    @Binding var query: String
    let balance: Int
    let liked: Set<Int>
    let onLike: (Int) -> Void
    let onItem: (StoreItem) -> Void

    private var results: [StoreItem] {
        StorePlaceholder.items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        Group {
            if query.isEmpty {
                suggestions
            } else if results.isEmpty {
                emptyResult
            } else {
                grid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// 빈 화면을 두지 않는다 — 아직 아무것도 안 쳤을 때는 **누를 거리**를 준다
    private var suggestions: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            Text("추천 검색어")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)

            HStack(spacing: MyFisSpacing.sm) {
                // TODO(서버): 추천 검색어는 서버가 고른다
                ForEach(StoreSearch.suggestions, id: \.self) { word in
                    Button { query = word } label: {
                        Text(word)
                            .font(MyFisFont.bodySm)
                            .foregroundStyle(MyFisColor.textPrimary)
                            .padding(.horizontal, MyFisSpacing.md)
                            .padding(.vertical, MyFisSpacing.sm)
                            .background(MyFisColor.surface2, in: Capsule())
                    }
                    .buttonStyle(.myFisTap)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.lg)
    }

    private var emptyResult: some View {
        VStack(spacing: MyFisSpacing.md) {
            Text("\u{2018}\(query)\u{2019} 검색 결과가 없어요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
            Button("검색어 지우기") { query = "" }
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textPrimary)
                .buttonStyle(.myFisTap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: StoreSearch.columns, spacing: MyFisSpacing.lg) {
                ForEach(results) { item in
                    ItemCard(
                        item: item,
                        balance: balance,
                        liked: liked.contains(item.id),
                        onLike: { onLike(item.id) },
                        onTap: { onItem(item) }
                    )
                }
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.top, MyFisSpacing.lg)
            .padding(.bottom, MyFisSpacing.xxxl)
        }
        // 스크롤을 시작하면 키보드를 내린다 — 결과를 보려는 참이다
        .scrollDismissesKeyboard(.immediately)
    }
}

enum StoreSearch {
    /// TODO(서버): 추천 검색어 API 가 붙으면 지운다
    static let suggestions = ["음료", "프로틴", "타월", "보틀", "매트"]

    static let columns = [
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
    ]

}
