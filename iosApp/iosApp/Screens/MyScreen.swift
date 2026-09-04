import SwiftUI

/// TODO(서버): 회원권·교환권 API 가 붙으면 지운다 (SPEC M-06 · S-05)
enum MyPlaceholder {
    static let nickname = "은후"
    static let branch = "광주 상무점"

    static let membership = "3개월 회원권"
    static let totalDays = 90
    static let daysLeft = 42
    static let period = "2026. 7. 1 ~ 2026. 10. 15"
    static let locker = "12번"
    static let wear = "이용 중"

    static let coupons = 1
    static let exchanges = 2

    /// 만료가 코앞이면 카드 **위에** 한 줄이 뜬다 (§6.35)
    static let warnWithin = 7

    /// 아바타 색 — **닉네임에서 계산한다** (P-07 레이더와 같은 규칙).
    ///
    /// ⚠️ 무작위가 아니다. 다시 그릴 때마다 색이 바뀌면 *내 색*이 아니게 된다 —
    /// 출석 도장 기울기(§6.11)와 같은 이유로 **글자에서 뽑는다.** 두 플랫폼이 같은 식을 쓴다.
    /// **라임은 팔레트에서 뺐다** — 그건 진행바(액센트)의 몫이라 얼굴 색으로 쓰면 예산이 겹친다
    static let avatarPalette = [
        MyFisColor.categoryViolet, MyFisColor.categoryBlue, MyFisColor.categoryCoral,
        MyFisColor.categoryGreen, MyFisColor.categoryGold, MyFisColor.categoryTeal,
    ]

    static var avatarColor: Color {
        let sum = nickname.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return avatarPalette[sum % avatarPalette.count]
    }
}

/// SPEC.md Y-01 마이 (DESIGN.md §6.35).
///
/// 레퍼런스 셋을 **각각 다른 이유로** 뜯어 왔다 (사용자 지정).
/// - **버핏그라운드 MY** → 화면의 뼈대. *회원권이 주인공*이고 락커·운동복이 그 카드 안에 산다
/// - **마이배민** → *값이 있는 것들*(마일리지·교환권·쿠폰)을 한 카드에 모아 숫자를 오른쪽에 세운다
/// - **토스 설정** → 항목을 카드로 묶고 카드 사이를 띄워 그룹을 만든다. 다크에서 구분선보다 잘 읽힌다
///
/// **회원권이 주인공인 이유** — 헬스장 앱 마이에 오는 이유가 *"며칠 남았지"* 다.
/// 마일리지를 주인공으로 두는 안도 있었지만 잔액은 홈·혜택·스토어가 **이미 세 번** 보여준다.
struct MyScreen: View {
    var onSettings: () -> Void = {}

    /// 남은 날 — 훅으로 만료 임박 상태를 볼 수 있다
    private var daysLeft: Int { MyFisDebug.myDaysLeft }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    profileCard

                    sectionTitle("멤버십")
                    if daysLeft <= MyPlaceholder.warnWithin { expiryLine }
                    membershipCard

                    sectionTitle("내 것")
                    myThings

                    sectionTitle("기록")
                    records
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.sm)
                .padding(.bottom, MyFisSpacing.xxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// 다른 탭(§6.28 · §6.29 · §6.33)과 같은 꼴 — 화면 이름 `title.lg` + 오른쪽 아이콘.
    /// **설정은 톱니 하나로 뺐다** (사용자 지정) — 자주 가는 곳이 아니라 목록을 먹을 이유가 없다
    private var header: some View {
        HStack(spacing: MyFisSpacing.md) {
            Text("마이")
                .font(MyFisFont.titleLg)
                .foregroundStyle(MyFisColor.textPrimary)

            Spacer(minLength: MyFisSpacing.md)

            HeaderIcon("ic_header_settings", "설정", action: onSettings)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(MyFisFont.titleMd)
            .foregroundStyle(MyFisColor.textPrimary)
            .padding(.top, MyFisSpacing.sectionGap)
            .padding(.bottom, MyFisSpacing.md)
    }

    /// 프로필 — **사진을 쓰지 않는다.** 색 원 + 닉네임 첫 글자 (SPEC P-07 프라이버시, §6.25 와 같은 규칙)
    private var profileCard: some View {
        MyFisCard {
            HStack(spacing: MyFisSpacing.lg) {
                Text(String(MyPlaceholder.nickname.prefix(1)))
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.bgBase)
                    .frame(width: MyFisSize.listRowMin, height: MyFisSize.listRowMin)
                    .background(MyPlaceholder.avatarColor, in: Circle())

                VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                    Text(MyPlaceholder.nickname)
                        .font(MyFisFont.titleMd)
                        .foregroundStyle(MyFisColor.textPrimary)
                    Text(MyPlaceholder.branch)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textSecondary)
                }

                Spacer(minLength: MyFisSpacing.md)

                Chevron()
            }
        }
        // TODO(Y-02): 누르면 프로필 수정으로 간다
    }

    /// 만료 경고 — **카드 위 한 줄**이다. 카드 안에 넣으면 카드가 시끄러워진다 (버핏그라운드와 같은 자리).
    /// 아이콘을 만들지 않았다 — `danger` 글자가 이미 경고다 (§8 은 그림을 늘리지 말라고 한다)
    private var expiryLine: some View {
        HStack(spacing: MyFisSpacing.md) {
            Text("곧 만료되는 회원권이 있어요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.danger)
            Spacer(minLength: 0)
            Text("연장하기")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textPrimary)
            Chevron(size: 16)
        }
        .padding(.bottom, MyFisSpacing.md)
        // TODO(M-04): 연장 결제로 간다
    }

    /// 이 화면의 주인공 (§2 원칙 1) — **남은 날이 제일 큰 숫자**다
    private var membershipCard: some View {
        MyFisCard(radius: MyFisRadius.lg) {
            Text(MyPlaceholder.membership)
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.textPrimary)

            HStack(alignment: .bottom, spacing: MyFisSpacing.sm) {
                Text("\(daysLeft)")
                    .font(MyFisFont.metricLg)
                    .foregroundStyle(daysLeft <= MyPlaceholder.warnWithin
                                     ? MyFisColor.danger : MyFisColor.textPrimary)
                Text("일 남음")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .padding(.bottom, MyFisSpacing.sm)
            }
            .padding(.top, MyFisSpacing.sm)

            MyFisProgress(value: Double(daysLeft) / Double(MyPlaceholder.totalDays))
                .padding(.top, MyFisSpacing.sm)

            Text(MyPlaceholder.period)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textTertiary)
                .padding(.top, MyFisSpacing.md)

            // 락커·운동복은 **회원권에 딸린 것**이라 같은 카드 안에 산다 (버핏그라운드와 같은 판단)
            MyFisRowDivider()
                .padding(.vertical, MyFisSpacing.lg)

            HStack(spacing: MyFisSpacing.md) {
                attachment("락커", MyPlaceholder.locker)
                Spacer(minLength: MyFisSpacing.md)
                attachment("운동복", MyPlaceholder.wear)
            }
        }
        // TODO(M-06): 누르면 회원권 관리로 간다
    }

    private func attachment(_ label: String, _ value: String) -> some View {
        HStack(spacing: MyFisSpacing.sm) {
            Text(label)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)
            Text(value)
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textPrimary)
        }
    }

    /// **값이 있는 것들을 한 덩어리로** (마이배민에서 가져온 것) — 흩어져 있으면 세 번 찾아야 한다
    private var myThings: some View {
        MyFisCard {
            // 포인트 표기는 앱 전체가 한 규칙을 쓴다 (§3.3) — 글자로 찍지 않는다
            MyFisListRow(title: "마일리지",
                         accessory: AnyView(MileageText(BenefitPlaceholder.balance)
                             .font(MyFisFont.bodySm)))
            MyFisRowDivider()
            MyFisListRow(title: "교환권", value: "\(MyPlaceholder.exchanges)장")
            MyFisRowDivider()
            MyFisListRow(title: "쿠폰", value: "\(MyPlaceholder.coupons)장")
        }
        // TODO(P-02 · S-05): 각각 내역 화면으로 간다
    }

    /// 기록은 **자리만 잡는다** (사용자 지정) — 누르면 아직 안 간다.
    /// `체성분 기록` 은 인바디 연동(SPEC §7.6)이 붙으면 채워진다
    private var records: some View {
        MyFisCard {
            MyFisListRow(title: "운동 기록", value: nil)
            MyFisRowDivider()
            MyFisListRow(title: "유산소 기록", value: nil)
            MyFisRowDivider()
            MyFisListRow(title: "체성분 기록", value: nil)
            MyFisRowDivider()
            MyFisListRow(title: "결제 내역", value: nil)
        }
        // TODO(W-06 · C-05 · M-07): 각각 기록 화면으로 간다
    }
}

#Preview {
    MyScreen().preferredColorScheme(.dark)
}
