import SwiftUI

/// 홈 헤더의 **핀으로 들어오는 잎 화면** — 지금은 빈 껍데기다.
///
/// 길만 먼저 뚫어 뒀다 (셸을 덮고 오른쪽에서 밀려 들어온다, DESIGN.md §7.1).
/// 🔵 무엇을 담을지는 미정이다 — SPEC M-01 지점 선택이 후보지만 확정 아니다.
struct BranchScreen: View {
    var onBack: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: nil, onBack: onBack)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
