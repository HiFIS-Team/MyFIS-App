import SwiftUI

/// 목록 한 줄 (DESIGN.md §6.5) — 높이 최소 `56`, 좌우는 화면 여백(`20`).
///
/// 마이(Y-01)·설정(Y-03)·내 멤버십(M-06) 처럼 **글자 한 줄 + 값 + 꺾쇠**가
/// 줄줄이 서는 화면이 앞으로 여럿이라 공용으로 둔다.
///
/// **꺾쇠는 값이 있는 줄에만 기본으로 붙는다** (레퍼런스 관행 · §6.5 "실제로 이동하는 행에만").
/// 값 없이 이동만 하는 줄은 `chevron: true` 로 켠다.
struct MyFisListRow<Trailing: View>: View {
    let title: String
    /// 오른쪽 값 — `앱 버전 0.1.0` 처럼 읽기만 하는 값도 여기 온다
    var value: String?
    var titleColor: Color = MyFisColor.textPrimary
    var titleFont: Font = MyFisFont.body
    var chevron: Bool?
    var action: (() -> Void)?
    /// 값 대신 넣는 것 — 버튼·마일리지 표기처럼 글자 한 줄로 안 되는 자리
    @ViewBuilder var trailing: Trailing

    private var showsChevron: Bool { chevron ?? (value != nil) }

    private var row: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(titleFont)
                .foregroundStyle(titleColor)

            Spacer(minLength: MyFisSpacing.md)

            trailing

            if let value {
                Text(value)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
                    .padding(.leading, MyFisSpacing.sm)
            }
            if showsChevron {
                Chevron().padding(.leading, MyFisSpacing.xs)
            }
        }
        .frame(minHeight: MyFisSize.listRowMin)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        if let action {
            MyFisTappable(label: title, action: action) { row }
        } else {
            row
        }
    }
}

extension MyFisListRow where Trailing == EmptyView {
    init(_ title: String,
         value: String? = nil,
         titleColor: Color = MyFisColor.textPrimary,
         titleFont: Font = MyFisFont.body,
         chevron: Bool? = nil,
         action: (() -> Void)? = nil) {
        self.init(title: title, value: value, titleColor: titleColor, titleFont: titleFont,
                  chevron: chevron, action: action) { EmptyView() }
    }
}

/// 구분선 (DESIGN.md §6.5) — **좌측 인덴트 없이 전체 너비**다
struct MyFisDivider: View {
    var body: some View {
        Rectangle()
            .fill(MyFisColor.borderSubtle)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}
