import SwiftUI

/// 헤더 조각들 (DESIGN.md §6.9 · §7.1).
///
/// **iOS 헤더는 시스템 내비 바다** 🟢 (2026-09-15, 사용자 지정 — *"그냥 크림처럼 하고싶다 크림처럼 해봐"*).
/// 탭 화면은 `TabShell` 이, 잎 화면은 자기가 `.toolbar` · `navigationTitle` 로 올린다.
/// 옆에서 화면이 들어올 때 **유리가 새 화면 아이템으로 녹아 바뀌는 것**은 시스템 내비 바만 한다.
///
/// 2026-08-25 ~ 09-15 에는 화면이 헤더를 직접 그렸다(`HeaderBar` · `DetailHeader` · `myFisHeader`) — 걷었다.
/// 남은 `HeaderGlass` · `HeaderIcon` · `HeaderInset` 은 **내비 바를 숨기는 검색 잎**(`SearchHeader`) 몫이다

// MARK: - 툴바

/// 툴바 아이콘 — 우리 벡터 그대로 26pt. **유리 · 누름 · 이웃 아이템 묶기는 시스템이 한다**
struct ToolbarIcon: View {
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
        }
        .accessibilityLabel(label)
    }
}

/// 탭 화면 이름 — 툴바 왼쪽에 `title.lg` 로 선다 (웨이트 · 유산소 · 모임, §6.9 · §4.2)
struct ToolbarScreenTitle: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(MyFisFont.titleLg)
            .foregroundStyle(MyFisColor.textPrimary)
            .fixedSize()
    }
}

extension ToolbarContent {
    /// 유리를 씌우지 않는다 — iOS 26 은 툴바 아이템마다 유리를 씌우는데,
    /// **화면 이름 · 칩 · 시계처럼 판이 없어야 하거나 자기 판이 있는 것**에는 겹친다
    @ToolbarContentBuilder
    func withoutGlass() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}

// MARK: - 검색 잎 머리 (내비 바를 숨긴다)

/// 헤더 좌우 여백 (§6.9).
///
/// 평평한 아이콘은 **글리프**가 눈에 보이는 끝이라 터치 영역이 튀어나온 만큼(`8`) 빼서 `20 - 8`.
/// 유리(iOS 26)는 **유리 테두리**가 끝이라 화면 여백 `20` 그대로다
enum HeaderInset {
    static var horizontal: CGFloat {
        if #available(iOS 26.0, *) { return MyFisSpacing.screenHorizontal }
        return MyFisSpacing.screenHorizontal - MyFisSpacing.sm
    }
}

extension EnvironmentValues {
    /// 헤더 아이콘이 유리 위에 있다 (`HeaderGlass`) — 누름은 유리가 알리므로 아이콘을 줄이지 않는다
    @Entry var headerOnGlass = false
}

/// 헤더 아이콘을 **리퀴드 글래스**에 얹는다 — 네이티브 `glassEffect`.
/// 아이콘 하나면 원(44), 둘이면 알약. iOS 26 미만은 평평한 아이콘이다
struct HeaderGlass<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26.0, *) {
            HStack(spacing: 0) { content }
                .environment(\.headerOnGlass, true)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            HStack(spacing: 0) { content }
        }
    }
}

/// 헤더의 아이콘 버튼 — 아이콘 26pt, 터치 타겟 44pt (§5.3).
struct HeaderIcon: View {
    let asset: String
    let label: String
    let action: () -> Void
    @Environment(\.headerOnGlass) private var onGlass

    init(_ asset: String, _ label: String, action: @escaping () -> Void,
         tint: Color = MyFisColor.textPrimary) {
        self.asset = asset
        self.label = label
        self.action = action
        self.tint = tint
    }

    /// 흰 바탕 화면에서는 어두운 아이콘을 쓴다 (§9 이탈 #1)
    var tint: Color

    var body: some View {
        Button(action: action) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .frame(width: MyFisSize.headerIcon, height: MyFisSize.headerIcon)
                .frame(width: MyFisSize.minTouchTarget, height: MyFisSize.minTouchTarget)
                .contentShape(Rectangle())
        }
        // 누름은 아이콘만 줄인다 (§6.7) — 유리 위에서는 유리가 알린다
        .buttonStyle(onGlass ? MyFisTapStyle.myFisTap : MyFisTapStyle.myFisIcon)
        .foregroundStyle(tint)
        .accessibilityLabel(label)
    }
}
