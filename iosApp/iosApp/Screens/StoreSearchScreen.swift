import SwiftUI

/// SPEC.md S-07 상품 검색 — **잎 화면이다** 🟢 (2026-09-05, 사용자 지정).
///
/// 장바구니(S-06)·알림(H-02)과 **똑같은 라우트**라 하단 탭 바를 통째로 덮는다.
/// 레퍼런스는 당근 검색 — 머리 한 줄에 `‹` · 필드 · `닫기`, 아래는 최근 검색이다 (§6.9).
///
/// ⚠️ **스토어 탭에서는 이 잎으로 오지 않는다** (2026-09-15, 크림) — 스토어 머리의 시스템 검색창이 제자리에서 켜진다.
/// 지금은 상품 상세(S-02)의 검색 버튼만 여기로 온다. 아래 판(`StoreSearchResults`)은 둘이 같이 쓴다
struct StoreSearchScreen: View {
    @Binding var liked: Set<Int>
    @Binding var recents: SearchRecents
    var onBack: () -> Void = {}
    var onItem: (StoreItem) -> Void = { _ in }
    var onLike: (Int) -> Void = { _ in }

    @State private var query = MyFisDebug.searchQuery

    var body: some View {
        VStack(spacing: 0) {
            SearchHeader(text: $query, placeholder: "상품 검색", onBack: onBack)
            StoreSearchResults(query: $query, recents: $recents, liked: liked, onItem: onItem, onLike: onLike)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // **검색 잎은 시스템 내비 바를 숨긴다** — 필드가 곧 머리라 바에 올릴 게 없다 (§6.9 · §7.1)
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// 상품 검색 판 — **스토어 머리 검색**(S-01)과 검색 잎(S-07)이 같이 쓴다 (금지 6).
///
/// 안 쳤으면 최근 · 추천, 걸린 게 없으면 안내, 있으면 상품 그리드
struct StoreSearchResults: View {
    @Binding var query: String
    @Binding var recents: SearchRecents
    let liked: Set<Int>
    let onItem: (StoreItem) -> Void
    let onLike: (Int) -> Void

    private var results: [StoreItem] {
        StorePlaceholder.items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    private let columns = [
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
    ]

    var body: some View {
        if query.isEmpty {
            SearchEmptyState(
                recents: recents.words,
                suggestions: StoreSearchWords.suggestions,
                onPick: { pick($0) },
                onRemove: { recents.remove($0) },
                onClearAll: { recents.clear() }
            )
        } else if results.isEmpty {
            SearchNoResult(query: query) { query = "" }
        } else {
            grid
        }
    }

    /// 눌러서 들어온 말도 **최근 검색에 남는다** — 친 것과 다를 이유가 없다
    private func pick(_ word: String) {
        query = word
        recents.add(word)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: MyFisSpacing.lg) {
                ForEach(results) { item in
                    ItemCard(
                        item: item,
                        balance: StorePlaceholder.balance,
                        liked: liked.contains(item.id),
                        onLike: { onLike(item.id) },
                        onTap: { recents.add(query); onItem(item) }
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

enum StoreSearchWords {
    /// TODO(서버): 추천 검색어 API 가 붙으면 지운다
    static let suggestions = ["음료", "프로틴", "타월", "보틀", "매트"]
}
