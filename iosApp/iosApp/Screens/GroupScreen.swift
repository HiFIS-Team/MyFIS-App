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
    /// 헤더 돋보기 → **검색 잎(G-01 검색)** 을 연다.
    /// ⚠️ 전에는 셸이 이걸 아무 데도 안 이어 줘서 **눌러도 아무 일이 없었다**
    var onSearch: () -> Void = {}

    @State private var segment: GroupSegment = .browse
    @State private var category: GroupCategory = .all
    @State private var sort: GroupSort = MyFisDebug.initialGroupSort
    @State private var order: GroupOrder = .recommended

    private var rows: [GroupItem] {
        GroupPlaceholder.groups.filter { category == .all || $0.category == category }
    }

    /// `인기` — 이번 주 점수 차례. **50 등까지 센다** (원본 `Top 50`)
    private var ranked: [GroupItem] { rows.sorted { $0.score > $1.score }.prefix(50).map { $0 } }

    /// `요즘 뜨는` — **일정을 모으는 중이거나 이제 막 생긴 것**.
    /// 오래되고 조용한 모임은 여기 오면 안 된다
    private var rising: [GroupItem] { rows.filter { $0.recruiting || $0.isNew } }

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

                        SortChips(selection: $sort, order: $order)
                            .padding(.top, MyFisSpacing.md)

                        // **칩이 목록의 종류를 바꾼다** 🟢 (2026-09-04, 사용자 지정) —
                        // 걸러 내기만 하는 게 아니라 **다른 것을 보여 준다**
                        switch sort {
                        case .popular:
                            RankHeader()
                            ForEach(Array(ranked.enumerated()), id: \.element.id) { index, group in
                                RankRow(rank: index + 1, group: group, onTap: { onGroup(group) })
                            }
                        case .rising:
                            ForEach(rising) { group in
                                RisingRow(group: group, onTap: { onGroup(group) })
                            }
                            .padding(.top, MyFisSpacing.xs)
                        default:
                            ForEach(rows) { group in
                                GroupRow(group: group, onTap: { onGroup(group) })
                            }
                            .padding(.top, MyFisSpacing.xs)
                        }
                    }
                    // 알약이 마지막 줄을 가리지 않게 그만큼 비워 둔다 (유산소와 같은 규칙)
                    .padding(.bottom, MyFisSize.buttonSecondary + MyFisSpacing.xxxl)
                }

                // 이 화면의 액션은 이 하나뿐 (§2 원칙 5) — **오른쪽 아래**, 엄지가 닿는 자리다 (원칙 2).
                // 원본(당근)도 우하단이고 유산소(§6.28)도 같은 자리다
                MyFisPrimaryButton(title: "＋ 모임 만들기", pill: true, action: onCreate)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, MyFisSpacing.screenHorizontal)
                    .padding(.bottom, MyFisSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// **화면 이름 한 줄** 🟢 (2026-09-04, 사용자 지정).
    ///
    /// 전에는 `{지점}의 모임` 이었다 — 모임이 지점에 매여 있다고 봤기 때문인데,
    /// **활동 지역(§6.30)이 들어오면서 그 전제가 없어졌다.** 지점을 헤더에 계속 걸어 두면
    /// 목록이 지점 것만인 줄 읽힌다.
    /// 원본 헤더의 셋(검색·알림·메뉴) 중 알림은 셸이 이미 들고 있고 메뉴는 우리에게 없다 → 검색만 남긴다
    private var header: some View {
        HStack(spacing: 0) {
            Text("모임")
                // 화면 이름은 `title.lg` 다 (§4.2 · §6.9, 2026-09-04)
                .font(MyFisFont.titleLg)
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

    private var index: Int { GroupSegment.allCases.firstIndex(of: selection) ?? 0 }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GroupSegment.allCases, id: \.self) { item in
                Button { selection = item } label: {
                    Text(item.title)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(item == selection ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: MyFisSize.buttonSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.myFisTap)
            }
        }
        // **고른 칸이 미끄러져 간다** 🟢 (2026-09-04, 사용자 지정) — 갈래 줄 밑줄(§6.29)과 같은 규칙.
        // 칸마다 판을 켰다 끄면 **어디서 어디로 갔는지가 안 보인다.**
        // 판 하나를 두고 **자리를 옮긴다** — 칸 셋이 폭을 고르게 나눠 가지므로 순번만 알면 자리가 나온다
        .background(alignment: .leading) {
            GeometryReader { geo in
                let slot = geo.size.width / CGFloat(GroupSegment.allCases.count)
                Capsule()
                    .fill(MyFisColor.bgBase)
                    .frame(width: slot)
                    .offset(x: slot * CGFloat(index))
                    // 고르는 동작이라 `fast`(120ms) — §7
                    .animation(MyFisMotion.fast, value: selection)
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
    @Binding var order: GroupOrder
    /// 차례 고르는 목록이 열려 있는지 (§6.34)
    @State private var orderOpen = MyFisDebug.groupOrderOpen

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MyFisSpacing.sm) {
                // **첫 칩만 여는 칩이다** — 나머지는 켜고 끄는 것.
                // 여는 판은 **우리 면으로 그린다** (§6.34) — 시스템 `Menu` 는 목록을 유리로 띄우는데
                // 이 앱에 그 재질은 여기밖에 없고, 안드로이드는 같은 자리를 평면으로 그린다
                // **필터가 켜져 있으면 누를 때 되돌아가기만 한다** 🟢 (2026-09-04, 사용자 지정).
                // `인기` 를 보다가 `추천` 을 누르는 사람은 **차례를 고르려는 게 아니라 원래 목록으로 가려는 것**이다 —
                // 거기서 메뉴를 열면 한 번 더 눌러야 돌아간다.
                // 차례 고르기는 **이미 추천을 보고 있을 때**만 뜻이 있다
                Button {
                    if selection != .none { selection = .none } else { orderOpen = true }
                } label: {
                    chip(order.title, selected: selection == .none, chevron: true)
                }
                .buttonStyle(.myFisTap)
                .myFisDropdown(isPresented: $orderOpen, options: GroupOrder.allCases,
                               selection: $order, title: { $0.title })

                ForEach(GroupSort.allCases, id: \.self) { item in
                    Button { selection = (selection == item) ? .none : item } label: {
                        chip(item.title, selected: item == selection, chevron: false)
                    }
                    .buttonStyle(.myFisTap)
                }
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
        }
    }

    private func chip(_ title: String, selected: Bool, chevron: Bool) -> some View {
        HStack(spacing: MyFisSpacing.xs) {
            Text(title)
                .font(MyFisFont.bodySm)
            if chevron {
                Image("ic_chevron_down")
                    .resizable()
                    .frame(width: 14, height: 14)
            }
        }
        .foregroundStyle(selected ? MyFisColor.textPrimary : MyFisColor.textTertiary)
        .padding(.horizontal, MyFisSpacing.md)
        .frame(height: MyFisSize.chip)
        .background(selected ? MyFisColor.surface2 : Color.clear, in: Capsule())
        .overlay(
            Capsule().strokeBorder(selected ? Color.clear : MyFisColor.borderSubtle, lineWidth: 1)
        )
        // 칩은 `36` 이라 그대로 두면 터치 타겟이 `44` 에 못 미친다 (§5.3).
        // **보이는 높이는 그대로 두고 누르는 넓이만** 위아래로 벌린다
        .padding(.vertical, (MyFisSize.minTouchTarget - MyFisSize.chip) / 2)
        .contentShape(Rectangle())
    }
}

// MARK: - 목록 한 줄

/// 모임 한 줄 — 타일 + 이름 + 한 줄 소개 + 메타.
///
/// **메타가 원본과 다르다.** 원본은 `📍동네 · 👤122명` 인데, 같은 지점 사람들끼리는
/// 동네가 전부 같아 알려 주는 게 없다 → **언제 모이는지**를 그 자리에 넣었다.
/// 들어갈지 말지를 가르는 건 거리가 아니라 **요일·시간**이다
/// 목록 한 줄. **검색 결과도 이 줄을 쓴다** (`GroupSearchScreen`) — 두 곳이 각자 그리면 그날로 어긋난다
struct GroupRow: View {
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

/// `인기` 목록 머리 — **이번 주 몇 등인지 말해 주는 줄**.
///
/// 원본은 1위 줄을 **주황**으로 칠하는데 우리는 색이 하나고 그 라임은
/// `＋ 모임 만들기` 와 안 읽은 점이 이미 쓰고 있다 (§3.2 상한) →
/// **표면 밝기로 세운다** (§5.4 다크에서 위계는 밝기다)
private struct RankHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
            HStack(spacing: 0) {
                Text("이번 주 모임 Top 50")
                    .font(MyFisFont.titleMd)
                    .foregroundStyle(MyFisColor.textPrimary)
                Spacer(minLength: MyFisSpacing.md)
                // TODO: 순위 산정 기준 안내가 붙으면 연결한다
                Image("ic_my_ask")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(MyFisColor.textTertiary)
            }
            HStack(spacing: MyFisSpacing.sm) {
                Text("9월 1주차(월-일) 실시간")
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textTertiary)
                // TODO: 지난 주 랭킹 화면이 붙으면 연결한다
                HStack(spacing: 2) {
                    Text("지난 주")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textPrimary)
                    Image("ic_chevron_down")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
        .padding(.top, MyFisSpacing.lg)
        .padding(.bottom, MyFisSpacing.md)
    }
}

/// 순위 한 줄 — 순번 + 타일 + 이름·동네 + 점수.
///
/// **1등만 판을 올린다.** 셋을 올리면 시상대가 되고, 이 목록은 시상대가 아니라 **순위표**다
private struct RankRow: View {
    let rank: Int
    let group: GroupItem
    let onTap: () -> Void

    private var top: Bool { rank == 1 }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MyFisSpacing.md) {
                Text("\(rank)")
                    .font(MyFisFont.titleSm.monospacedDigit())
                    .foregroundStyle(top ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                    .frame(width: 24, alignment: .center)

                MyFisIconTile {
                    Image(group.category.icon)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundStyle(MyFisColor.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .lineLimit(1)
                    RegionLine(group.region)
                }

                Spacer(minLength: MyFisSpacing.sm)

                Text("\(group.score.decimal)점")
                    .font(MyFisFont.titleSm.monospacedDigit())
                    .foregroundStyle(top ? MyFisColor.textPrimary : MyFisColor.textTertiary)
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.vertical, MyFisSpacing.md)
            .background(top ? MyFisColor.surface1 : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }
}

/// `요즘 뜨는` 한 줄 — **메타가 다르다.** 언제 모이는지 대신 **동네 · 사람 수 · 모집 중**이다.
///
/// 여기 오는 모임은 *지금 사람을 받는* 모임이라, 고를 때 궁금한 것이 요일이 아니라
/// **들어갈 자리가 있느냐**다
private struct RisingRow: View {
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
                    Text(group.name)
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .lineLimit(1)
                    Text(group.summary)
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .lineLimit(1)

                    HStack(spacing: MyFisSpacing.sm) {
                        RegionLine(group.region)
                        Text(group.isNew ? "신규 모임" : "\(group.members)명")
                            .font(MyFisFont.caption.monospacedDigit())
                            .foregroundStyle(MyFisColor.textTertiary)
                        if group.recruiting {
                            // **상태다** — `info`(안내) 로 적는다. 라임이 아니라 §3.2 상한을 안 건드린다
                            Text("일정 모집 중")
                                .font(MyFisFont.caption)
                                .foregroundStyle(MyFisColor.info)
                        }
                    }
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
}

/// 핀 + 동네. 두 목록이 같이 쓴다
private struct RegionLine: View {
    let region: String

    init(_ region: String) { self.region = region }

    var body: some View {
        HStack(spacing: 3) {
            Image("ic_place_pin")
                .renderingMode(.template)
                .resizable()
                .frame(width: 12, height: 12)
            Text(region)
                .font(MyFisFont.caption)
                .lineLimit(1)
        }
        .foregroundStyle(MyFisColor.textTertiary)
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

/// 모임 갈래 — **운동 반 · 친목 반** 🟢 (2026-09-04, 사용자 지정).
///
/// 처음엔 `러닝 · 웨이트 · 클래스 · 대회` 넷이었는데 **운동만 담겼다.**
/// 이 탭은 *운동 모임*이 아니라 **같은 헬스장 사람들이 친해지는 자리**라
/// 밥·정보·나들이가 갈 데가 없었다 → 넷을 더했다.
///
/// 원본(당근)은 `운동 · 동네친구 · 아웃도어/여행 · 자기계발 …` 열둘인데,
/// 그건 **동네 전체**를 훑을 때 쓰는 잣대다. 한 지점 모임은 열 개 남짓이라
/// 열둘이면 갈래당 한 개도 안 된다 — **여덟이 우리 크기다.**
///
/// ⚠️ **이 목록이 앱의 유일한 갈래 벌이다.** 모임 개설(G-03) 칩도 이걸 그대로 쓴다
enum GroupCategory: CaseIterable {
    case all, weight, running, classRoom, outdoor, social, diet, info, contest

    /// 만들 때 고를 수 있는 것 — `전체` 는 목록 갈래 줄에만 있는 자리다
    static var pickable: [GroupCategory] { allCases.filter { $0 != .all } }

    var title: String {
        switch self {
        case .all: "전체"
        case .weight: "웨이트"
        case .running: "러닝"
        case .classRoom: "클래스"
        case .outdoor: "아웃도어"
        case .social: "친목"
        case .diet: "식단"
        case .info: "정보공유"
        case .contest: "대회"
        }
    }

    /// 갈래마다 다른 그림을 준다 — 줄 목록에서 **글을 안 읽어도** 종류가 보인다.
    /// 새 그림을 그리지 않고 **있는 것에서 골랐다** (§8: 28px 에서 뭘로 읽히는지)
    var icon: String {
        switch self {
        case .all: "ic_tab_group"
        case .weight: "ic_tab_weight"
        case .running: "ic_tab_cardio"
        // ⚠️ `ic_place_stretch`(요가 매트)는 **원색 두 톤 지도용**이라
        // 한 색으로 누르면 둥근 덩어리가 된다 (2026-09-04 확인, §8)
        case .classRoom: "ic_benefit_stretch"
        // 밖으로 나간다 — 핀이 그 뜻을 제일 짧게 낸다
        case .outdoor: "ic_place_pin"
        // 잔 두 개. 밥·커피 모임이라 먹는 그림이어야 한다
        case .social: "ic_tab_store"
        case .diet: "ic_home_diet"
        case .info: "ic_quest_board"
        case .contest: "ic_tab_ranking"
        }
    }
}

/// **여는 칩** — 목록을 무슨 차례로 볼지 (SPEC G-01) 🟢 (2026-09-04, 사용자 지정).
///
/// 전에는 `추천` 이 켜고 끄는 칩이었는데, **차례는 켜고 끄는 게 아니라 하나를 고르는 것**이다.
/// 그래서 여는 칩으로 바꾸고 목록을 달았다
enum GroupOrder: CaseIterable {
    case recommended, latest

    var title: String {
        switch self {
        case .recommended: "추천"
        case .latest: "최신순"
        }
    }
}

/// **켜고 끄는 칩** — 목록을 좁힌다 (SPEC G-01).
/// `none` 은 아무것도 안 켠 상태다 — 칩은 다시 누르면 꺼진다
enum GroupSort: CaseIterable {
    case none, popular, rising, thisWeek

    /// 칩으로 그리는 것만. `none` 은 상태이지 칩이 아니다
    static var allCases: [GroupSort] { [.popular, .rising, .thisWeek] }

    var title: String {
        switch self {
        case .none: ""
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
    /// 어느 동네에서 모이나 (§6.30 활동 지역) — `인기`·`요즘 뜨는` 목록이 쓴다
    let region: String
    /// 이번 주 랭킹 점수 (`인기`). TODO(서버): 활동량으로 서버가 낸다
    let score: Int
    /// 일정을 모으는 중인가 (`요즘 뜨는`)
    var recruiting: Bool = false
    /// 이제 막 생긴 모임 — 사람 수 대신 `신규 모임` 이라 적는다
    var isNew: Bool = false
    /// 내가 든 모임인가
    var joined: Bool = false
    /// 안 읽은 글이 있나 — 든 모임에서만 뜻이 있다
    var unread: Bool = false
}

/// TODO(서버): 모임·멤버·일정은 서버가 준다 (SPEC §8). 하드코딩하지 않는다
enum GroupPlaceholder {
    static let branch = "광주 상무"

    /// 개설 화면 칩에 바로 뜨는 셋 (§6.30) — 지점 동네와 그 옆이다
    static let regions = ["치평동", "화정동", "광천동"]

    /// 활동 지역 설정(§6.31) 목록. **칩 셋으로는 부족해서 있는 목록이다**.
    /// TODO(서버): 지점 좌표로 가까운 동네를 거리순으로 받아 온다
    static let nearbyRegions = [
        "치평동", "화정동", "광천동", "농성동", "유덕동", "쌍촌동",
        "금호동", "마륵동", "서창동", "풍암동", "동천동", "매곡동",
    ]

    /// 목록에 적는 온전한 이름 — 동 이름만 두면 어느 도시인지 모른다
    static func fullName(_ region: String) -> String { "광주광역시 서구 \(region)" }

    static let groups: [GroupItem] = [
        .init(id: 1, category: .running, name: "아침 러닝 크루",
              summary: "출근 전에 한 바퀴 돌고 가요", schedule: "매일 06:00", members: 24,
              region: "서구 치평동", score: 10_483, recruiting: true, joined: true, unread: true),
        .init(id: 2, category: .weight, name: "스쿼트 100개 클럽",
              summary: "하루 100개, 인증만 하면 끝", schedule: "매일 자유", members: 51,
              region: "서구 화정동", score: 4_280, joined: true),
        .init(id: 3, category: .classRoom, name: "필라테스 같이 들어요",
              summary: "3인 이상 모이면 그룹 할인", schedule: "화·목 20:00", members: 12,
              region: "서구 농성동", score: 4_148, recruiting: true),
        .init(id: 4, category: .social, name: "운동 끝나고 한 잔",
              summary: "단백질 쉐이크든 맥주든", schedule: "금 21:00", members: 37,
              region: "서구 치평동", score: 2_981),
        .init(id: 5, category: .diet, name: "도시락 같이 싸요",
              summary: "일요일에 한 주치 준비", schedule: "일 14:00", members: 19,
              region: "서구 쌍촌동", score: 2_543, recruiting: true),
        .init(id: 6, category: .outdoor, name: "주말 등산",
              summary: "무등산부터 시작해요", schedule: "토 07:00", members: 26,
              region: "북구 두암동", score: 1_592),
        .init(id: 7, category: .weight, name: "3대 500 가자",
              summary: "스쿼트·벤치·데드 합계 올리기", schedule: "월·수·금 19:00", members: 33,
              region: "서구 화정동", score: 1_163),
        .init(id: 8, category: .contest, name: "가을 바디 챌린지",
              summary: "8주 뒤 인바디로 순위 가려요", schedule: "10월 1일 시작", members: 87,
              region: "서구 치평동", score: 985, recruiting: true),
        .init(id: 9, category: .info, name: "보충제·장비 정보방",
              summary: "뭐 살지 물어보는 곳", schedule: "아무 때나", members: 64,
              region: "남구 봉선동", score: 742),
        .init(id: 10, category: .classRoom, name: "초보 요가",
              summary: "처음 오신 분 환영해요", schedule: "일 10:00", members: 9,
              region: "서구 광천동", score: 613, recruiting: true, isNew: true),
        .init(id: 11, category: .social, name: "퇴근하고 볼링",
              summary: "점수 못 내도 괜찮아요", schedule: "수 20:00", members: 0,
              region: "서구 화정동", score: 480, recruiting: true, isNew: true),
        .init(id: 12, category: .running, name: "동네방네 러닝",
              summary: "혼자 뛰는 게 지루해진 분 환영", schedule: "화·목 20:00", members: 13,
              region: "서구 화정동", score: 402, recruiting: true),
    ]

    /// 가로 줄 — **든 모임이 앞**, 그다음이 추천이다
    static let rail: [GroupItem] = groups.sorted { $0.joined && !$1.joined }
}
