import SwiftUI

// MARK: - 버튼 (DESIGN.md §6.1)

/// Primary — 화면당 1개
struct MyFisPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MyFisFont.titleSm)
                .frame(maxWidth: .infinity, minHeight: MyFisSize.buttonPrimary)
        }
        .disabled(!isEnabled)
        // 비활성에 opacity 를 쓰지 않는다 (§9 의도된 이탈 #2) — 색 토큰 자체를 바꾼다.
        .foregroundStyle(isEnabled ? MyFisColor.onAccent : MyFisColor.textTertiary)
        .background(isEnabled ? MyFisColor.accent : MyFisColor.surface2)
        .clipShape(Capsule())
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
        .foregroundStyle(MyFisColor.textPrimary)
        .background(MyFisColor.surface2)
        .clipShape(Capsule())
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
        .foregroundStyle(MyFisColor.textSecondary)
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
        .foregroundStyle(MyFisColor.danger)
        .overlay(Capsule().stroke(MyFisColor.danger, lineWidth: 1))
    }
}

// MARK: - 카드 / 진행률

/// DESIGN.md §6.2 카드
struct MyFisCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MyFisSpacing.cardPadding)
        .background(MyFisColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
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
