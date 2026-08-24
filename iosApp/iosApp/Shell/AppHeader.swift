import SwiftUI

/// 화면 상단 헤더.
///
/// - 왼쪽: 지점 (누르면 지점 선택 M-01)
/// - 오른쪽: 멤버십 (M-06) · 알림 (H-02)
///
/// 아이콘은 DESIGN.md §8 아웃라인 1.5px 규칙을 따른다.
/// 하단 탭과 달리 시스템 컴포넌트가 아니므로 **두 플랫폼이 같은 벡터**를 쓴다.
struct AppHeader: View {
    var onBranch: () -> Void = {}
    var onMembership: () -> Void = {}
    var onNotification: () -> Void = {}

    var body: some View {
        ZStack {
            // 워드마크는 양옆 아이콘 개수와 무관하게 **화면 정중앙**에 둔다.
            // HStack 안에 넣으면 좌우 아이콘 폭에 따라 중심이 밀린다.
            Wordmark()

            HStack(spacing: 0) {
                headerIcon("ic_header_branch", "지점", onBranch)
                Spacer()
                HStack(spacing: MyFisSpacing.xs) {
                    headerIcon("ic_header_membership", "멤버십", onMembership)
                    headerIcon("ic_header_notification", "알림", onNotification)
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }

    private func headerIcon(_ asset: String, _ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset)
                // 터치 타겟 44pt (DESIGN.md §5.3). 아이콘은 26pt 지만 영역은 넉넉히 잡는다
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(MyFisColor.textPrimary)
        .accessibilityLabel(label)
    }
}
