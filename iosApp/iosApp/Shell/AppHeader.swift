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
    /// 콘텐츠 위에 떠 있는 상태. 아이콘이 유리 알약으로 바뀐다 (§6.17)
    var glass: Bool = false

    var body: some View {
        ZStack {
            // 워드마크는 양옆 아이콘 개수와 무관하게 **화면 정중앙**에 둔다.
            // HStack 안에 넣으면 좌우 아이콘 폭에 따라 중심이 밀린다.
            Wordmark()
                .padding(.horizontal, MyFisSpacing.md)
                .padding(.vertical, MyFisSpacing.sm)
                // 떠 있을 때는 워드마크도 유리에 앉힌다 — 카드 글씨 위에 그냥 얹으면 겹쳐서 안 읽힌다
                .background { if glass { GlassChrome().transition(.opacity) } }

            HStack(spacing: 0) {
                HeaderIcon("ic_header_branch", "지점", onBranch, glass: glass)
                Spacer()
                HStack(spacing: MyFisSpacing.xs) {
                    HeaderIcon("ic_header_membership", "멤버십", onMembership, glass: glass)
                    HeaderIcon("ic_header_notification", "알림", onNotification, glass: glass)
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
    /// 콘텐츠 위에 떠 있을 때만 유리 알약을 깐다 (§6.17)
    var glass: Bool = false

    init(_ asset: String, _ label: String, _ action: @escaping () -> Void, glass: Bool = false) {
        self.asset = asset
        self.label = label
        self.action = action
        self.glass = glass
    }

    var body: some View {
        Button(action: action) {
            Image(asset)
                // 터치 타겟 44pt (DESIGN.md §5.3). 아이콘은 26pt 지만 영역은 넉넉히 잡는다
                .frame(width: 44, height: 44)
                // 배경으로 깐다 — 아이콘 뷰의 정체성이 그대로라 켜고 끌 때 튀지 않는다
                .background { if glass { GlassChrome().transition(.opacity) } }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(MyFisColor.textPrimary)
        .accessibilityLabel(label)
    }
}

/// 헤더 요소 뒤에 깔리는 유리 알약 (§6.17).
///
/// 정사각(아이콘 44pt)에 쓰면 원이 되므로 아이콘·워드마크가 같은 모양을 공유한다.
/// iOS 25 이하에는 유리가 없어 흐린 알약으로 떨어진다.
private struct GlassChrome: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            Color.clear.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            Capsule().fill(MyFisColor.surface3.opacity(0.7))
        }
    }
}
