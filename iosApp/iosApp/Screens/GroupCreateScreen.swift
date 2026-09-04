import SwiftUI

/// SPEC.md G-03 모임 개설 (DESIGN.md §6.30).
///
/// 레퍼런스는 **당근 모임 만들기 1단계**다 — `✕` · 큰 질문 · 이름 칸 · 갈래 칩(`더보기`) ·
/// 둘째 칸 · 바닥에 붙은 `다음`.
///
/// **이 화면은 묻는 화면이다.** 그래서 §2 원칙 1 과 달리 **질문이 제일 크다** —
/// 계기판이 아니라 대화다 (G-01 과 같은 예외, §6.29).
///
/// **원본에서 가져온 좋은 동작 둘**
/// - 이름을 치기 시작하면 **질문과 부제가 사라진다.** 화면이 *묻는 중* 에서 *채우는 중* 으로 바뀐다 —
///   다 채운 사람에게 질문을 계속 띄워 둘 이유가 없다
/// - 갈래를 고르면 **그 칩이 맨 앞으로 온다.** 접었을 때도 고른 것이 늘 보인다
///
/// **원본과 다른 것**
/// - 원본의 `활동 지역 · 활동 범위 · 지도` 가 통째로 빠졌다 — **우리 모임은 지점에 매여 있다.**
///   반경도 지도도 물을 게 없다. 그 자리에 **`모이는 때`** 를 넣었다 —
///   친목이든 러닝이든 **들어갈지 말지를 가르는 건 요일·시간**이다 (§6.29 메타와 같은 판단)
/// - `다음` 은 흰색이 아니라 **라임**이다. 원본이 흰색인 건 당근 브랜드색이 주황이라
///   큰 면적에 못 쓰기 때문이고, 우리는 그 제약이 없다
struct GroupCreateScreen: View {
    var onClose: () -> Void = {}
    /// TODO: 2단계(소개·정원)가 붙으면 연결한다
    var onNext: (String, GroupCategory, Set<GroupDay>, GroupTimeSlot?) -> Void = { _, _, _, _ in }

    @State private var name = MyFisDebug.groupCreateFill?.name ?? ""
    @State private var category: GroupCategory? = MyFisDebug.groupCreateFill?.category
    @State private var days: Set<GroupDay> = []
    @State private var slot: GroupTimeSlot?
    @State private var expanded = MyFisDebug.groupCreateFill?.expanded ?? false

    /// 이름과 갈래가 있어야 다음이 뜻이 있다
    private var ready: Bool { !name.trimmed.isEmpty && category != nil }
    /// 질문을 언제까지 띄워 두나 — **이름을 치기 시작하면 물러난다**
    private var asking: Bool { name.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if asking {
                        Text("어떤 모임을 만들까요?")
                            .font(MyFisFont.titleLg)
                            .foregroundStyle(MyFisColor.textPrimary)
                        Text("모임명과 갈래는 만든 뒤에도 바꿀 수 있어요")
                            .font(MyFisFont.bodySm)
                            .foregroundStyle(MyFisColor.textTertiary)
                            .padding(.top, MyFisSpacing.sm)
                            .padding(.bottom, MyFisSpacing.xxl)
                    }

                    Field("모임명") {
                        TextField("", text: $name, prompt: prompt("모임명이 짧을수록 알아보기 쉬워요"))
                            .font(MyFisFont.body)
                            .foregroundStyle(MyFisColor.textPrimary)
                            .tint(MyFisColor.accent)
                            .padding(.horizontal, MyFisSpacing.lg)
                            .frame(height: MyFisSize.inputHeight)
                            .background(
                                MyFisColor.surface2,
                                in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                            )

                        CategoryChips(selection: $category, expanded: $expanded)
                            .padding(.top, MyFisSpacing.md)
                    }

                    // 이름과 갈래가 정해져야 나타난다 — 원본에서 지도가 그렇게 뜬다.
                    // 처음부터 다 보이면 **묻는 게 셋**이 되어 첫 칸에 손이 안 간다
                    if ready {
                        Field("모이는 때") {
                            FlowLayout(spacing: MyFisSpacing.sm) {
                                ForEach(GroupDay.allCases, id: \.self) { day in
                                    PickChip(day.title, selected: days.contains(day), compact: true) {
                                        if days.contains(day) { days.remove(day) } else { days.insert(day) }
                                    }
                                }
                            }
                            FlowLayout(spacing: MyFisSpacing.sm) {
                                ForEach(GroupTimeSlot.allCases, id: \.self) { item in
                                    PickChip(item.title, selected: item == slot) {
                                        slot = (slot == item) ? nil : item
                                    }
                                }
                            }
                            .padding(.top, MyFisSpacing.sm)
                        }
                        .padding(.top, MyFisSpacing.xxl)
                    }
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
            }

            // **바닥에 붙는다.** 다 채우고 누르는 버튼이라 떠 있을 이유가 없다 —
            // 이 화면은 탭 바가 없는 잎이라 §6.28 알약 규칙이 걸리지 않는다
            MyFisPrimaryButton(title: "다음", isEnabled: ready) {
                onNext(name.trimmed, category ?? .weight, days, slot)
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.bottom, MyFisSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// `✕` 하나뿐이다 — 잎 화면이라 뒤가 아니라 **닫는다** (§6.9)
    private var header: some View {
        HStack(spacing: 0) {
            HeaderIcon("ic_header_close", "닫기", action: onClose)
            Spacer(minLength: 0)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }

    private func prompt(_ text: String) -> Text {
        Text(text).foregroundColor(MyFisColor.textTertiary)
    }
}

/// 라벨 + 내용 한 묶음. 이 화면에만 있는 꼴이라 밖으로 안 뺀다
private struct Field<Content: View>: View {
    let label: String
    @ViewBuilder var content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.md) {
            Text(label)
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.textPrimary)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 갈래 칩 + `더보기` / `접기`.
///
/// **고른 것이 맨 앞으로 온다** (원본과 같다) — 접었을 때도 고른 게 늘 보여야 하고,
/// 안 그러면 접는 순간 무엇을 골랐는지 사라진다.
private struct CategoryChips: View {
    @Binding var selection: GroupCategory?
    @Binding var expanded: Bool

    /// 접었을 때 보일 개수. 넷은 한 줄에 안 들어가고 셋이면 `더보기` 까지 한 줄이다
    private static let collapsed = 3

    private var ordered: [GroupCategory] {
        let all = GroupCategory.pickable
        guard let selection, let index = all.firstIndex(of: selection) else { return all }
        var moved = all
        moved.remove(at: index)
        moved.insert(selection, at: 0)
        return moved
    }

    var body: some View {
        FlowLayout(spacing: MyFisSpacing.sm) {
            ForEach(expanded ? ordered : Array(ordered.prefix(Self.collapsed)), id: \.self) { item in
                PickChip(item.title, selected: item == selection) {
                    selection = (selection == item) ? nil : item
                }
            }
            PickChip(expanded ? "접기" : "더보기", chevronUp: expanded) {
                expanded.toggle()
            }
        }
    }
}

/// 고르는 칩.
///
/// ⚠️ 높이는 `size.chip`(36) 이 아니라 **터치 타겟(44)** 이다 — 물 마시기 시각 칩(§6.22)과 같은 규칙이다.
/// 고른 것은 **판을 채우고 글자를 뒤집는다** (원본과 같다) — 다크에서 가장 셀 수 있는 표시다
private struct PickChip: View {
    let title: String
    var selected = false
    /// `더보기` / `접기` 칩만 화살표를 단다. `nil` 이면 안 단다
    var chevronUp: Bool?
    /// 한 글자짜리 요일 칩용 — 여백을 한 단계 좁힌다.
    /// 넓은 채로 두면 **일곱 개가 한 줄에 안 들어가 `일` 이 혼자 다음 줄로 떨어진다**
    var compact = false
    let action: () -> Void

    init(_ title: String, selected: Bool = false, chevronUp: Bool? = nil,
         compact: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.selected = selected
        self.chevronUp = chevronUp
        self.compact = compact
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: MyFisSpacing.xs) {
                Text(title)
                    .font(selected ? MyFisFont.titleSm : MyFisFont.body)
                if let chevronUp {
                    Image("ic_chevron_down")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(chevronUp ? 180 : 0))
                }
            }
            .foregroundStyle(selected ? MyFisColor.onAccent : MyFisColor.textSecondary)
            .padding(.horizontal, compact ? MyFisSpacing.md : MyFisSpacing.lg)
            .frame(height: MyFisSize.minTouchTarget)
            .background(selected ? MyFisColor.textPrimary : Color.clear, in: Capsule())
            .overlay(
                Capsule().strokeBorder(
                    selected ? Color.clear : MyFisColor.borderSubtle,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.myFisTap)
    }
}

// MARK: - 모델

/// 무슨 요일에 모이나 (SPEC G-03)
enum GroupDay: CaseIterable {
    case mon, tue, wed, thu, fri, sat, sun

    var title: String {
        switch self {
        case .mon: "월"
        case .tue: "화"
        case .wed: "수"
        case .thu: "목"
        case .fri: "금"
        case .sat: "토"
        case .sun: "일"
        }
    }
}

/// 하루 중 언제 (SPEC G-03) — 시각을 분 단위로 묻지 않는다.
/// **모임은 대개 "저녁쯤"으로 정해지고**, 분까지 물으면 만들기가 무거워진다
enum GroupTimeSlot: CaseIterable {
    case dawn, morning, noon, evening, free

    var title: String {
        switch self {
        case .dawn: "새벽"
        case .morning: "아침"
        case .noon: "점심"
        case .evening: "저녁"
        case .free: "자유"
        }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
