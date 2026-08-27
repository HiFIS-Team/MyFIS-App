import SwiftUI

/// SPEC.md S-07 상품 검색 (DESIGN.md §6.9).
///
/// **검색은 화면이 아니라 스토어의 모드다** 🟢 (2026-08-26) — 헤더의 검색 자리를 누르면
/// 그 자리에서 필드가 장바구니 자리까지 늘어나고, 마이가 `X` 로 바뀌고, 본문만 검색으로 바뀐다.
/// 화면이 옆에서 밀려 들어오지 않는다 — **검색은 다른 데로 가는 일이 아니라 지금 화면을 좁히는 일**이다.
///
/// 여기에는 필드(`StoreSearchInput`)와 본문(`StoreSearchResults`)만 있다. 헤더는 스토어가 그린다.
///
/// 열면 **키보드가 바로 올라온다.** 검색하러 누른 사람에게 한 번 더 누르게 하지 않는다.

/// 검색 필드. 들어오면 **키보드가 바로 올라온다.**
///
/// 포커스는 **자기가 잡는다** — 셸에 `@FocusState` 를 두면 내비 바 안까지 닿지 않는다 (확인함).
struct StoreSearchInput: View {
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        StoreSearchShell {
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
