import SwiftUI

/// P-05 물 마시기 — **미션 시각 고르기** (SPEC P-05).
///
/// 레퍼런스는 토스 `언제 마실까요?` 다 (사용자 지정). 짜임만 가져온다.
///
/// ⚠️ **고른 칩을 라임으로 칠하지 않는다.** 원본은 고른 칩 셋 + 오른쪽 요약 셋 + 버튼까지
/// 전부 민트라 강조가 일곱 곳이다. 우리는 화면당 **두 곳**이 상한이고(§2 원칙 3),
/// 주간 캘린더(§6.11)가 이미 답을 냈다 — **선택은 표면 밝기와 글자 밝기로.**
/// 이 화면의 라임은 **하단 `설정하기` 하나뿐**이다.
struct WaterTimeScreen: View {
    /// 지금 걸린 미션 시각
    var times: [String: String] = WaterSlot.defaultTimes
    /// `설정하기` 를 누르면 고른 시각을 넘긴다
    var onSave: ([String: String]) -> Void = { _ in }
    var onBack: () -> Void = {}

    /// 고를 때만 여기서 들고 있고, **저장을 눌러야** 밖으로 나간다 —
    /// 되돌아가면 고르던 것은 버려진다
    @State private var picked: [String: String] = [:]

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: "물 마시기", onBack: onBack, light: true)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("언제 마실까요?")
                        .font(MyFisFont.titleLg)
                        .foregroundStyle(MyFisColor.lightTextPrimary)

                    Text("고른 시간에 알려드려요")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.lightTextSecondary)
                        .padding(.top, MyFisSpacing.sm)

                    ForEach(Array(WaterSlot.all.enumerated()), id: \.element.id) { index, slot in
                        SlotCard(
                            slot: slot,
                            picked: picked[slot.name] ?? slot.times[0],
                            onPick: { picked[slot.name] = $0 }
                        )
                        .padding(.top, index == 0 ? MyFisSpacing.sectionGap : MyFisSpacing.cardGap)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
            }

            MyFisPrimaryButton(
                title: "설정하기",
                light: true,
                // 활동 화면의 Primary 는 **그 활동의 색**이다 (2026-08-28)
                fill: MyFisColor.lightAccentCyan,
                onFill: MyFisColor.lightBgBase,
                action: { onSave(picked); onBack() }
            )
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.vertical, MyFisSpacing.md)
                .background(MyFisColor.lightBgBase)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear { if picked.isEmpty { picked = times } }
        // **흰 바탕** — 혜택의 활동 화면은 밝다 (§9 이탈 #1, 2026-08-28 개정)
        .background(MyFisColor.lightBgBase)
    }
}

/// 때 한 장 — 머리(그림 · 이름 ↔ 고른 값) + 시각 칩들
private struct SlotCard: View {
    let slot: WaterSlot
    let picked: String
    let onPick: (String) -> Void

    var body: some View {
        MyFisCard(light: true) {
            HStack(spacing: 0) {
                Text(slot.emoji)
                    .font(MyFisFont.titleMd)
                Text(slot.name)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.lightTextPrimary)
                    .padding(.leading, MyFisSpacing.sm)

                Spacer(minLength: MyFisSpacing.sm)

                // 고른 값을 다시 적는다 — 칩이 여러 줄이면 무엇을 골랐는지 한눈에 안 잡힌다.
                // **라임을 쓰지 않는다** (원본은 민트다) — 흰 글자로 충분히 앞선다
                Text(picked.asClock)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.lightTextPrimary)
            }

            FlowLayout(spacing: MyFisSpacing.sm) {
                ForEach(slot.times, id: \.self) { time in
                    TimeSlotChip(time: time, selected: time == picked) { onPick(time) }
                }
            }
            .padding(.top, MyFisSpacing.lg)
        }
    }
}

/// 시각 칩. **고른 것은 판을 한 단계 올리고 테두리를 두른다** (§5.4 위계는 표면 밝기).
///
/// ⚠️ 높이는 `size.chip`(36) 이 아니라 **터치 타겟(44)** 이다 — 마일리지 칩과 달리
/// 이건 **누르는 칩**이라 §5.3 최소치를 지켜야 한다
private struct TimeSlotChip: View {
    let time: String
    let selected: Bool
    let onPick: () -> Void

    var body: some View {
        Button(action: onPick) {
            Text(time)
                .font((selected ? MyFisFont.titleSm : MyFisFont.body).monospacedDigit())
                .foregroundStyle(selected ? MyFisColor.lightTextPrimary : MyFisColor.lightTextSecondary)
                .padding(.horizontal, MyFisSpacing.lg)
                .frame(height: MyFisSize.minTouchTarget)
                .background(
                    selected ? MyFisColor.lightSurface3 : MyFisColor.lightSurface2,
                    in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                )
                .overlay {
                    if selected {
                        RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                            .strokeBorder(MyFisColor.lightAccentCyan, lineWidth: 1.5)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }
}

/// 칸이 모자라면 다음 줄로 넘긴다 — 안드로이드 `FlowRow` 와 같은 결과를 낸다.
///
/// **디자인 조각이 아니라 배치 도구다.** 칩 폭이 글자마다 달라 격자로는 두 플랫폼이 어긋난다
private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

private extension String {
    /// `8:00` → `오전 8시` — 머리에서는 문장으로 읽히는 편이 낫다
    var asClock: String {
        guard let hour = Int(prefix(while: { $0 != ":" })) else { return self }
        let half = hasSuffix(":30") ? " 30분" : ""
        if hour < 12 { return "오전 \(hour)시\(half)" }
        if hour == 12 { return "오후 12시\(half)" }
        return "오후 \(hour - 12)시\(half)"
    }
}
