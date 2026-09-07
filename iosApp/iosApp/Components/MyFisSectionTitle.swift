import SwiftUI

/// 섹션 제목 (DESIGN.md §4.2 — 섹션 제목은 `title.md`).
///
/// 두 화면이 **같은 이름으로 각자** 그리고 있었다 (운동 상세 · 마이, 2026-09-08 실측).
/// 둘 다 `title.md` + `text.primary` 라 같은 것인데, 다른 건 **여백과 곁말**뿐이었다.
///
/// **여백은 여기서 주지 않는다** — 화면마다 다르므로 부르는 쪽이 붙인다.
struct MyFisSectionTitle: View {
    let title: String
    /// 오른쪽 곁말 — 마이의 지점 이름처럼 제목과 짝이 되는 값
    var trailing: String?

    init(_ title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            if let trailing {
                Spacer(minLength: MyFisSpacing.md)
                Text(trailing)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
