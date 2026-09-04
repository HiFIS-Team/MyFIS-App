import SwiftUI

// MARK: - 버튼 (DESIGN.md §6.1)

/// Primary — 화면당 1개
struct MyFisPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    /// 흰 바탕 화면(혜택·활동, §9 이탈 #1)에서는 **비활성** 면을 밝은 쪽으로 바꾼다
    var light: Bool = false
    /// 활동 화면은 **그 활동의 갈래 색**으로 칠한다 (2026-08-28). 기본은 라임
    var fill: Color = MyFisColor.accent
    var onFill: Color = MyFisColor.onAccent
    /// **떠 있는 알약**으로 그린다 (§6.28 유산소 탭, 2026-09-03).
    ///
    /// 탭 화면은 아래에 **떠 있는 탭 바**가 있어서, 폭을 다 쓰는 판을 얹으면
    /// **둥근 덩어리가 둘로 겹쳐** 보이고 뒤 카드가 모서리에 반쯤 잘린다.
    /// 탭 바와 **같은 캡슐 모양**으로 맞추고 폭은 글자에 맡긴다.
    var pill: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MyFisFont.titleSm)
                .padding(.horizontal, pill ? MyFisSpacing.xxl : 0)
                .frame(maxWidth: pill ? nil : .infinity,
                       minHeight: pill ? MyFisSize.buttonSecondary : MyFisSize.buttonPrimary)
        }
        .buttonStyle(.myFisTap)
        .disabled(!isEnabled)
        // 비활성에 opacity 를 쓰지 않는다 (§9 의도된 이탈 #2) — 색 토큰 자체를 바꾼다.
        .foregroundStyle(isEnabled ? onFill
                         : (light ? MyFisColor.lightTextTertiary : MyFisColor.textTertiary))
        .background(isEnabled ? fill
                    : (light ? MyFisColor.lightSurface2 : MyFisColor.surface2))
        .clipShape(pill ? AnyShape(Capsule())
                   : AnyShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)))
    }
}

/// Secondary
struct MyFisSecondaryButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MyFisFont.bodySm)
                .frame(maxWidth: .infinity, minHeight: MyFisSize.buttonSecondary)
        }
        .buttonStyle(.myFisTap)
        .foregroundStyle(MyFisColor.textPrimary)
        .background(MyFisColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
    }
}

/// Ghost
struct MyFisGhostButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MyFisFont.bodySm)
                .frame(maxWidth: .infinity, minHeight: MyFisSize.buttonSecondary)
        }
        .buttonStyle(.myFisTap)
        .foregroundStyle(MyFisColor.textSecondary)
    }
}

/// Small — **카드 안**에서 쓰는 보조 버튼.
///
/// 전체 폭을 먹지 않는다. 카드 머리 줄처럼 다른 글자와 나란히 서는 자리용이다.
struct MyFisSmallButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MyFisFont.bodySm)
                .padding(.horizontal, MyFisSpacing.lg)
                .frame(minHeight: MyFisSize.buttonSmall)
        }
        .buttonStyle(.myFisTap)
        .foregroundStyle(MyFisColor.textPrimary)
        .background(MyFisColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
    }
}

/// Danger
struct MyFisDangerButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MyFisFont.bodySm)
                .frame(maxWidth: .infinity, minHeight: MyFisSize.buttonSecondary)
        }
        .buttonStyle(.myFisTap)
        .foregroundStyle(MyFisColor.danger)
        .overlay(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous).stroke(MyFisColor.danger, lineWidth: 1))
    }
}

// MARK: - 카드 / 진행률

/// DESIGN.md §6.2 카드
struct MyFisCard<Content: View>: View {
    /// 기본은 `radius.md`. **화면 폭을 다 쓰는 배너만 `radius.lg`** 다 (§6.2) —
    /// 스토어 캐러셀·혜택 초대 배너가 둘 다 `lg` 로 그려져 있어 그 관행을 그대로 받는다
    var radius: CGFloat = MyFisRadius.md
    /// 흰 바탕 화면(혜택·활동, §9 이탈 #1)에서는 면을 밝은 쪽으로 바꾼다
    var light: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MyFisSpacing.cardPadding)
        .background(light ? MyFisColor.lightSurface1 : MyFisColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// DESIGN.md §6.23 · §6.26 **아이콘 타일** — `56` 판 + `radius.tile` + `border.subtle` 1.
///
/// 혜택 행 · 기구 찾기 빠른 고르기 · 자주 쓰는 기구가 **같은 판을 세 곳에서 따로 그리고 있었다**
/// (2026-08-27 실측). 판을 여기 한 벌로 모은다.
///
/// - 테두리 한 줄이 판을 **타일**로 만든다 — 없으면 배경에 녹는다
/// - **크기를 받는다** 🟢 (2026-09-04) — 모임 레일(§6.29)이 `72` 판을 쓰면서
///   `23` 을 직접 박고 있었다. `radius.tile` 은 `56` 판에 맞춘 값이라(§5.2) 다른 크기에 그대로 못 쓴다 →
///   **라운딩을 비율(`radius.tileRatio`)로 뽑는다.** `56` 은 예전과 같은 `18` 이 나온다
struct MyFisIconTile<Content: View>: View {
    /// 이미 받은 줄처럼 한 단계 물러난 자리 — 판을 `surface.1` 로 내린다
    var dimmed = false
    /// 판 한 변. 기본은 목록 행(`56`)
    var size: CGFloat = MyFisSize.listRowMin
    @ViewBuilder var content: Content

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size * MyFisRadius.tileRatio, style: .continuous)
    }

    var body: some View {
        content
            .frame(width: size, height: size)
            .background(dimmed ? MyFisColor.surface1 : MyFisColor.surface2, in: shape)
            .overlay(shape.strokeBorder(MyFisColor.borderSubtle, lineWidth: 1))
    }
}

/// DESIGN.md §6.4 진행률 — 트랙은 0%일 때도 보여준다
struct MyFisProgress: View {
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(MyFisColor.surface3)
                Capsule()
                    .fill(MyFisColor.accent)
                    .frame(width: geo.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: MyFisSize.progressHeight)
    }
}

/// DESIGN.md §6.3 숫자 카드 — 이 앱의 시그니처.
/// 라벨이 숫자 '위'에 온다 (읽는 순서: 뭘 보는지 → 값).
struct MyFisMetricCard: View {
    let label: String
    let value: String
    let unit: String
    let caption: String
    let progress: Double
    var valueColor: Color = MyFisColor.accent

    var body: some View {
        MyFisCard {
            Text(label)
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)

            HStack(alignment: .lastTextBaseline, spacing: MyFisSpacing.sm) {
                Text(value)
                    .font(MyFisFont.metricXl)
                    .foregroundStyle(valueColor)
                Text(unit)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
            .padding(.top, MyFisSpacing.sm)

            MyFisProgress(value: progress)
                .padding(.top, MyFisSpacing.md)

            Text(caption)
                .font(MyFisFont.caption)
                .foregroundStyle(MyFisColor.textTertiary)
                .padding(.top, MyFisSpacing.sm)
        }
    }
}

/// 토큰 확인용 컬러 스와치
struct ColorSwatch: View {
    let name: String
    let color: Color
    let hex: String

    var body: some View {
        HStack(spacing: MyFisSpacing.md) {
            RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
                .fill(color)
                .frame(width: 56, height: 36)
            Text(name)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textPrimary)
            Spacer()
            Text(hex)
                .font(MyFisFont.caption)
                .foregroundStyle(MyFisColor.textTertiary)
        }
    }
}
