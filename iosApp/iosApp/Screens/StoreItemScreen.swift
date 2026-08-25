import SwiftUI

/// SPEC.md S-02 상품 상세 (DESIGN.md §6.21).
///
/// 이 화면이 답해야 하는 건 하나다 — **"이거 지금 바꿀 수 있나?"**
/// 그래서 가격 밑에 곧바로 교환 후 잔액(또는 부족분)을 붙이고, 하단 버튼이 같은 말을 반복한다.
struct StoreItemScreen: View {
    let item: StoreItem
    var balance: Int = StorePlaceholder.balance
    let onBack: () -> Void
    var onCart: () -> Void = {}
    var onExchange: () -> Void = {}

    @State private var liked = false

    private var short: Int { max(item.price - balance, 0) }

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        image
                        head
                        facts
                    }
                }
                buyBar
            }
            .ignoresSafeArea(edges: .top)

            // **버튼은 스크롤을 따라가지 않는다.** 내려 읽다가 뒤로가기가 사라지면 안 된다.
            // 안전 영역을 지키는 바깥 층에 두어야 상태바와 겹치지 않는다
            VStack(spacing: 0) {
                HStack {
                    FloatingIcon(icon: "ic_tab_back", label: "뒤로", action: onBack)
                    Spacer(minLength: 0)
                    // TODO: S-06 장바구니가 붙으면 연결한다
                    FloatingIcon(icon: "ic_header_cart", label: "장바구니", action: onCart)
                }
                .padding(.horizontal, MyFisSpacing.md)
                .padding(.top, MyFisSpacing.sm)
                Spacer(minLength: 0)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    /// 상품 이미지. 위 버튼들은 이미지 **위에 떠 있다** — 이미지를 화면 끝까지 쓰기 위해서다
    private var image: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .background(MyFisColor.surface2)
            .overlay {
                // TODO(서버): 상품 이미지가 오면 교체한다
                Image("ic_tab_store")
                    .resizable()
                    .frame(width: 96, height: 96)
                    .foregroundStyle(MyFisColor.surface3)
            }
    }

    /// 분류·이름·가격, 그리고 **바꿀 수 있는지**
    private var head: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Chip(label: item.category.label)
                Chip(label: "인기 \(popularityRank)위")
            }

            Text(item.name)
                .font(MyFisFont.titleLg)
                .foregroundStyle(MyFisColor.textPrimary)
                .padding(.top, MyFisSpacing.md)

            HStack(spacing: MyFisSpacing.sm) {
                Image("ic_mileage_fill")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(MyFisColor.accent)
                Text(item.price.mileage)
                    .font(MyFisFont.metricLg.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
            }
            .padding(.top, MyFisSpacing.sm)

            // 가격 바로 밑에서 **바꿀 수 있는지**를 답한다. 하단 버튼까지 내려가서 알 일이 아니다
            Text(availability)
                .font(MyFisFont.bodySm.monospacedDigit())
                .foregroundStyle(
                    short > 0 || item.soldOut ? MyFisColor.warning : MyFisColor.textSecondary
                )
                .padding(.top, MyFisSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.lg)
    }

    private var availability: String {
        if item.soldOut { return "지금은 품절이에요" }
        if short > 0 { return "\(short.mileage) 더 모으면 교환할 수 있어요" }
        return "교환하면 \((balance - item.price).mileage) 남아요"
    }

    /// 나머지 사실들. 한 줄에 하나씩, 라벨 폭을 고정해 값이 세로로 정렬된다
    private var facts: some View {
        VStack(spacing: 0) {
            divider
            FactRow(
                label: "평점 · 리뷰",
                value: "\(String(format: "%.1f", item.rating)) (\(item.reviewCount.decimal))",
                chevron: true
            )
            FactRow(label: "조회", value: item.views.viewCount)
            FactRow(label: "수령", value: "지점 데스크에서 받아요", chevron: true)
            FactRow(label: "교환권", value: "발급 후 7일 안에 수령")
            divider
        }
    }

    private var divider: some View {
        Rectangle().fill(MyFisColor.borderSubtle).frame(height: 1)
    }

    /// 하단 고정 바 (§6.21).
    ///
    /// **엄지가 닿는 자리**라 이 화면의 유일한 Primary 를 여기 둔다 (§2 원칙 2·5).
    /// 못 바꾸는 이유는 버튼 글자가 직접 말한다 — 비활성만 시키고 이유를 안 적으면 사용자가 막힌다.
    private var buyBar: some View {
        VStack(spacing: 0) {
            divider
            HStack(spacing: MyFisSpacing.sm) {
                BarIcon(
                    icon: liked ? "ic_store_like_fill" : "ic_store_like",
                    label: liked ? "찜 해제" : "찜하기",
                    tint: liked ? MyFisColor.like : MyFisColor.textSecondary
                ) { liked.toggle() }
                BarIcon(icon: "ic_header_cart", label: "장바구니", tint: MyFisColor.textSecondary, action: onCart)
                MyFisPrimaryButton(
                    title: buyLabel,
                    isEnabled: !item.soldOut && short == 0,
                    action: onExchange
                )
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)
            .background(MyFisColor.bgBase)
        }
    }

    private var buyLabel: String {
        if item.soldOut { return "품절" }
        if short > 0 { return "\(short.mileage) 부족" }
        return "교환하기"
    }

    /// 같은 분류 안에서 몇 번째로 많이 봤는지. TODO(서버): 랭킹이 오면 지운다
    private var popularityRank: Int {
        let ranked = StorePlaceholder.items
            .filter { $0.category == item.category }
            .sorted { $0.views > $1.views }
        return (ranked.firstIndex { $0.id == item.id } ?? 0) + 1
    }
}

/// 이미지 위에 뜨는 둥근 버튼. 배경을 깔아야 밝은 상품 사진 위에서도 아이콘이 보인다
private struct FloatingIcon: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundStyle(MyFisColor.textPrimary)
                .frame(width: 40, height: 40)
                .background(MyFisColor.bgBase.opacity(0.45), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct Chip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(MyFisFont.label)
            .foregroundStyle(MyFisColor.textSecondary)
            .padding(.horizontal, MyFisSpacing.sm)
            .padding(.vertical, MyFisSpacing.xs)
            .background(
                MyFisColor.surface2,
                in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
            )
    }
}

private struct FactRow: View {
    let label: String
    let value: String
    var chevron: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
                .frame(width: 88, alignment: .leading)
            Text(value)
                .font(MyFisFont.body.monospacedDigit())
                .foregroundStyle(MyFisColor.textPrimary)
                .lineLimit(1)
            Spacer(minLength: MyFisSpacing.sm)
            if chevron {
                Image("ic_chevron_down")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(MyFisColor.textTertiary)
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.vertical, MyFisSpacing.md)
        .contentShape(Rectangle())
    }
}

private struct BarIcon: View {
    let icon: String
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
