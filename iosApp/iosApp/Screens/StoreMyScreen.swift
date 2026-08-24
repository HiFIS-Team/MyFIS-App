import SwiftUI

/// SPEC.md S-08 스토어 마이.
///
/// **마이 탭(Y-01)과 다른 화면이다.** 여기는 스토어 안에서의 나 —
/// 교환권(S-04) · 교환 내역(S-05) · 장바구니(S-06) 처럼 **교환에 관한 것만** 모인다.
/// 프로필·기록·설정은 마이 탭이 맡는다.
///
/// 스토어 헤더에서 **오른쪽에서 왼쪽으로 밀려 들어온다** (잎 화면, DESIGN.md §7.1).
struct StoreMyScreen: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()
            // TODO: 보유 마일리지 · 교환권 · 교환 내역 · 장바구니가 붙으면 교체한다 (SPEC S-08).
            PlaceholderScreen(
                id: "S-08",
                title: "스토어 마이",
                description: "교환권 · 교환 내역 · 장바구니"
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 알림함과 같은 규칙 — 스택의 루트라 뒤로 버튼을 직접 넣되 자리는 시스템 툴바를 쓴다.
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("뒤로")
            }
            ToolbarItem(placement: .principal) {
                Text("스토어 마이")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
            }
        }
    }
}
