import SwiftUI

/// SPEC.md S-07 상품 검색 (DESIGN.md §6.9).
///
/// **iOS 는 화면을 옮기지 않는다** — 검색 자리를 누르면 그 자리에서 헤더가 검색 모드로 갈린다.
/// 오른쪽 유리 알약(장바구니·마이)이 `취소` 로 바뀌고, 필드가 그 앞까지 늘어나고,
/// 본문만 검색 쪽으로 바뀐다. 하단 탭은 감춘다.
///
/// **툭 바뀐다.** 옆에서 밀려 나오는 연출을 넣지 않는다 — iOS 앱들이 그렇게 한다.
/// (Android 는 검색 화면이 밀려 들어온다. 그쪽 관습이 그렇다.)

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

/// 헤더의 검색 자리 — 평소 모습. 누르면 검색 모드로 들어간다.
///
/// **폭은 셸이 정해 준다.** 내비 바는 자식에게 남는 폭을 주지 않아서
/// `maxWidth: .infinity` 로는 늘어나지 않는다 (확인함).
struct StoreSearchField: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SearchPill {
                Text("상품 검색")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        // 판을 누르는 것에는 축소를 주지 않는다 — 진동만 (§6.7)
        .buttonStyle(.myFisTap)
        .accessibilityLabel("상품 검색")
    }
}

/// 검색 모드의 필드. 들어오면 **키보드가 바로 올라온다.**
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

    /// 시뮬레이터에는 키보드를 칠 수단이 없다. 검색 모드를 스크린샷으로 확인할 때
    /// `SIMCTL_CHILD_MYFIS_SEARCH=1`(빈 검색어) 또는 `=음료`(결과) 로 띄운다
    static var initialForDebug: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["MYFIS_SEARCH"] != nil
        #else
        false
        #endif
    }

    static var initialQueryForDebug: String {
        #if DEBUG
        let value = ProcessInfo.processInfo.environment["MYFIS_SEARCH"] ?? ""
        return value == "1" ? "" : value
        #else
        return ""
        #endif
    }
}
