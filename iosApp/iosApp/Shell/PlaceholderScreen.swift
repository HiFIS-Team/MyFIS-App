import SwiftUI

/// 아직 안 만든 화면 자리. 무엇이 올지 적어 둔다.
struct PlaceholderScreen: View {
    let id: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: MyFisSpacing.sm) {
            Text(id)
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.accent)
            Text(title)
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            Text(description)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
