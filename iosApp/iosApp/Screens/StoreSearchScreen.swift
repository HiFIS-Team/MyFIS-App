import SwiftUI

/// SPEC.md S-07 상품 검색 (DESIGN.md §6.9).
///
/// **검색은 화면을 띄운다** 🟢 (2026-08-25 결정) — 헤더의 검색 자리를 누르면 여기가 밀려 들어오고
/// **하단 탭까지 덮는다** (§7.1 잎 화면). 검색은 목록을 훑는 일과 다른 일이라 자리를 따로 준다.
///
/// 들어오면 **키보드가 바로 올라온다.** 검색하러 들어온 사람에게 한 번 더 누르게 하지 않는다.
struct StoreSearchScreen: View {
    var onItem: (StoreItem) -> Void = { _ in }

    @State private var query = ""
    /// TODO(서버): 찜은 계정에 붙는다. 지금은 화면이 들고 있다
    @State private var liked: Set<Int> = []
    @FocusState private var focused: Bool

    private var results: [StoreItem] {
        StorePlaceholder.items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            SearchResults(
                query: $query,
                results: results,
                balance: StorePlaceholder.balance,
                liked: liked,
                onLike: { id in
                    if liked.contains(id) { liked.remove(id) } else { liked.insert(id) }
                },
                onItem: onItem
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                // 뒤로 버튼 자리를 뺀 만큼만 쓴다 (§6.9 — 검색이 폭을 다 먹는다)
                StoreSearchField(query: $query, focused: $focused)
                    .frame(width: max(160, UIScreen.main.bounds.width - 96))
            }
        }
        .onAppear { focused = true }
    }
}

private struct SearchResults: View {
    @Binding var query: String
    let results: [StoreItem]
    let balance: Int
    let liked: Set<Int>
    let onLike: (Int) -> Void
    let onItem: (StoreItem) -> Void

    private let suggestions = ["음료", "프로틴", "타월", "보틀", "매트"]
    private let columns = [
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
    ]

    var body: some View {
        Group {
            if query.isEmpty {
                suggestionList
            } else if results.isEmpty {
                emptyState
            } else {
                grid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var suggestionList: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            Text("추천 검색어")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)
            FlowRow(items: suggestions) { word in
                Button {
                    query = word
                } label: {
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
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.top, MyFisSpacing.lg)
    }

    private var emptyState: some View {
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
            LazyVGrid(columns: columns, spacing: MyFisSpacing.lg) {
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

/// 칩을 줄 바꿔 흘려 놓는다. 개수가 적어 `Layout` 까지 만들지 않는다.
private struct FlowRow<Item: Hashable, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            ForEach(items, id: \.self) { content($0) }
        }
    }
}

/// 시뮬레이터에는 키보드를 칠 수단이 마땅치 않다. 검색 모드를 스크린샷으로 확인할 때
/// `SIMCTL_CHILD_MYFIS_SEARCH=1` (빈 검색) 또는 `=음료` (결과) 로 띄운다.
