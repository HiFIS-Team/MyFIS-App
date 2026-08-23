import SwiftUI

/// 구현 전 자리. 화면이 붙으면 지운다.
struct PlaceholderScreen: View {
    let id: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 0) {
            Text(id)
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.accent)
            Text(title)
                .font(MyFisFont.titleLg)
                .foregroundStyle(MyFisColor.textPrimary)
                .padding(.top, MyFisSpacing.sm)
            Text(description)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.top, MyFisSpacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }
}
