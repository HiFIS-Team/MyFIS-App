import SwiftUI

/// SPEC.md S-08 스토어 마이 (DESIGN.md §6.20).
///
/// **마이 탭(Y-01)과 다른 화면이다.** 여기는 스토어 안에서의 나 —
/// 교환권(S-04) · 교환 내역(S-05) · 장바구니(S-06) 처럼 **교환에 관한 것만** 모인다.
/// 프로필·기록·설정은 마이 탭이 맡는다.
///
/// 스토어 헤더에서 **오른쪽에서 왼쪽으로 밀려 들어온다** (잎 화면, DESIGN.md §7.1).
struct StoreMyScreen: View {
    let onBack: () -> Void
    var onCart: () -> Void = {}

    var body: some View {
        ZStack {
            MyFisColor.bgBase.ignoresSafeArea()

            ScrollView {
                VStack(spacing: MyFisSpacing.cardGap) {
                    BalanceRow(balance: StorePlaceholder.balance)
                    QuickMenu()
                    RecentRow(count: 3)
                    ExchangeCard(exchange: StoreMyPlaceholder.exchange)
                    InviteRow()
                    SuggestionGrid(items: StoreMyPlaceholder.affordable(StorePlaceholder.balance))
                        .padding(.top, MyFisSpacing.xl)
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 알림함과 같은 규칙 — 스택의 루트라 뒤로 버튼을 직접 넣되 자리는 시스템 툴바를 쓴다.
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("뒤로")
            }
            ToolbarItem(placement: .principal) {
                Text("내 교환")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
            }
            // TODO: S-06 장바구니가 붙으면 연결한다
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onCart) {
                    Image("ic_header_cart")
                }
                .accessibilityLabel("장바구니")
            }
        }
    }
}

/// 보유 마일리지.
///
/// 제목은 헤더가 맡고, 본문 맨 위는 **이 화면에서 가장 중요한 숫자**가 차지한다 (§2 원칙 1).
private struct BalanceRow: View {
    let balance: Int

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
            Text("보유 마일리지")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
            HStack(spacing: MyFisSpacing.sm) {
                Image("ic_mileage_fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(MyFisColor.accent)
                Text(balance.mileage)
                    .font(MyFisFont.metricMd.monospacedDigit())
                    .foregroundStyle(MyFisColor.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, MyFisSpacing.sm)
        .padding(.bottom, MyFisSpacing.xs)
    }
}

/// 네 갈래 바로가기. **네 개로 고정한다** — 다섯 개가 되면 한 줄에 안 들어가 글자가 줄어든다
private struct QuickMenu: View {
    var body: some View {
        HStack(spacing: 0) {
            // TODO: 각 화면(S-04 · S-07 찜 · S-05 · 문의)이 붙으면 연결한다
            QuickItem(icon: "ic_my_coupon", label: "교환권")
            QuickItem(icon: "ic_store_like_fill", label: "찜")
            QuickItem(icon: "ic_quest_board", label: "교환 내역")
            QuickItem(icon: "ic_my_ask", label: "문의")
        }
        .padding(.vertical, MyFisSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            MyFisColor.surface1,
            in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        )
    }
}

private struct QuickItem: View {
    let icon: String
    let label: String

    var body: some View {
        Button {} label: {
            VStack(spacing: MyFisSpacing.sm) {
                Image(icon)
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text(label)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// 최근 본 상품 — 썸네일만 보여 주고 목록은 눌러서 본다
private struct RecentRow: View {
    let count: Int

    var body: some View {
        // TODO: 최근 본 상품 목록이 붙으면 연결한다
        Button {} label: {
            HStack(spacing: MyFisSpacing.sm) {
                Text("최근 본 상품")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                Spacer(minLength: 0)
                HStack(spacing: MyFisSpacing.xs) {
                    ForEach(0..<count, id: \.self) { _ in Thumbnail(size: 36) }
                }
                Chevron()
            }
            .padding(MyFisSpacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(
                MyFisColor.surface1,
                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

/// 교환 한 건 (DESIGN.md §6.20).
///
/// 상태와 기한이 맨 위, 상품이 가운데, 할 수 있는 일이 맨 아래.
/// **기한이 제목보다 먼저 읽혀야 한다** — 교환권은 지나면 사라진다.
private struct ExchangeCard: View {
    let exchange: MyExchange

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: MyFisSpacing.sm) {
                Text(exchange.status)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                Text(exchange.deadline)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
                Spacer(minLength: 0)
                MyFisSmallButton(title: "교환권 보기")
            }
            .padding(MyFisSpacing.cardPadding)

            Rectangle()
                .fill(MyFisColor.borderSubtle)
                .frame(height: 1)

            HStack(alignment: .top, spacing: MyFisSpacing.md) {
                Thumbnail(size: 64)
                VStack(alignment: .leading, spacing: 2) {
                    Text(exchange.date)
                        .font(MyFisFont.caption)
                        .foregroundStyle(MyFisColor.textTertiary)
                    Text(exchange.item)
                        .font(MyFisFont.body)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .lineLimit(1)
                    Text("\(exchange.price.mileage) · \(exchange.count)개")
                        .font(MyFisFont.bodySm.monospacedDigit())
                        .foregroundStyle(MyFisColor.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(MyFisSpacing.cardPadding)

            // TODO: 문의(🔵) · 리뷰(🔵) 화면이 붙으면 연결한다.
            // 리뷰가 우리가 바라는 행동이라 Secondary, 문의는 Ghost (§6.1)
            HStack(spacing: MyFisSpacing.sm) {
                MyFisGhostButton(title: "문의하기")
                MyFisSecondaryButton(title: "리뷰 쓰기")
            }
            .padding(.horizontal, MyFisSpacing.cardPadding)
            .padding(.bottom, MyFisSpacing.cardPadding)
        }
        .background(
            MyFisColor.surface1,
            in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        )
    }
}

/// 친구 초대 — 마일리지가 늘어나는 유일한 '내가 하는' 길이라 이 화면에 둔다
private struct InviteRow: View {
    var body: some View {
        // TODO: 초대 링크 공유가 붙으면 연결한다
        Button {} label: {
            HStack(spacing: MyFisSpacing.sm) {
                Text("친구 초대")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                Spacer(minLength: 0)
                Text("1,000 P 받는 링크 보내기")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
                Chevron()
            }
            .padding(MyFisSpacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(
                MyFisColor.surface1,
                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

/// 잔액으로 바꿀 수 있는 것들. 홈(§6.16)과 같은 기준이라 여기서도 **부족한 상품은 넣지 않는다**
private struct SuggestionGrid: View {
    let items: [StoreItem]

    private let columns = [
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
        GridItem(.flexible(), spacing: MyFisSpacing.cardGap),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("바꿀 만한 것")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            Text("지금 마일리지로 바로 교환할 수 있어요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
                .padding(.top, 2)

            LazyVGrid(columns: columns, spacing: MyFisSpacing.lg) {
                ForEach(items) { SuggestionCard(item: $0) }
            }
            .padding(.top, MyFisSpacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SuggestionCard: View {
    let item: StoreItem

    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 0) {
                // TODO(서버): 상품 이미지가 오면 교체한다
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .background(MyFisColor.surface2)
                    .overlay {
                        Image("ic_tab_store")
                            .resizable()
                            .frame(width: 44, height: 44)
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

/// 상품 자리값. TODO(서버): 이미지가 오면 교체한다
private struct Thumbnail: View {
    let size: CGFloat

    var body: some View {
        Image("ic_tab_store")
            .resizable()
            .frame(width: size / 2, height: size / 2)
            .foregroundStyle(MyFisColor.surface3)
            .frame(width: size, height: size)
            .background(
                MyFisColor.surface2,
                in: RoundedRectangle(cornerRadius: MyFisRadius.sm, style: .continuous)
            )
    }
}

private struct Chevron: View {
    var body: some View {
        Image("ic_chevron_down")
            .resizable()
            .frame(width: 18, height: 18)
            .rotationEffect(.degrees(-90))
            .foregroundStyle(MyFisColor.textTertiary)
    }
}

/// TODO(서버): 교환 내역 API 가 붙으면 지운다 (SPEC S-05)
struct MyExchange {
    let status: String
    let deadline: String
    let date: String
    let item: String
    let price: Int
    let count: Int
}

enum StoreMyPlaceholder {
    /// TODO(서버): 교환 API 가 붙으면 지운다
    static let exchange = MyExchange(
        status: "수령 대기",
        deadline: "내일 23:59까지",
        date: "8월 24일 교환",
        item: "이온음료 500ml",
        price: 300,
        count: 1
    )

    /// TODO(서버): 추천은 서버가 고른다. 홈(§6.16)과 같은 기준을 쓴다
    static func affordable(_ balance: Int) -> [StoreItem] {
        StorePlaceholder.items
            .filter { !$0.soldOut && $0.price <= balance }
            .sorted { $0.views > $1.views }
            .prefix(4)
            .map { $0 }
    }
}
