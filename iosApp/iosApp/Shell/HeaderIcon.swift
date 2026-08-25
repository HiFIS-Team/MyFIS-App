import SwiftUI

/// **홈 헤더** (DESIGN.md §6.9).
///
/// - 왼쪽: 지점 (누르면 지점 선택 M-01)
/// - 오른쪽: 멤버십 (M-06) · 알림 (H-02)
///
/// 헤더는 셸이 아니라 **화면이 들고 있다.** 화면마다 다르기 때문이다 —
/// 스토어는 검색·장바구니·마이를 쓴다 (`StoreScreen`).
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
            // 워드마크는 양옆 아이콘 개수와 무관하게 **화면 정중앙**에 둔다.
            // HStack 안에 넣으면 좌우 아이콘 폭에 따라 중심이 밀린다.
            Wordmark()

            HStack(spacing: 0) {
                HeaderIcon("ic_header_branch", "지점", onBranch)
                Spacer()
                HStack(spacing: MyFisSpacing.xs) {
                    HeaderIcon("ic_header_membership", "멤버십", onMembership)
                    HeaderIcon("ic_header_notification", "알림", onNotification)
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }

}

/// 헤더의 아이콘 버튼. 홈·스토어 등 화면별 헤더가 같이 쓴다 (DESIGN.md §6.9).
struct HeaderIcon: View {
    let asset: String
    let label: String
    let action: () -> Void

    init(_ asset: String, _ label: String, _ action: @escaping () -> Void) {
        self.asset = asset
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(asset)
                // 터치 타겟 44pt (DESIGN.md §5.3). 아이콘은 26pt 지만 영역은 넉넉히 잡는다
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
        .foregroundStyle(MyFisColor.textPrimary)
        .accessibilityLabel(label)
    }
}
