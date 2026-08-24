import SwiftUI

/// 워드마크 — `My` 는 흰색, `FIS` 는 액센트.
///
/// 서체는 Quicksand Bold. 본문 서체(Pretendard)와 다른 유일한 자리다.
/// 액센트를 쓰는 곳이므로 **같은 화면에서 액센트 사용 예산 1칸을 차지한다** (DESIGN.md §2 원칙 3).
struct Wordmark: View {
    var body: some View {
        (
            Text("My").foregroundStyle(MyFisColor.textPrimary)
                + Text("FIS").foregroundStyle(MyFisColor.accent)
        )
        .font(MyFisFont.wordmark)
    }
}
