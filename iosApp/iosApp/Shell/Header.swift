import SwiftUI

/// 헤더 조각들 (DESIGN.md §6.9).
///
/// **시스템 툴바(`.toolbar`)를 쓰지 않는다.** 화면이 자기 헤더를 직접 그린다 —
/// 그래야 헤더가 페이지와 **함께** 움직인다. 시스템 내비 바는 화면들이 공유하는 크롬이라
/// 화면이 바뀔 때마다 아이템을 morph 시키고(유리 껍데기·그루터기·좌우 밀림)
/// 그 움직임을 우리가 끌 수 없다 (2026-08-25 확인).

/// 헤더의 아이콘 버튼 — 아이콘 26pt, 터치 타겟 44pt (§5.3).
struct HeaderIcon: View {
    let asset: String
    let label: String
    let action: () -> Void

    init(_ asset: String, _ label: String, action: @escaping () -> Void) {
        self.asset = asset
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .frame(width: MyFisSize.headerIcon, height: MyFisSize.headerIcon)
                .frame(width: MyFisSize.minTouchTarget, height: MyFisSize.minTouchTarget)
                .contentShape(Rectangle())
        }
        // 누름은 아이콘만 줄인다 (§6.7)
        .buttonStyle(.myFisIcon)
        .foregroundStyle(MyFisColor.textPrimary)
        .accessibilityLabel(label)
    }
}

/// 헤더 한 줄 — 왼쪽 · 가운데 · 오른쪽.
///
/// 높이 `56`, 좌우 여백은 화면 여백(`20`)에서 **아이콘 터치 영역이 튀어나온 만큼**(`8`) 뺀 값이다.
/// 그래야 아이콘의 눈에 보이는 왼쪽 끝이 본문 여백과 맞는다.
struct HeaderBar<Leading: View, Center: View, Trailing: View>: View {
    @ViewBuilder var leading: Leading
    @ViewBuilder var center: Center
    @ViewBuilder var trailing: Trailing

    var body: some View {
        ZStack {
            center
            HStack(spacing: 0) {
                leading
                Spacer(minLength: 0)
                trailing
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }
}

/// 잎 화면의 상단 바 — 뒤로 + 제목 + (선택) 액션.
///
/// 셸 헤더와 높이·여백이 같아서 두 화면이 겹쳐도 줄이 어긋나지 않는다.
/// "헤더에 제목을 두지 않는다"(§6.9)는 **탭 화면** 규칙이고,
/// 잎 화면은 자기가 어디인지 밝혀야 한다.
struct DetailHeader: View {
    /// 제목을 본문에서 크게 다루는 화면은 `nil` 로 비운다
    var title: String?
    let onBack: () -> Void
    /// 되돌아가는 게 아니라 **닫는** 화면은 `X` 를 쓴다 (활동 랜딩 §6.25)
    var backIcon: String = "ic_tab_back"
    var backLabel: String = "뒤로"
    var actionIcon: String?
    var actionLabel: String = ""
    var onAction: () -> Void = {}

    var body: some View {
        HeaderBar {
            HeaderIcon(backIcon, backLabel, action: onBack)
        } center: {
            if let title {
                Text(title)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
            }
        } trailing: {
            if let actionIcon {
                HeaderIcon(actionIcon, actionLabel, action: onAction)
            }
        }
    }
}
