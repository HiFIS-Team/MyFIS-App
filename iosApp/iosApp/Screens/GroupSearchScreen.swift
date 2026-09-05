import SwiftUI

/// SPEC.md G-01 모임 검색 — 상품 검색(S-07)과 **같은 꼴의 잎 화면**이다.
///
/// 모임 헤더의 돋보기로 들어온다. 전에는 그 돋보기가 **셸에 안 이어져 있어 눌러도 아무 일이 없었다**.
struct GroupSearchScreen: View {
    @Binding var recents: SearchRecents
    var onBack: () -> Void = {}
    var onGroup: (GroupItem) -> Void = { _ in }

    @State private var query = MyFisDebug.groupSearchQuery

    /// **이름 · 갈래 · 지역**으로 찾는다.
    ///
    /// 한 줄 소개는 안 본다 — `출근 전에 한 바퀴` 같은 문장까지 걸면
    /// **왜 걸렸는지 줄만 봐서는 알 수 없는 결과**가 섞인다. 걸린 이유가 줄에 보여야 한다.
    /// TODO(서버): 검색은 서버가 한다 (SPEC §8)
    private var results: [GroupItem] {
        GroupPlaceholder.groups.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.category.title.localizedCaseInsensitiveContains(query)
                || $0.region.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchHeader(text: $query, placeholder: "모임 검색", onBack: onBack)

            if query.isEmpty {
                SearchEmptyState(
                    recents: recents.words,
                    suggestions: GroupSearchWords.suggestions,
                    onPick: { query = $0; recents.add($0) },
                    onRemove: { recents.remove($0) },
                    onClearAll: { recents.clear() }
                )
            } else if results.isEmpty {
                SearchNoResult(query: query) { query = "" }
            } else {
                list
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(results) { group in
                    GroupRow(group: group, onTap: { recents.add(query); onGroup(group) })
                }
            }
            .padding(.top, MyFisSpacing.md)
            .padding(.bottom, MyFisSpacing.xxxl)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

enum GroupSearchWords {
    /// TODO(서버): 추천 검색어 API 가 붙으면 지운다.
    /// **다 걸리는 말로 골랐다** — 눌렀는데 결과가 없으면 추천이 아니다
    static let suggestions = ["러닝", "웨이트", "클래스", "등산", "치평동"]
}
