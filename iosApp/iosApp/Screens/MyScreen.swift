import SwiftUI

/// SPEC.md Y-01 마이 (DESIGN.md §6.38).
///
/// 레퍼런스는 **버핏그라운드 MY** 다 (2026-09-07, 사용자 지정 — *"아얘 이 디자인이랑 똑같이 만들어"*).
/// 구조를 그대로 옮기고 **표면만 우리 토큰**으로 바꾼다 (§3.2).
///
/// 위에서부터 — 프로필 한 줄 → **멤버십 덩어리**(만료 경고 · 회원권 카드 · 관리 · 구매)
/// → 구분선으로 나뉜 **글자 줄 묶음**(결제 · 기록 · 안내) → 맨 아래 로그아웃 · 탈퇴.
///
/// ⚠️ **1순위가 숫자가 아니다** (§2 원칙 1 의 예외 — 모임 §6.29 와 같은 사유).
/// 여기는 계기판이 아니라 **찾아 들어가는 목록**이고, 답이 "어디로 가지" 다.
/// 그래도 회원권만은 숫자로 말한다 — 만료 경고 줄과 카드의 `남음` 이 그 몫이다.
struct MyScreen: View {
    var onProfile: () -> Void = {}
    var onMembership: () -> Void = {}
    var onPurchase: () -> Void = {}

    private let profile = MyPlaceholder.profile
    private let membership = MyPlaceholder.membership

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ProfileRow(profile: profile, action: onProfile)
                        .padding(.top, MyFisSpacing.sm)

                    SectionTitle("멤버십", trailing: profile.branch)
                        .padding(.top, MyFisSpacing.xxl)

                    if membership.daysLeft <= MyPlaceholder.expirySoonDays {
                        ExpiryRow(action: onPurchase)
                    }

                    MembershipCard(membership: membership)
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)
                        .padding(.top, MyFisSpacing.sm)

                    // TODO(M-06): 내 멤버십 화면이 붙으면 연결한다
                    MyFisListRow("멤버십 관리",
                                 value: "유효 멤버십 \(membership.count)개",
                                 action: onMembership)
                        .padding(.top, MyFisSpacing.sm)

                    MyFisDivider().padding(.vertical, MyFisSpacing.md)

                    // **이 화면에서 돈이 되는 유일한 줄**이라 라임을 여기 쓴다 (§3.2 액센트 2곳 예산)
                    // TODO(M-01 → M-03): 지점 선택 → 멤버십 구성으로 이어진다
                    MyFisListRow(title: "멤버십 구매하기",
                                 titleColor: MyFisColor.accent,
                                 chevron: true,
                                 action: onPurchase) {
                        MyFisSmallButton(title: "지점 선택", action: onPurchase)
                    }

                    MyFisDivider().padding(.vertical, MyFisSpacing.md)

                    GroupLabel("결제")
                    // TODO(M-07): 결제 내역이 붙으면 연결한다
                    MyFisListRow("결제 내역", chevron: true, action: {})
                    MyFisListRow("결제 수단 관리", chevron: true, action: {})
                    // TODO(S-04): 교환권이 붙으면 연결한다
                    MyFisListRow("교환권", value: "1장", action: {})
                    // TODO(P-02): 마일리지 내역이 붙으면 연결한다. 표기는 앱 전체가 같다 (§3.3)
                    MyFisListRow(title: "마일리지", chevron: true, action: {}) {
                        MileageText(StorePlaceholder.balance).font(MyFisFont.bodySm)
                    }

                    MyFisDivider().padding(.vertical, MyFisSpacing.md)

                    GroupLabel("기록")
                    // TODO(W-06 · C-05 · S-05): 각 기록 화면이 붙으면 연결한다
                    MyFisListRow("운동 기록", chevron: true, action: {})
                    MyFisListRow("유산소 기록", chevron: true, action: {})
                    MyFisListRow("교환 내역", chevron: true, action: {})

                    MyFisDivider().padding(.vertical, MyFisSpacing.md)

                    GroupLabel("안내 · 설정")
                    // TODO: 공지·문의(🔵) · 알림 설정(Y-03) · 약관(Y-03) 이 붙으면 연결한다
                    MyFisListRow("공지사항", chevron: true, action: {})
                    MyFisListRow("고객 의견", chevron: true, action: {})
                    MyFisListRow("알림 설정", chevron: true, action: {})
                    MyFisListRow("약관 · 개인정보", chevron: true, action: {})
                    MyFisListRow("앱 버전", value: MyPlaceholder.appVersion, chevron: false)

                    MyFisDivider().padding(.vertical, MyFisSpacing.md)

                    // 물러난 줄이라 `text.secondary` 다. 원본은 로그아웃 하나지만
                    // **탈퇴는 앱 안에서 끝나야 한다** (스토어 심사 요구, SPEC Y-03)
                    MyFisListRow("로그아웃", titleColor: MyFisColor.textSecondary, action: {})
                    MyFisListRow("회원 탈퇴", titleColor: MyFisColor.textSecondary, action: {})
                }
                .padding(.bottom, MyFisSpacing.xxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

}

/// 아바타 + 닉네임 ↔ `프로필 수정`. 원본과 같이 **꺾쇠를 두지 않는다** — 오른쪽 글자가 그 구실을 한다
private struct ProfileRow: View {
    let profile: MyProfile
    let action: () -> Void

    var body: some View {
        MyFisTappable(label: "\(profile.nickname) 프로필 수정", action: action) {
            HStack(spacing: 0) {
                Avatar(nickname: profile.nickname)
                Text(profile.nickname)
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .padding(.leading, MyFisSpacing.md)

                Spacer(minLength: MyFisSpacing.md)

                Text("프로필 수정")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
            .frame(minHeight: MyFisSize.listRowMin)
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .frame(maxWidth: .infinity)
        }
    }
}

/// TODO(서버): 프로필 사진이 오면 교체한다. 지금은 닉네임 첫 글자다
private struct Avatar: View {
    let nickname: String

    var body: some View {
        Circle()
            .fill(MyFisColor.surface2)
            .frame(width: MyPlaceholder.avatar, height: MyPlaceholder.avatar)
            .overlay(
                Text(nickname.prefix(1))
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textSecondary)
            )
    }
}

/// 묶음 제목 ↔ 오른쪽 곁말 (`멤버십` ↔ 지점 이름)
private struct SectionTitle: View {
    let title: String
    var trailing: String?

    init(_ title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
            Spacer(minLength: MyFisSpacing.md)
            if let trailing {
                Text(trailing)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }
}

/// 글자 줄 묶음의 머리 — 제목이 아니라 **꼬리표**라 `label` 이다 (§4.2)
private struct GroupLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(MyFisFont.label)
            .foregroundStyle(MyFisColor.textTertiary)
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.sm)
    }
}

/// 만료가 코앞일 때만 나오는 줄. **여기서만 danger 를 쓴다** — 상태 표시다 (§3.1)
private struct ExpiryRow: View {
    let action: () -> Void

    var body: some View {
        MyFisTappable(label: "곧 만료되는 멤버십이 있어요. 연장하기", action: action) {
            HStack(spacing: 0) {
                // 느낌표는 **동그란 색 판 안에** 넣어 쓴다 — 토스트(§6.35)와 같은 판·같은 비율이다
                Circle()
                    .fill(MyFisColor.danger)
                    .frame(width: MyFisSpacing.xxl, height: MyFisSpacing.xxl)
                    .overlay(
                        Image("ic_alert")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: MyPlaceholder.alertGlyph,
                                   height: MyPlaceholder.alertGlyph)
                            .foregroundStyle(MyFisColor.onAccent)
                    )

                Text("곧 만료되는 멤버십이 있어요")
                    .font(MyFisFont.body)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .padding(.leading, MyFisSpacing.sm)

                Spacer(minLength: MyFisSpacing.md)

                Text("연장하기")
                    .font(MyFisFont.body)
                    .foregroundStyle(MyFisColor.textPrimary)
                Chevron().padding(.leading, MyFisSpacing.xs)
            }
            .frame(minHeight: MyFisSize.listRowMin)
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .frame(maxWidth: .infinity)
        }
    }
}

/// 회원권 한 장 (원본의 `1일 이용권` 카드).
///
/// 머리 줄이 **무엇을 얼마나** 남겼는지 말하고, 아래 두 칸이 **아직 안 산 것**을 판다.
/// 원본은 두 칸이 따로 판이고 버튼이 테두리형인데, 우리는 **테두리 버튼이 없다** (§6.1 5종) —
/// 카드 위에 세로 실선으로 나누고 `Small`(surface.2) 을 쓴다. 면이 하나 줄어 더 조용하다.
private struct MembershipCard: View {
    let membership: MyMembership

    var body: some View {
        MyFisCard {
            HStack(spacing: 0) {
                // 카드에서 제일 먼저 읽혀야 하는 값이라 **한 단계 키운다** (§4.2 title.md,
                // 2026-09-07 사용자 지정). `title.sm` 이면 옆 `5일 남음` 과 무게가 비슷해 보였다
                Text(membership.name)
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.textPrimary)
                Spacer(minLength: MyFisSpacing.md)
                Text("\(membership.daysLeft)일 남음")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(membership.daysLeft <= MyPlaceholder.expirySoonDays
                                     ? MyFisColor.danger : MyFisColor.textSecondary)
            }

            HStack(spacing: MyFisSpacing.cardGap) {
                AddonSlot(label: "락커", state: membership.locker)
                AddonSlot(label: "운동복", state: membership.apparel)
            }
            .padding(.top, MyFisSpacing.lg)
        }
    }
}

/// 산 것은 상태를 보여 주고, 안 산 것은 판다 (M-03 으로 간다).
///
/// **카드 안의 `surface.2` 블록**이다 (§6.2 — 카드 안에 카드를 넣지 않는다).
/// 그래서 버튼은 `Small` 의 **테두리 변형**이다 — 같은 면끼리면 버튼이 판에 녹는다
private struct AddonSlot: View {
    let label: String
    var state: String?

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.textPrimary)
            Spacer(minLength: MyFisSpacing.sm)
            if let state {
                Text(state)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
            } else {
                // TODO(M-03): 멤버십 구성 화면이 붙으면 연결한다
                MyFisSmallButton(title: "구매하기", outlined: true, action: {})
            }
        }
        .frame(maxWidth: .infinity)
        .padding(MyFisSpacing.md)
        .background(MyFisColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
    }
}

/// TODO(서버): 프로필 API 가 붙으면 지운다 (SPEC Y-01)
struct MyProfile {
    let nickname: String
    let branch: String
}

/// TODO(서버): 내 멤버십 API 가 붙으면 지운다 (SPEC M-06)
struct MyMembership {
    let name: String
    let daysLeft: Int
    /// 배정된 락커 번호. `nil` 이면 안 샀다
    var locker: String?
    /// 운동복 수령 상태. `nil` 이면 안 샀다
    var apparel: String?
    let count: Int
}

enum MyPlaceholder {
    static let profile = MyProfile(nickname: "은후", branch: "MyFIS 역삼점")

    static let membership = MyMembership(name: "3개월 회원권", daysLeft: 5,
                                         locker: nil, apparel: nil, count: 1)

    /// 며칠 남았을 때부터 `만료 임박` 인가
    static let expirySoonDays = 7

    /// 프로필 아바타 — 목록 줄 왼쪽에 서므로 `40` 이다. 더 키우면 이 줄이 화면 주인공이 된다
    static let avatar: CGFloat = 40

    /// 느낌표 판 안의 글리프 — 토스트(§6.35)와 같은 값이다
    static let alertGlyph: CGFloat = 14

    /// TODO: 빌드 정보에서 읽어 온다
    static let appVersion = "0.1.0 (1)"
}
