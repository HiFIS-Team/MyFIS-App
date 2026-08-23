import SwiftUI

/// DESIGN.md §6.7 하단 탭.
///
/// - 배경 surface.1, 상단 border.subtle 1px
/// - 활성 accent / 비활성 text.tertiary
/// - **라벨은 항상 표시한다.** 아이콘만으로는 헬스장 조명·짧은 시선에서 구분이 안 된다 (§9 이탈 #3)
/// - `이전` 탭은 성격이 다르므로 활성 색을 쓰지 않고 text.secondary 로 둔다
struct BottomTabBar<T: MyFisTab>: View {
    let tabs: [T]
    let selected: T
    var isExit: (T) -> Bool = { _ in false }
    let onSelect: (T) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(MyFisColor.borderSubtle)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    tabItem(tab)
                }
            }
            .padding(.top, MyFisSpacing.sm)
            .padding(.bottom, MyFisSpacing.xs)
        }
        // 배경만 하단 세이프에어리어까지 늘린다. 홈 인디케이터 영역이 검게 남으면
        // 탭 바가 떠 있는 것처럼 보인다.
        .background(MyFisColor.surface1.ignoresSafeArea(edges: .bottom))
    }

    private func tabItem(_ tab: T) -> some View {
        let tint: Color = isExit(tab)
            ? MyFisColor.textSecondary
            : (tab == selected ? MyFisColor.accent : MyFisColor.textTertiary)

        return Button {
            onSelect(tab)
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 20, weight: .regular))
                    .frame(height: 24)
                Text(tab.label)
                    .font(MyFisFont.caption)
            }
            .foregroundStyle(tint)
            // 터치 타겟 44pt 확보 (DESIGN.md §5.3)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
