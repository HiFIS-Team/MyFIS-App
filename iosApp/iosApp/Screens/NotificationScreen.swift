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
            // TODO: Y-03 설정이 붙으면 연결한다
            ToolbarItem(placement: .topBarTrailing) {
                Button("알림 설정") {}
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
        }
    }

    private var list: some View {
        let unread = items.filter(\.isUnread)
        let read = items.filter { !$0.isUnread }

        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                // 안 읽은 알림은 **한 덩어리로 밝게 깐다.** 점을 하나씩 찍는 것보다
                // "여기까지가 새 거" 가 한눈에 들어온다 (DESIGN.md §6.19)
                if !unread.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(unread) { NotificationRow(item: $0) }
                    }
                    .padding(.vertical, MyFisSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(MyFisColor.surface1)
                }

                if !read.isEmpty {
                    Text("지난 알림")
                        .font(MyFisFont.titleMd)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)
                        .padding(.top, MyFisSpacing.xxl)
                        .padding(.bottom, MyFisSpacing.sm)

                    ForEach(read) { NotificationRow(item: $0) }
                }
            }
            .padding(.bottom, MyFisSpacing.xxxl)
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

/// 알림 한 행 (DESIGN.md §6.19).
///
/// 왼쪽 아이콘 타일 · 제목 · 본문 · 오른쪽 위 시각. 구분선은 두지 않는다 —
/// 행마다 선을 그으면 목록이 표처럼 보이고, 묶음(안 읽음 블록)이 안 읽힌다.
private struct NotificationRow: View {
    let item: MyFisNotification

    private static let tile: CGFloat = 44

    var body: some View {
        HStack(alignment: .top, spacing: MyFisSpacing.md) {
            // 하단 탭과 같은 벡터를 쓴다. 탭에서는 28pt 로 그리므로 목록 크기는 여기서 정한다.
            Image(item.kind.icon)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundStyle(MyFisColor.textSecondary)
                .frame(width: Self.tile, height: Self.tile)
                .background(
                    MyFisColor.surface2,
                    in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .top, spacing: MyFisSpacing.sm) {
                    Text(item.title)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(item.time)
                        .font(MyFisFont.caption)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .padding(.top, 2)
                }

                // 건수 배지는 **본문 첫 줄 오른쪽**에 붙인다. 본문은 그 아래로 흘러내린다
                HStack(alignment: .top, spacing: MyFisSpacing.sm) {
                    Text(item.body)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    if let count = item.count {
                        Spacer(minLength: 0)
                        // 액센트는 쓰지 않는다 — 건수는 강조할 값이 아니다
                        Text("\(count)건")
                            .font(MyFisFont.caption.monospacedDigit())
                            .foregroundStyle(MyFisColor.textSecondary)
                            .padding(.horizontal, MyFisSpacing.sm)
                            .padding(.vertical, 2)
                            .background(
                                MyFisColor.surface3,
                                in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
                            )
                    }
                }
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.md)
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
