import SwiftUI

/// 검색 화면 공용 조각 (DESIGN.md §6.9).
///
/// **검색은 잎 화면이다** — 장바구니(S-06)·알림(H-02)과 **똑같은 라우트**다.
/// 그래서 하단 탭 바를 통째로 덮는 것도, 옆에서 밀려 들어오는 것도 잎이 알아서 한다.
///
/// 레퍼런스는 **당근 검색** 🟢 (2026-09-05, 사용자 지정) — 머리 한 줄에
/// `‹ 뒤로` · 필드 · `닫기` 가 나란히 서고, 아래는 **최근 검색**이다.
/// 구조만 가져오고 표면은 우리 토큰으로 쓴다 (§3.2).

// MARK: - 머리 한 줄

/// `‹` + 필드 + `닫기`. **제목을 두지 않는다** — 필드가 곧 제목이다.
struct SearchHeader: View {
    @Binding var text: String
    let placeholder: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            HeaderIcon("ic_tab_back", "뒤로", action: onBack)

            SearchField(text: $text, placeholder: placeholder, autoFocus: true)

            Button("닫기", action: onBack)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
                .buttonStyle(.myFisTap)
        }
        .padding(.leading, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
        .padding(.trailing, MyFisSpacing.screenHorizontal)
        .frame(height: MyFisSize.header)
    }
}

/// 검색 입력칸 — 앱에 **하나뿐이다** (§6.9). 스토어·모임·지역이 같이 쓴다.
/// 값은 §6.9 그대로 — 높이 `40` · `surface.2` · `radius.md` · 돋보기 `20` · 문구 `body.sm`.
struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    /// 들어오자마자 키보드를 올린다 — 검색하러 들어온 사람에게 한 번 더 누르게 하지 않는다
    var autoFocus: Bool = false

    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: MyFisSpacing.sm) {
            Image("ic_header_search")
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(MyFisColor.textTertiary)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
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

            // 닫기가 옆에 있어도 지우개는 둔다 — 검색어만 바꿔 다시 치는 일이 더 잦다
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
        .padding(.horizontal, MyFisSpacing.md)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(MyFisColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
        .onAppear { if autoFocus { focused = true } }
    }
}

// MARK: - 안 쳤을 때

/// 최근 검색 + (아직 없으면) 추천 검색어.
///
/// **빈 판을 두지 않는다** — 아직 아무것도 안 쳤을 때는 누를 거리를 준다.
struct SearchEmptyState: View {
    let recents: [String]
    let suggestions: [String]
    let onPick: (String) -> Void
    let onRemove: (String) -> Void
    let onClearAll: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if recents.isEmpty {
                    sectionTitle("추천 검색어", action: nil)
                    // TODO(서버): 추천 검색어는 서버가 고른다
                    FlowLayout(spacing: MyFisSpacing.sm) {
                        ForEach(suggestions, id: \.self) { word in
                            Button { onPick(word) } label: {
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
                } else {
                    sectionTitle("최근 검색", action: onClearAll)
                    ForEach(recents, id: \.self) { word in
                        RecentRow(word: word,
                                  onTap: { onPick(word) },
                                  onRemove: { onRemove(word) })
                    }
                }
            }
            .padding(.top, MyFisSpacing.lg)
            .padding(.bottom, MyFisSpacing.xxxl)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private func sectionTitle(_ title: String, action: (() -> Void)?) -> some View {
        HStack(spacing: MyFisSpacing.md) {
            Text(title)
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.textPrimary)
            Spacer(minLength: 0)
            if let action {
                Button("전체 삭제", action: action)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
                    .buttonStyle(.myFisTap)
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.bottom, MyFisSpacing.md)
    }
}

/// 최근 검색 한 줄 — 시계 + 검색어 + `✕`.
private struct RecentRow: View {
    let word: String
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: MyFisSpacing.md) {
            Button(action: onTap) {
                HStack(spacing: MyFisSpacing.md) {
                    Image("ic_time")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(MyFisColor.textTertiary)
                    Text(word)
                        .font(MyFisFont.body)
                        .foregroundStyle(MyFisColor.textPrimary)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.myFisTap)

            Button(action: onRemove) {
                Image("ic_header_close")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .frame(width: MyFisSize.minTouchTarget, height: MyFisSize.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.myFisTap)
            .foregroundStyle(MyFisColor.textTertiary)
            .accessibilityLabel("\(word) 지우기")
        }
        .padding(.leading, MyFisSpacing.screenHorizontal)
        .padding(.trailing, MyFisSpacing.screenHorizontal - MyFisSpacing.md)
        .frame(height: MyFisSize.listRowMin)
    }
}

/// 걸린 게 없을 때 — 두 검색 화면이 같은 글을 쓴다.
struct SearchNoResult: View {
    let query: String
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: MyFisSpacing.md) {
            Text("\u{2018}\(query)\u{2019} 검색 결과가 없어요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
            Button("검색어 지우기", action: onClear)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textPrimary)
                .buttonStyle(.myFisTap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 최근 검색 목록 — **셸이 들고 있다** (두 플랫폼 같다).
/// TODO(서버): 계정에 붙는다. 지금은 앱을 끄면 사라진다
struct SearchRecents {
    private(set) var words: [String] = MyFisDebug.initialRecents

    /// 같은 말을 다시 치면 **맨 위로 올라온다**. 열 개까지만 둔다
    mutating func add(_ word: String) {
        let trimmed = word.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        words.removeAll { $0 == trimmed }
        words.insert(trimmed, at: 0)
        if words.count > 10 { words.removeLast(words.count - 10) }
    }

    mutating func remove(_ word: String) { words.removeAll { $0 == word } }
    mutating func clear() { words.removeAll() }
}
