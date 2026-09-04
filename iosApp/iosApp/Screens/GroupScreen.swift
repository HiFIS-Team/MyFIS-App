import SwiftUI

/// SPEC.md G-01 모임 (DESIGN.md §6.29).
///
/// 레퍼런스는 **당근 커뮤니티 › 모임**이다 — 가로 모임 줄 → 세그먼트 → 카테고리 갈래 → 필터 칩 → 목록,
/// 그리고 떠 있는 `모임 만들기`. **구조만 가져오고 표면은 우리 것을 쓴다** (§3.2).
///
/// 이 탭이 답하는 질문은 하나 — **"지금 우리 지점에 들어갈 만한 모임이 뭐가 있나"**.
///
/// ⚠️ **1순위가 숫자가 아니다** (§2 원칙 1 의 예외). 여기는 계기판이 아니라 **탐색 화면**이고
/// 답이 글이다 — 모임 이름이 제일 크다. 홈·유산소와 성격이 다르다.
///
/// **원본과 달라진 것 세 가지**
/// - **사진을 안 쓴다.** 모임 사진이 서버에 없고, 없이 옮기면 회색 정사각 목록이 된다 →
///   갈래 아이콘 타일(§6.26)로 바꿨다. 당근은 *모르는 동네 모임*이라 분위기를 봐야 하지만
///   우리는 **같은 지점 사람들**이라 분위기보다 언제·몇 명이 먼저다
/// - 원본 맨 위 다섯 갈래(동네생활·모임·카페…)는 우리 IA 에 없다 → 뺐다
/// - 원본은 색이 여섯 곳(주황 버튼·주황 점·파란 화살표·이모지·사진)이다. 우리는 **라임 두 곳**이 상한이라
///   `모임 만들기` 와 **안 읽은 점**에만 준다. 고른 것은 색이 아니라 밑줄·판 밝기로 알린다
struct GroupScreen: View {
    /// TODO: G-03 모임 개설이 붙으면 연결한다
    var onCreate: () -> Void = {}
    /// TODO: G-02 모임 상세가 붙으면 연결한다
    var onGroup: (GroupItem) -> Void = { _ in }
    var onSearch: () -> Void = {}

    @State private var segment: GroupSegment = .browse
    @State private var category: GroupCategory = .all
    @State private var sort: GroupSort = .recommended

    private var rows: [GroupItem] {
        GroupPlaceholder.groups.filter { category == .all || $0.category == category }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        MyGroupRail(groups: GroupPlaceholder.rail, onTap: onGroup)

                        SegmentBar(selection: $segment)
                            .padding(.horizontal, MyFisSpacing.screenHorizontal)
                            .padding(.top, MyFisSpacing.lg)

                        MyFisUnderlineTabs(
                            items: GroupCategory.allCases,
                            selection: $category,
                            distribution: .scrolling
                        ) { $0.title }
                            .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
                            .padding(.top, MyFisSpacing.md)

                        SortChips(selection: $sort)
                            .padding(.top, MyFisSpacing.md)

                        ForEach(rows) { group in
                            GroupRow(group: group, onTap: { onGroup(group) })
                        }
                        .padding(.top, MyFisSpacing.xs)
                    }
                    // 알약이 마지막 줄을 가리지 않게 그만큼 비워 둔다 (유산소와 같은 규칙)
                    .padding(.bottom, MyFisSize.buttonSecondary + MyFisSpacing.xxxl)
                }

                // 이 화면의 액션은 이 하나뿐 (§2 원칙 5). 원본은 우하단이지만
                // 우리 세트는 **떠 있는 탭 바** 위라 유산소(§6.28)와 같은 자리·같은 알약으로 맞춘다
                MyFisPrimaryButton(title: "＋ 모임 만들기", pill: true, action: onCreate)
                    .padding(.bottom, MyFisSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// **어느 지점의 모임인지 밝히는 줄이다** — 유산소 헤더가 이름을 앞에 두는 것과 같은 규칙이다.
    ///
    /// 다른 탭(혜택·스토어)은 헤더에 글자를 안 두지만 여기는 다르다 —
    /// 모임은 **지점에 매여 있어서**, 어느 지점 것을 보고 있는지가 목록보다 먼저 와야 한다.
    /// 원본 헤더의 셋(검색·알림·메뉴) 중 알림은 셸이 이미 들고 있고 메뉴는 우리에게 없다 → 검색만 남긴다
    private var header: some View {
        HStack(spacing: 0) {
            Text("\(GroupPlaceholder.branch)의 모임")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)
                .padding(.leading, MyFisSpacing.sm)

            Spacer(minLength: MyFisSpacing.md)

            HeaderIcon("ic_header_search", "모임 검색", action: onSearch)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }
}

// MARK: - 가로 모임 줄

/// 내가 든 모임과 추천을 옆으로 미는 줄 (원본 맨 위 줄).
///
/// **여기만 아바타를 쓴다.** 아래 목록과 같은 타일이면 같은 것을 두 번 보여주는 셈이라,
/// 위는 `72` 원판 + 이름 두 줄로 **얼굴처럼** 세우고 아래는 줄 목록으로 둔다.
private struct MyGroupRail: View {
    let groups: [GroupItem]
    let onTap: (GroupItem) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: MyFisSpacing.md) {
                ForEach(groups) { group in
                    Button { onTap(group) } label: { item(group) }
                        .buttonStyle(.myFisTap)
                }
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)
        }
    }

    private func item(_ group: GroupItem) -> some View {
        VStack(spacing: MyFisSpacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                // 목록과 **같은 타일**이다 — 크기만 다르다 (§6.26 이 크기를 받는다)
                MyFisIconTile(size: Self.avatar) {
                    Image(group.category.icon)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(MyFisColor.textSecondary)
                }

                badge(group)
                    .offset(x: 3, y: 3)
            }

            Text(group.name)
                .font(MyFisFont.caption)
                .foregroundStyle(MyFisColor.textSecondary)
                .multilineTextAlignment(.center)
                // 두 줄로 고정해야 줄의 바닥이 서로 같다 (상품 카드 §6.12 와 같은 판단)
                .lineLimit(2, reservesSpace: true)
        }
        .frame(width: Self.avatar)
    }

    /// 든 모임이면 **안 읽은 점**, 아니면 `＋`(들어가기). 원본과 같은 규칙이다.
    /// 라임을 쓰는 두 번째이자 마지막 자리다 — 점 하나라 면적이 거의 없다 (§3.2)
    @ViewBuilder
    private func badge(_ group: GroupItem) -> some View {
        if group.joined {
            if group.unread {
                Circle()
                    .fill(MyFisColor.accent)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().strokeBorder(MyFisColor.bgBase, lineWidth: 2.5))
            }
        } else {
            // 두 판이 **같은 그림**을 쓴다 — SF Symbol 을 쓰면 안드로이드와 굵기가 달라진다 (§10)
            Image("ic_plus_circle")
                .renderingMode(.template)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundStyle(MyFisColor.textPrimary)
                // 바탕색 고리가 아바타에서 뱃지를 떼어 놓는다
                .background(MyFisColor.bgBase, in: Circle().inset(by: -2.5))
        }
    }

    private static let avatar: CGFloat = 72
}

// MARK: - 세그먼트

/// `둘러보기 · 일정 · 내 모임` — 원본의 알약 세그먼트.
///
/// 원본은 `홈`이지만 우리 앱에는 **홈 탭이 따로 있어** 같은 이름을 두 뜻으로 쓸 수 없다 → `둘러보기`.
/// 고른 칸은 색이 아니라 **판 밝기**로 알린다 (§5.4 다크에서 위계는 표면 밝기다)
private struct SegmentBar: View {
    @Binding var selection: GroupSegment

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GroupSegment.allCases, id: \.self) { item in
                let isSelected = item == selection
                Button { selection = item } label: {
                    Text(item.title)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(isSelected ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: MyFisSize.buttonSecondary)
                        .background {
                            if isSelected {
                                Capsule().fill(MyFisColor.bgBase)
                            }
                        }
                }
                .buttonStyle(.myFisTap)
            }
        }
        .padding(MyFisSpacing.xs)
        .background(MyFisColor.surface1, in: Capsule())
    }
}

// MARK: - 정렬 칩

/// `추천 ⌄ · 인기 · 요즘 뜨는 · 이번 주 열리는` — 원본의 필터 칩 줄.
///
/// 원본은 칩마다 이모지가 붙지만(📈 · 🏪) **우리는 안 붙인다** — 열 줄 남짓한 목록 위에서
/// 이모지 둘은 라임보다 먼저 눈에 띄어 위계를 뒤집는다 (§2 원칙 3)
private struct SortChips: View {
    @Binding var selection: GroupSort

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MyFisSpacing.sm) {
                ForEach(GroupSort.allCases, id: \.self) { item in
                    let isSelected = item == selection
                    Button { selection = item } label: {
                        HStack(spacing: MyFisSpacing.xs) {
                            Text(item.title)
                                .font(MyFisFont.bodySm)
                            // 첫 칩만 여는 칩이다 — 나머지는 켜고 끄는 것
                            if item == .recommended {
                                Image("ic_chevron_down")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                        }
                        .foregroundStyle(isSelected ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                        .padding(.horizontal, MyFisSpacing.md)
                        .frame(height: MyFisSize.chip)
                        .background(
                            isSelected ? MyFisColor.surface2 : Color.clear,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                isSelected ? Color.clear : MyFisColor.borderSubtle,
                                lineWidth: 1
                            )
                        )
                        // 칩은 `36` 이라 그대로 두면 터치 타겟이 `44` 에 못 미친다 (§5.3).
                        // **보이는 높이는 그대로 두고 누르는 넓이만** 위아래로 벌린다
                        .padding(.vertical, (MyFisSize.minTouchTarget - MyFisSize.chip) / 2)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.myFisTap)
                }
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
        }
    }
}

// MARK: - 목록 한 줄

/// 모임 한 줄 — 타일 + 이름 + 한 줄 소개 + 메타.
///
/// **메타가 원본과 다르다.** 원본은 `📍동네 · 👤122명` 인데, 같은 지점 사람들끼리는
/// 동네가 전부 같아 알려 주는 게 없다 → **언제 모이는지**를 그 자리에 넣었다.
/// 들어갈지 말지를 가르는 건 거리가 아니라 **요일·시간**이다
private struct GroupRow: View {
    let group: GroupItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: MyFisSpacing.lg) {
                MyFisIconTile {
                    Image(group.category.icon)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundStyle(MyFisColor.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: MyFisSpacing.sm) {
                        Text(group.name)
                            .font(MyFisFont.titleSm)
                            .foregroundStyle(MyFisColor.textPrimary)
                            .lineLimit(1)
                        if group.joined {
                            Text("참여 중")
                                .font(MyFisFont.caption)
                                .foregroundStyle(MyFisColor.textSecondary)
                                .padding(.horizontal, MyFisSpacing.sm)
                                .padding(.vertical, 2)
                                .background(MyFisColor.surface2, in: Capsule())
                        }
                    }

                    Text(group.summary)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .lineLimit(1)

                    meta
                        .padding(.top, MyFisSpacing.xs)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }

    /// 언제 · 몇 명. 구분은 가운뎃점이 아니라 **세로선**이다 — 점은 시간 글자에 묻힌다 (§6.12 와 같은 규칙)
    private var meta: some View {
        HStack(spacing: 3) {
            Image("ic_quest_attend")
                .renderingMode(.template)
                .resizable()
                .frame(width: 13, height: 13)
            Text(group.schedule)
                .font(MyFisFont.caption)
            Rectangle()
                .fill(MyFisColor.borderStrong)
                .frame(width: 1, height: 10)
                .padding(.horizontal, 2)
            Image("ic_tab_my")
                .renderingMode(.template)
                .resizable()
                .frame(width: 12, height: 12)
            Text("\(group.members)명")
                .font(MyFisFont.caption.monospacedDigit())
        }
        .foregroundStyle(MyFisColor.textTertiary)
        .lineLimit(1)
    }
}

// MARK: - 모델

/// 세 세그먼트 (SPEC G-01)
enum GroupSegment: CaseIterable {
    case browse, schedule, mine

    var title: String {
        switch self {
        case .browse: "둘러보기"
        case .schedule: "일정"
        case .mine: "내 모임"
        }
    }
}

/// 모임 갈래 — **운동 종류로 가른다** 🟢 (2026-09-04, 사용자 지정).
///
/// 원본은 `운동 · 동네친구 · 아웃도어/여행 · 자기계발` 인데 그건 동네 전체를 훑을 때 쓰는 잣대다.
/// 우리는 **헬스장 안**이라 그 넷 중 셋이 빈다
enum GroupCategory: CaseIterable {
    case all, running, weight, classRoom, contest

    var title: String {
        switch self {
        case .all: "전체"
        case .running: "러닝"
        case .weight: "웨이트"
        case .classRoom: "클래스"
        case .contest: "대회"
        }
    }

    /// 갈래마다 다른 그림을 준다 — 줄 목록에서 **글을 안 읽어도** 종류가 보인다
    var icon: String {
        switch self {
        case .all, .classRoom: "ic_tab_group"
        case .running: "ic_tab_cardio"
        case .weight: "ic_tab_weight"
        case .contest: "ic_tab_ranking"
        }
    }
}

/// 정렬·필터 칩 (SPEC G-01)
enum GroupSort: CaseIterable {
    case recommended, popular, rising, thisWeek

    var title: String {
        switch self {
        case .recommended: "추천"
        case .popular: "인기"
        case .rising: "요즘 뜨는"
        case .thisWeek: "이번 주 열리는"
        }
    }
}

/// 모임 하나 (SPEC G-01)
struct GroupItem: Identifiable, Hashable {
    let id: Int
    let category: GroupCategory
    let name: String
    /// 한 줄 소개
    let summary: String
    /// `화·목 저녁` 처럼 **언제 모이는지**
    let schedule: String
    let members: Int
    /// 내가 든 모임인가
    var joined: Bool = false
    /// 안 읽은 글이 있나 — 든 모임에서만 뜻이 있다
    var unread: Bool = false
}

/// TODO(서버): 모임·멤버·일정은 서버가 준다 (SPEC §8). 하드코딩하지 않는다
enum GroupPlaceholder {
    static let branch = "광주 상무"

    static let groups: [GroupItem] = [
        .init(id: 1, category: .running, name: "아침 러닝 크루",
              summary: "출근 전에 한 바퀴 돌고 가요", schedule: "매일 06:00", members: 24,
              joined: true, unread: true),
        .init(id: 2, category: .weight, name: "스쿼트 100개 클럽",
              summary: "하루 100개, 인증만 하면 끝", schedule: "매일 자유", members: 51, joined: true),
        .init(id: 3, category: .classRoom, name: "필라테스 같이 들어요",
              summary: "3인 이상 모이면 그룹 할인", schedule: "화·목 20:00", members: 12),
        .init(id: 4, category: .running, name: "주말 장거리",
              summary: "10km 이상 뛰는 사람만", schedule: "토 08:00", members: 18),
        .init(id: 5, category: .contest, name: "가을 바디 챌린지",
              summary: "8주 뒤 인바디로 순위 가려요", schedule: "10월 1일 시작", members: 87),
        .init(id: 6, category: .weight, name: "3대 500 가자",
              summary: "스쿼트·벤치·데드 합계 올리기", schedule: "월·수·금 19:00", members: 33),
        .init(id: 7, category: .classRoom, name: "초보 요가",
              summary: "처음 오신 분 환영해요", schedule: "일 10:00", members: 9),
        .init(id: 8, category: .contest, name: "10월 마일리지 왕",
              summary: "이번 달 P 제일 많이 모으기", schedule: "10월 한 달", members: 142),
    ]

    /// 가로 줄 — **든 모임이 앞**, 그다음이 추천이다
    static let rail: [GroupItem] = groups.sorted { $0.joined && !$1.joined }
}
