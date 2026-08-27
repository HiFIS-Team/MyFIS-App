import SwiftUI

/// P-07 **함께 마일리지 받기** — 지금 같은 지점에 있는 회원을 눌러 서로 적립한다.
///
/// 레퍼런스는 **토스 친구 초대 레이더**다 — 동심원을 깔고 사람을 흩어 놓은 뒤 가운데에 나를 둔다.
/// 목록으로 그리면 *누구인지* 가 앞서지만, 레이더로 그리면 ***지금 여기 같이 있다*** 가 앞선다.
/// 이 화면이 파는 건 사람이 아니라 **같은 공간에 있다는 사실**이다.
///
/// 액센트는 **가운데 나 + 말풍선 숫자 2곳뿐**이다 (§3.2). 주변 사람은 카테고리 색을 쓴다 —
/// 전부 회색으로 두면 "아무도 없는 방"처럼 읽히고, 전부 라임이면 누구를 눌러야 할지 사라진다.
struct TouchScreen: View {
    var onClose: () -> Void = {}

    /// 하루에 받을 수 있는 사람 수. **무제한이면 의미가 없다** (SPEC P-07)
    private static let dailyLimit = 5

    @State private var members = NearbyMember.placeholder

    private var remaining: Int {
        max(0, Self.dailyLimit - members.filter(\.received).count)
    }

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: "함께 마일리지 받기", onBack: onClose,
                         backIcon: "ic_header_close", backLabel: "닫기")

            // 사람 수가 먼저다 — 지금 갈 만한지가 여기서 정해진다
            Text("지금 강남점에 12명")
                .font(MyFisFont.label)
                .foregroundStyle(MyFisColor.textSecondary)
                .padding(.top, MyFisSpacing.lg)

            radar
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("얼굴을 누르면 둘 다 +10 P 받아요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
                .padding(.bottom, MyFisSpacing.giant)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 레이더

    private var radar: some View {
        ZStack {
            rings
            ForEach(members.indices, id: \.self) { i in
                MemberDot(member: members[i]) { receive(at: i) }
                    .offset(x: members[i].dx, y: members[i].dy)
            }
            bubble.offset(x: 10, y: -96)
            me
        }
        // 바깥 고리는 화면 밖으로 흘러나간다 — 방이 화면보다 넓다는 뜻이다
        .clipped()
    }

    /// 동심원 — 바깥으로 갈수록 옅어진다. 멀수록 흐릿하게 잡히는 신호처럼 보이게
    private var rings: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for (i, radius) in [78.0, 140.0, 202.0, 264.0].enumerated() {
                let box = CGRect(x: center.x - radius, y: center.y - radius,
                                 width: radius * 2, height: radius * 2)
                ctx.stroke(
                    Path(ellipseIn: box),
                    with: .color(MyFisColor.borderSubtle.opacity(0.85 - Double(i) * 0.17)),
                    lineWidth: 1
                )
            }
        }
    }

    private var me: some View {
        Circle()
            .fill(MyFisColor.accent)
            .frame(width: 64, height: 64)
            .overlay(
                Text("나")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.onAccent)
            )
    }

    /// 남은 횟수 — 숫자만 라임이라 한 눈에 걸린다
    private var bubble: some View {
        HStack(spacing: 4) {
            Text("오늘")
            Text("\(remaining)명")
                .foregroundStyle(MyFisColor.accent)
            Text("더 받을 수 있어요")
        }
        .font(MyFisFont.bodySm)
        .foregroundStyle(MyFisColor.textPrimary)
        .padding(.horizontal, MyFisSpacing.lg)
        .padding(.vertical, MyFisSpacing.md)
        .background(MyFisColor.surface2, in: Capsule())
    }

    /// 같은 사람은 하루 1회. 한도를 다 쓰면 더 받지 않는다 (SPEC P-07)
    private func receive(at index: Int) {
        guard !members[index].received, remaining > 0 else { return }
        withAnimation(MyFisMotion.base) { members[index].received = true }
    }
}

// MARK: - 사람 하나

private struct MemberDot: View {
    let member: NearbyMember
    let onTap: () -> Void

    private static let size: CGFloat = 56

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: MyFisSpacing.sm) {
                Circle()
                    .fill(member.received ? MyFisColor.surface2 : member.color)
                    .frame(width: Self.size, height: Self.size)
                    .overlay(
                        Text(member.initial)
                            .font(MyFisFont.titleSm)
                            // 카테고리 색은 전부 밝은 파스텔이라 글자는 검정이다 (§3.2)
                            .foregroundStyle(member.received ? MyFisColor.textTertiary
                                                             : MyFisColor.onAccent)
                    )

                Text(member.received ? "받았어요" : member.nickname)
                    .font(MyFisFont.caption)
                    .foregroundStyle(member.received ? MyFisColor.textTertiary
                                                     : MyFisColor.textSecondary)
            }
        }
        .buttonStyle(.myFisIcon)
        .disabled(member.received)
        .accessibilityLabel(member.received ? "\(member.nickname) 이미 받음"
                                            : "\(member.nickname) 눌러서 함께 받기")
    }
}

// MARK: - 모델

/// 지금 같은 지점에 있는 회원. **닉네임 + 아바타만** 쓴다 — 실명·사진을 쓰지 않는다 (SPEC P-07)
struct NearbyMember: Identifiable {
    let id: Int
    let nickname: String
    let color: Color
    /// 레이더 가운데(= 나)에서의 자리
    let dx: CGFloat
    let dy: CGFloat
    var received: Bool = false

    var initial: String { String(nickname.prefix(1)) }

    // TODO(서버): 지점에 있는 회원 목록은 서버가 준다 (SPEC §8). 자리는 서버 값으로 흩는다
    static let placeholder: [NearbyMember] = [
        .init(id: 1, nickname: "민준", color: MyFisColor.categoryViolet, dx: -60, dy: -176),
        .init(id: 2, nickname: "지호", color: MyFisColor.categoryBlue, dx: 140, dy: -52),
        .init(id: 3, nickname: "서연", color: MyFisColor.categoryOrange, dx: -140, dy: -30),
        .init(id: 4, nickname: "도윤", color: MyFisColor.categoryPink, dx: 100, dy: 100,
              received: true),
        .init(id: 5, nickname: "하은", color: MyFisColor.categoryTeal, dx: -60, dy: 160),
    ]
}
