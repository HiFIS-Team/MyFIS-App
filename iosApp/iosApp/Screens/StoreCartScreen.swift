import SwiftUI

/// SPEC.md S-06 장바구니 (DESIGN.md §6.22).
///
/// 여러 상품을 **한 번에 교환**한다. 이 화면이 답해야 하는 건 상세와 같다 —
/// "지금 바꿀 수 있나". 다만 여기선 **고른 것들의 합계**가 그 답이다.
struct StoreCartScreen: View {
    let onBack: () -> Void
    var balance: Int = StorePlaceholder.balance
    var onStore: () -> Void = {}
    var onExchange: () -> Void = {}

    @State private var lines = CartPlaceholder.lines

    private var picked: [CartLine] { lines.filter(\.checked) }
    private var total: Int { picked.reduce(0) { $0 + $1.item.price * $1.count } }
    private var short: Int { max(total - balance, 0) }

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            if lines.isEmpty {
                CartEmpty(onStore: onStore)
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            selectAll

                            // 줄마다 카드를 떼지 않고 **한 장 안에서 구분선**으로 가른다
                            // (§6.21 리뷰와 같은 판단)
                            VStack(spacing: 0) {
                                ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                                    if index > 0 { divider }
                                    CartRow(
                                        line: line,
                                        onToggle: { lines[index].checked.toggle() },
                                        onCount: { lines[index].count = $0 },
                                        onDelete: { lines.remove(at: index) }
                                    )
                                }
                            }
                            .background(
                                MyFisColor.surface1,
                                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                            )
                            .padding(.horizontal, MyFisSpacing.screenHorizontal)

                            notice
                            suggestions
                        }
                    }
                    bar
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("뒤로")
            }
            ToolbarItem(placement: .principal) {
                Text("장바구니")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
            }
        }
    }

    /// 전체 선택 ↔ 선택 삭제. 목록 위에 둔다 — 고르고 나서 지우는 순서라서다
    private var selectAll: some View {
        let allChecked = lines.allSatisfy(\.checked)

        return HStack(spacing: 0) {
            Button {
                let next = !allChecked
                for index in lines.indices { lines[index].checked = next }
            } label: {
                HStack(spacing: MyFisSpacing.sm) {
                    CheckBox(checked: allChecked)
                    Text("전체 선택 (\(lines.count.decimal)건)")
                        .font(MyFisFont.bodySm.monospacedDigit())
                        .foregroundStyle(MyFisColor.textSecondary)
                }
                .padding(MyFisSpacing.xs)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            if !picked.isEmpty {
                MyFisSmallButton(title: "선택 삭제") {
                    lines.removeAll(where: \.checked)
                }
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.md)
    }

    /// 담아둔 것이 사라지는 조건을 **미리** 알린다. 사라진 뒤에 설명하면 늦다
    private var notice: some View {
        VStack(alignment: .leading, spacing: 2) {
            // TODO(서버): 담기 한도·보관 기간은 정책이 정해지면 맞춘다
            Text("* 한 번에 최대 \(CartPlaceholder.max)개까지 담을 수 있어요")
                .font(MyFisFont.caption.monospacedDigit())
            Text("* 담은 지 30일이 지난 상품은 장바구니에서 사라져요")
                .font(MyFisFont.caption)
        }
        .foregroundStyle(MyFisColor.textTertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.lg)
    }

    /// 같이 담을 만한 것. 담은 것과 겹치지 않게 고른다
    private var suggestions: some View {
        let inCart = Set(lines.map(\.item.id))
        let items = StorePlaceholder.items
            .filter { !inCart.contains($0.id) && !$0.soldOut }
            .sorted { $0.views > $1.views }
            .prefix(2)

        return VStack(alignment: .leading, spacing: 0) {
            Text("함께 담으면 좋아요")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)

            HStack(alignment: .top, spacing: MyFisSpacing.cardGap) {
                // TODO: 담기가 붙으면 연결한다
                ForEach(Array(items)) { CartSuggestionCard(item: $0) }
            }
            .padding(.top, MyFisSpacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.bottom, MyFisSpacing.xxxl)
    }

    /// 하단 고정 바.
    ///
    /// **합계와 남는 잔액을 버튼 바로 위에** 둔다 — 누르기 직전이 그 숫자를 볼 마지막 순간이다.
    /// 못 바꾸는 이유는 상세(§6.21)와 같이 버튼 글자가 직접 말한다.
    private var bar: some View {
        let count = picked.reduce(0) { $0 + $1.count }

        return VStack(spacing: 0) {
            divider
            VStack(spacing: 0) {
                HStack {
                    Text("쓰는 마일리지")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                    Spacer(minLength: MyFisSpacing.sm)
                    Text(
                        short > 0
                            ? "\(short.mileage) 부족"
                            : "교환하면 \((balance - total).mileage) 남아요"
                    )
                    .font(MyFisFont.bodySm.monospacedDigit())
                    .foregroundStyle(short > 0 ? MyFisColor.warning : MyFisColor.textSecondary)
                }

                HStack(spacing: MyFisSpacing.xs) {
                    Image("ic_mileage_fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(MyFisColor.accent)
                    Text(total.mileage)
                        .font(MyFisFont.metricMd.monospacedDigit())
                        .foregroundStyle(MyFisColor.accent)
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
                .padding(.bottom, MyFisSpacing.md)

                MyFisPrimaryButton(
                    title: count == 0
                        ? "상품을 골라 주세요"
                        : (short > 0 ? "\(short.mileage) 부족" : "\(count.decimal)개 교환하기"),
                    isEnabled: count > 0 && short == 0,
                    action: onExchange
                )
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)
            .background(MyFisColor.bgBase)
        }
    }

    private var divider: some View {
        Rectangle().fill(MyFisColor.borderSubtle).frame(height: 1)
    }
}

/// 선택 표시.
///
/// **색이 아니라 채움으로 알린다** (§6.7 하단 탭과 같은 판단) — 액센트는 하단 [교환하기] 몫이다.
/// 체크가 라임이면 화면에서 가장 중요한 게 뭔지 흐려진다.
private struct CheckBox: View {
    let checked: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
            .fill(checked ? MyFisColor.textPrimary : .clear)
            .frame(width: 22, height: 22)
            .overlay {
                if checked {
                    Image("ic_check")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(MyFisColor.bgBase)
                } else {
                    RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
                        .stroke(MyFisColor.borderStrong, lineWidth: 1.5)
                }
            }
    }
}

/// 담긴 상품 한 줄
private struct CartRow: View {
    let line: CartLine
    let onToggle: () -> Void
    let onCount: (Int) -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button(action: onToggle) {
                CheckBox(checked: line.checked)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(line.checked ? "선택 해제" : "선택")

            // TODO(서버): 상품 이미지가 오면 교체한다
            Color.clear
                .frame(width: 64, height: 64)
                .background(MyFisColor.surface2)
                .overlay {
                    Image("ic_tab_store")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(MyFisColor.surface3)
                }
                .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: 0) {
                Text(line.item.name)
                    .font(MyFisFont.body)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(1)

                HStack(spacing: MyFisSpacing.xs) {
                    Image("ic_mileage_fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(MyFisColor.accent)
                    Text((line.item.price * line.count).mileage)
                        .font(MyFisFont.titleSm.monospacedDigit())
                        .foregroundStyle(MyFisColor.textPrimary)
                }
                .padding(.top, 2)

                // 배송이 아니라 **지점 수령**이다 (SPEC S-01) — 도착 예정일 자리에 수령 방법을 적는다
                Text("강남점 데스크 · 발급 후 7일 안에 수령")
                    .font(MyFisFont.caption)
                    .foregroundStyle(MyFisColor.textTertiary)
                    .lineLimit(1)
                    .padding(.top, MyFisSpacing.xs)

                HStack(spacing: MyFisSpacing.sm) {
                    Button(action: onDelete) {
                        Image("ic_cart_delete")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(MyFisColor.textSecondary)
                            .frame(width: 34, height: 34)
                            .background(
                                MyFisColor.surface2,
                                in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("삭제")

                    Stepper(count: line.count, onCount: onCount)
                }
                .padding(.top, MyFisSpacing.sm)
            }
            .padding(.leading, MyFisSpacing.md)

            Spacer(minLength: 0)
        }
        .padding(MyFisSpacing.cardPadding)
    }
}

/// 수량. 1 밑으로는 안 내려간다 — 0개는 삭제가 할 일이다
private struct Stepper: View {
    let count: Int
    let onCount: (Int) -> Void

    var body: some View {
        HStack(spacing: 0) {
            StepperButton(label: "−", enabled: count > 1) { onCount(count - 1) }
            Text("\(count)")
                .font(MyFisFont.bodySm.monospacedDigit())
                .foregroundStyle(MyFisColor.textPrimary)
                .frame(width: 24)
            StepperButton(label: "+", enabled: count < CartPlaceholder.max) { onCount(count + 1) }
        }
        .background(
            MyFisColor.surface2,
            in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
        )
    }
}

private struct StepperButton: View {
    let label: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(MyFisFont.titleSm)
                .foregroundStyle(enabled ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                .frame(width: 34, height: 34)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

private struct CartSuggestionCard: View {
    let item: StoreItem

    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .background(MyFisColor.surface2)
                    .overlay {
                        Image("ic_tab_store")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(MyFisColor.surface3)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
                Text(item.name)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(1)
                    .padding(.top, MyFisSpacing.sm)
                Text(item.price.mileage)
                    .font(MyFisFont.titleSm.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

private struct CartEmpty: View {
    let onStore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image("ic_header_cart")
                .resizable()
                .frame(width: 56, height: 56)
                .foregroundStyle(MyFisColor.surface3)
            Text("담은 상품이 없어요")
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.textSecondary)
                .padding(.top, MyFisSpacing.md)
            // 버튼은 §6.1 대로 폭을 다 쓴다 — 안드로이드와 같은 모양이어야 한 앱으로 읽힌다
            MyFisSecondaryButton(title: "상품 보러 가기", action: onStore)
                .padding(.top, MyFisSpacing.lg)
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }
}

/// 장바구니 한 줄. TODO(서버): 장바구니 API 가 붙으면 지운다
struct CartLine: Identifiable, Hashable {
    let item: StoreItem
    var count: Int = 1
    var checked: Bool = true

    var id: Int { item.id }
}

enum CartPlaceholder {
    /// 한 번에 담을 수 있는 개수. TODO(서버): 정책이 정해지면 맞춘다
    static let max = 10

    /// TODO(서버): 장바구니 API 가 붙으면 지운다
    static let lines: [CartLine] = [
        CartLine(item: StorePlaceholder.items[0], count: 2),
        CartLine(item: StorePlaceholder.items[2]),
        CartLine(item: StorePlaceholder.items[6], checked: false),
    ]
}
