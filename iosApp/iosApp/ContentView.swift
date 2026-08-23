import SharedKit
import SwiftUI

/// DESIGN.md 토큰이 실제로 어떻게 보이는지 확인하는 화면. 구현이 시작되면 교체된다.
struct ContentView: View {
    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: MyFisSpacing.sectionGap) {
                    VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                        Text("MyFIS")
                            .font(MyFisFont.titleLg)
                            .foregroundStyle(MyFisColor.textPrimary)
                        Text("디자인 토큰 · \(Greeting().greet())")
                            .font(MyFisFont.bodySm)
                            .foregroundStyle(MyFisColor.textSecondary)
                    }

                    section("숫자 카드 (§6.3)") {
                        VStack(spacing: MyFisSpacing.cardGap) {
                            MyFisMetricCard(
                                label: "남은 기간",
                                value: "42",
                                unit: "일",
                                caption: "2027. 2. 23. 만료",
                                progress: 0.62
                            )
                            MyFisMetricCard(
                                label: "남은 기간",
                                value: "5",
                                unit: "일",
                                caption: "만료 7일 이내 — warning",
                                progress: 0.08,
                                valueColor: MyFisColor.warning
                            )
                        }
                    }

                    section("타이포 스케일 (§4.2)") {
                        MyFisCard {
                            VStack(alignment: .leading, spacing: MyFisSpacing.md) {
                                typeRow("4,250", MyFisFont.metricXl, "metric.xl 56", MyFisColor.accent)
                                typeRow("1,240", MyFisFont.metricLg, "metric.lg 40", MyFisColor.textPrimary)
                                typeRow("8 / 20", MyFisFont.metricMd, "metric.md 28", MyFisColor.textPrimary)
                                Text("화면 제목 title.lg").font(MyFisFont.titleLg)
                                Text("섹션 제목 title.md").font(MyFisFont.titleMd)
                                Text("카드 제목 title.sm").font(MyFisFont.titleSm)
                                Text("본문입니다 body 16").font(MyFisFont.body)
                                Text("보조 본문 body.sm 14")
                                    .font(MyFisFont.bodySm).foregroundStyle(MyFisColor.textSecondary)
                                Text("라벨 label 13")
                                    .font(MyFisFont.label).foregroundStyle(MyFisColor.textSecondary)
                                Text("캡션 caption 12")
                                    .font(MyFisFont.caption).foregroundStyle(MyFisColor.textTertiary)
                            }
                            .foregroundStyle(MyFisColor.textPrimary)
                        }
                    }

                    section("버튼 (§6.1)") {
                        VStack(spacing: MyFisSpacing.md) {
                            MyFisPrimaryButton(title: "운동 시작")
                            MyFisPrimaryButton(title: "비활성 — opacity 안 씀", isEnabled: false)
                            MyFisSecondaryButton(title: "보조 액션")
                            MyFisGhostButton(title: "건너뛰기")
                            MyFisDangerButton(title: "예약 취소")
                        }
                    }

                    section("진행률 (§6.4)") {
                        MyFisCard {
                            VStack(spacing: MyFisSpacing.lg) {
                                MyFisProgress(value: 0)
                                MyFisProgress(value: 0.35)
                                MyFisProgress(value: 1)
                            }
                        }
                    }

                    section("컬러 토큰 (§3.1)") {
                        MyFisCard {
                            VStack(spacing: MyFisSpacing.md) {
                                ColorSwatch(name: "accent", color: MyFisColor.accent, hex: "#C9F531")
                                ColorSwatch(name: "surface.1", color: MyFisColor.surface1, hex: "#0E0F12")
                                ColorSwatch(name: "surface.2", color: MyFisColor.surface2, hex: "#16181D")
                                ColorSwatch(name: "surface.3", color: MyFisColor.surface3, hex: "#1F2229")
                                ColorSwatch(name: "text.primary", color: MyFisColor.textPrimary, hex: "#FFFFFF")
                                ColorSwatch(name: "text.secondary", color: MyFisColor.textSecondary, hex: "#A3A9B5")
                                ColorSwatch(name: "text.tertiary", color: MyFisColor.textTertiary, hex: "#828997")
                                ColorSwatch(name: "border.strong", color: MyFisColor.borderStrong, hex: "#6B7383")
                                ColorSwatch(name: "success", color: MyFisColor.success, hex: "#4ADE80")
                                ColorSwatch(name: "warning", color: MyFisColor.warning, hex: "#FBBF24")
                                ColorSwatch(name: "danger", color: MyFisColor.danger, hex: "#FF6B6B")
                                ColorSwatch(name: "info", color: MyFisColor.info, hex: "#7DA8FF")
                            }
                        }
                    }
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.vertical, MyFisSpacing.xxxl)
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            Text(title)
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            content()
        }
    }

    @ViewBuilder
    private func typeRow(_ value: String, _ font: Font, _ note: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
            Text(value).font(font).foregroundStyle(color)
            Text(note).font(MyFisFont.caption).foregroundStyle(MyFisColor.textTertiary)
        }
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
