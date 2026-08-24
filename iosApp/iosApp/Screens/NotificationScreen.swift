import SwiftUI

/// SPEC.md §5 H-02 알림함 — 놓친 알림을 확인한다.
///
/// 헤더의 알림 아이콘에서 **오른쪽에서 왼쪽으로 밀려 들어온다.**
/// 전환은 `NavigationStack` push 를 그대로 쓴다 (DESIGN.md §7 — 화면 전환은 플랫폼 기본).
/// 가장자리 스와이프 뒤로가기도 공짜로 따라온다.
///
/// 탭 목적지가 아니라 잎 화면이라 **하단 탭 바는 가린다.**
struct NotificationScreen: View {
    let onBack: () -> Void
    let items: [MyFisNotification]

    init(
        onBack: @escaping () -> Void = {},
        items: [MyFisNotification] = MyFisNotification.initialForDebug
    ) {
        self.onBack = onBack
        self.items = items
    }

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            if items.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 스택의 루트라 시스템 뒤로 버튼이 없다. 직접 넣되 자리는 시스템 툴바를 쓴다 —
            // iOS 26 이 알아서 유리 원으로 그리고 터치 타겟도 맞춰 준다.
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("뒤로")
            }
            // navigationTitle 은 시스템 서체라 Pretendard 로 바꿀 수 없다.
            // 전역 UINavigationBar.appearance() 를 건드리는 대신 여기서만 교체한다.
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
            }
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    NotificationRow(item: item)
                    if item.id != items.last?.id {
                        // §6.5 구분선은 좌측 인덴트 없이 전체 너비
                        Rectangle()
                            .fill(MyFisColor.borderSubtle)
                            .frame(height: 1)
                    }
                }
            }
        }
    }

    /// §6.10 빈 상태 — 한 줄 설명 + 액션 1개. 일러스트는 넣지 않는다.
    private var emptyState: some View {
        VStack(spacing: MyFisSpacing.xl) {
            Text("알림이 없어요")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textSecondary)
            // TODO: Y-03 설정이 붙으면 연결한다.
            MyFisGhostButton(title: "알림 설정")
                .frame(width: 120)
        }
    }
}

/// 알림 한 행.
///
/// 미확인 점은 **행 맨 왼쪽**에 둔다 (SPEC H-02). 읽은 행도 같은 폭을 비워 둬야
/// 아이콘 세로줄이 어긋나지 않는다.
private struct NotificationRow: View {
    let item: MyFisNotification

    var body: some View {
        HStack(alignment: .top, spacing: MyFisSpacing.md) {
            Circle()
                .fill(item.isUnread ? MyFisColor.accent : .clear)
                .frame(width: 6, height: 6)
                .padding(.top, 8)

            // 하단 탭과 같은 벡터를 쓴다. 탭에서는 28pt 로 그리므로 목록 크기는 여기서 정한다.
            Image(item.kind.icon)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundStyle(MyFisColor.textSecondary)

            VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                Text(item.title)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text(item.body)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.time)
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textTertiary)
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.lg)
        .frame(minHeight: MyFisSize.listRowMin, alignment: .top)
        // TODO: kind.destination 화면이 붙으면 행을 눌러 이동한다.
        // 지금 눌러도 갈 곳이 없어 일부러 반응을 넣지 않았다.
    }
}

#Preview {
    NavigationStack {
        NotificationScreen()
    }
    .tint(MyFisColor.textPrimary)
    .preferredColorScheme(.dark)
}
