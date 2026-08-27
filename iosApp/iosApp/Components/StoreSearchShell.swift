import SwiftUI

/// 스토어 검색 판 (DESIGN.md §6.9).
///
/// **누르는 자리(스토어 헤더)와 치는 자리(검색 모드)가 같은 판이어야 바뀔 때 안 튄다.**
/// §6.9 가 그렇게 못 박아 뒀는데도 두 화면이 **각자 그리고 있었다** (2026-08-27 실측) —
/// 값이 우연히 같았을 뿐이라 한쪽만 고치면 그날로 어긋난다. 그래서 판을 여기 한 벌로 모은다.
///
/// 판만 맡는다. 안에 무엇이 들어가는지는 쓰는 쪽이 정한다 —
/// 헤더는 `상품 검색` 글자, 검색 모드는 입력칸과 지우개다.
struct StoreSearchShell<Content: View>: View {
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
        .frame(maxWidth: .infinity)
        .background(MyFisColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
    }
}
