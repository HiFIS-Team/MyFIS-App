import SwiftUI

/// 헤더 조각들 (DESIGN.md §6.9).
///
/// **시스템 툴바(`.toolbar`)를 쓰지 않는다.** 화면이 자기 헤더를 직접 그린다 —
/// 그래야 헤더가 페이지와 **함께** 움직인다. 시스템 내비 바는 화면들이 공유하는 크롬이라
/// 화면이 바뀔 때마다 아이템을 morph 시키고(유리 껍데기·그루터기·좌우 밀림)
/// 그 움직임을 우리가 끌 수 없다 (2026-08-25 확인).
///
/// 대신 **재질과 스크롤은 시스템 것**을 쓴다 🟢 (2026-09-15) — 아이콘은 `glassEffect`(`HeaderGlass`),
/// 본문은 헤더 밑으로 지나가고 시스템 가장자리 효과가 흐린다(`myFisHeader`).

extension View {
    /// 헤더를 본문 위에 띄운다 (§6.9).
    ///
    /// iOS 26 이면 **본문이 헤더 밑으로 지나간다** (`safeAreaBar`) — 첫 자리는 헤더 높이만큼 비워 두고,
    /// 헤더 밑은 시스템 가장자리 효과(`scrollEdgeEffect`) 기본값이 흐린다. 그래야 헤더 유리가 굴절할 게 생긴다.
    /// 26 미만은 헤더 밑에 본문을 쌓는다
    @ViewBuilder
    func myFisHeader<Header: View>(@ViewBuilder _ header: () -> Header) -> some View {
        if #available(iOS 26.0, *) {
            safeAreaBar(edge: .top, spacing: 0, content: header)
        } else {
            VStack(spacing: 0) {
                header()
                self
            }
        }
    }
}

/// 헤더 좌우 여백 (§6.9).
///
/// 평평한 아이콘은 **글리프**가 눈에 보이는 끝이라 터치 영역이 튀어나온 만큼(`8`) 빼서 `20 - 8`.
/// 유리(iOS 26)는 **유리 테두리**가 끝이라 화면 여백 `20` 그대로다
enum HeaderInset {
    static var horizontal: CGFloat {
        if #available(iOS 26.0, *) { return MyFisSpacing.screenHorizontal }
        return MyFisSpacing.screenHorizontal - MyFisSpacing.sm
    }

    /// 헤더 끝에 **글자 · 칩**이 설 때 더 들이는 값 — 평평한 헤더에서만 `8` 을 채워 화면 여백 선에 세운다
    static var edgeText: CGFloat {
        if #available(iOS 26.0, *) { return 0 }
        return MyFisSpacing.sm
    }
}

extension EnvironmentValues {
    /// 헤더 아이콘이 유리 위에 있다 (`HeaderGlass`) — 누름은 유리가 알리므로 아이콘을 줄이지 않는다
    @Entry var headerOnGlass = false
}

/// 헤더 아이콘을 **리퀴드 글래스**에 얹는다 (§6.9) 🟢 (2026-09-15).
///
/// 네이티브 `glassEffect` 다 — iOS 26 시스템 툴바가 이웃 아이템을 **한 알약으로 묶는** 모양 그대로.
/// 아이콘 하나면 원(44), 둘이면 알약(88×44). 누르면 유리가 스스로 반응한다(`interactive`).
/// iOS 26 미만은 평평한 아이콘이다
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

/// 헤더 한 줄 — 왼쪽 · 가운데 · 오른쪽.
///
/// 높이 `56`, 좌우 여백은 `HeaderInset.horizontal` — 아이콘의 눈에 보이는 끝이 본문 여백과 맞는다.
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
        .padding(.horizontal, HeaderInset.horizontal)
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
    /// 흰 바탕 화면(혜택·활동, §9 이탈 #1)에서는 글자·아이콘을 어두운 쪽으로 바꾼다
    var light: Bool = false

    private var ink: Color { light ? MyFisColor.lightTextPrimary : MyFisColor.textPrimary }

    var body: some View {
        HeaderBar {
            HeaderGlass {
                HeaderIcon(backIcon, backLabel, action: onBack, tint: ink)
            }
        } center: {
            if let title {
                Text(title)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(ink)
            }
        } trailing: {
            if let actionIcon {
                HeaderGlass {
                    HeaderIcon(actionIcon, actionLabel, action: onAction, tint: ink)
                }
            }
        }
    }
}
