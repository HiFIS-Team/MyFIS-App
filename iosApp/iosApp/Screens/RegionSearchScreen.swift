import SwiftUI

/// SPEC.md G-03 모임 개설 — **활동 지역 설정** (DESIGN.md §6.31).
///
/// 개설 화면(§6.30)의 `검색` 칩으로 들어오는 잎이다. 레퍼런스는 **당근 활동 지역 설정**.
///
/// **칩 넷으로는 부족해서 있는 화면이다.** 개설 화면은 지점 둘레 동네만 보여 주는데,
/// 이 탭의 취지가 *회원이 헬스장에만 묶이지 않는 것* 이라 **딴 동네도 고를 수 있어야** 한다.
struct RegionSearchScreen: View {
    var onBack: () -> Void = {}
    var onPick: (String) -> Void = { _ in }

    @State private var query = ""

    private var results: [String] {
        let keyword = query.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty else { return GroupPlaceholder.nearbyRegions }
        return GroupPlaceholder.nearbyRegions.filter { $0.contains(keyword) }
    }

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: "활동 지역 설정", onBack: onBack)

            searchField
                .padding(.horizontal, MyFisSpacing.screenHorizontal)

            // **찾는 것보다 빠른 길이다.** 대개 지금 서 있는 동네가 답이라 목록보다 위에 둔다
            Button {} label: {
                HStack(spacing: MyFisSpacing.sm) {
                    Image("ic_header_branch")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 18, height: 18)
                    Text("현재 위치로 찾기")
                        .font(MyFisFont.body)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(MyFisColor.textSecondary)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .frame(height: MyFisSize.minTouchTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(.myFisTap)
            .padding(.top, MyFisSpacing.md)

            if results.isEmpty {
                empty
            } else {
                list
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// 스토어 검색과 **같은 판**이다 (§6.9) — 두 화면이 각자 그리면 그날로 어긋난다
    private var searchField: some View {
        StoreSearchShell {
            TextField("", text: $query,
                      prompt: Text("동명(읍,면)으로 검색 (ex. 치평동)")
                        .foregroundColor(MyFisColor.textTertiary))
                .font(MyFisFont.body)
                .foregroundStyle(MyFisColor.textPrimary)
                .tint(MyFisColor.accent)
                .submitLabel(.search)

            if !query.isEmpty {
                Button { query = "" } label: {
                    Image("ic_header_clear")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(MyFisColor.textTertiary)
                }
                .buttonStyle(.myFisIcon)
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(query.isEmpty ? "근처 동네" : "'\(query)' 검색 결과")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .padding(.horizontal, MyFisSpacing.screenHorizontal)
                    .padding(.vertical, MyFisSpacing.md)

                ForEach(results, id: \.self) { region in
                    Button { onPick(region) } label: {
                        HStack(spacing: MyFisSpacing.sm) {
                            Image("ic_place_pin")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(MyFisColor.textTertiary)
                            Text(GroupPlaceholder.fullName(region))
                                .font(MyFisFont.body)
                                .foregroundStyle(MyFisColor.textPrimary)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)
                        .frame(height: MyFisSize.listRowMin)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.myFisTap)
                }
            }
            .padding(.bottom, MyFisSpacing.xxxl)
        }
    }

    /// 빈 상태 — **무엇을 하라고 알려 준다.** 없다는 말만 두면 화면이 막다른 길이 된다
    private var empty: some View {
        VStack(spacing: 0) {
            Spacer(minLength: MyFisSpacing.giant)
            Text("검색 결과가 없어요.\n동네 이름을 다시 확인해주세요.")
                .font(MyFisFont.body)
                .foregroundStyle(MyFisColor.textTertiary)
                .multilineTextAlignment(.center)
            MyFisSmallButton(title: "다시 검색하기") { query = "" }
                .padding(.top, MyFisSpacing.xl)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}
