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
    /// §6.31 활동 지역 설정으로 — 칩에 없는 동네를 찾을 때
    var onSearchRegion: () -> Void = {}
    /// TODO: 2단계(소개·정원)가 붙으면 연결한다
    var onNext: (String, GroupCategory, String?) -> Void = { _, _, _ in }

    @State private var name = MyFisDebug.groupCreateFill?.name ?? ""
    @State private var category: GroupCategory? = MyFisDebug.groupCreateFill?.category
    @Binding var region: String?
    @State private var range = 0
    @State private var expanded = MyFisDebug.groupCreateFill?.expanded ?? false

    /// 이름과 갈래가 있어야 다음이 뜻이 있다
    private var ready: Bool { !name.trimmed.isEmpty && category != nil }

    /// **칩은 애니메이션 없이 즉시 바뀐다** 🟢 (2026-09-04, 사용자 지정).
    ///
    /// 고른 칩이 맨 앞으로 미끄러져 가면 **고르는 동작이 기다리는 동작이 된다** —
    /// 목록이 갈리듯 그 자리에서 바뀌어야 빠르게 읽힌다 (§7 고르는 동작은 `fast`, 여기는 아예 0)
    private func instantly(_ change: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, change)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // **질문은 안 사라진다** 🟢 (2026-09-04, 사용자 지정).
                    // 원본은 치기 시작하면 접는데, 그러면 **스크롤해서 돌아왔을 때
                    // 여기가 무슨 화면인지 다시 알려 줄 게 없다**
                    Text("어떤 모임을 만들까요?")
                        .font(MyFisFont.titleLg)
                        .foregroundStyle(MyFisColor.textPrimary)
                    Text("모임명과 갈래는 만든 뒤에도 바꿀 수 있어요")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textTertiary)
                        .padding(.top, MyFisSpacing.sm)
                        .padding(.bottom, MyFisSpacing.xxl)

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

                    // **활동 지역** 🟢 (2026-09-04, 사용자 지정).
                    //
                    // 처음엔 `모이는 때`(요일·시간) 를 뒀었다 — 모임이 지점에 매여 있으니
                    // 지역을 물을 게 없다고 봤는데, **그 전제가 틀렸다.**
                    // 이 탭의 취지가 *회원이 헬스장에만 묶이지 않는 것* 이라
                    // **밖에서 모이는 자리**가 오히려 본령이다. 그래서 원본처럼 지역을 묻는다.
                    //
                    // 이름·갈래를 안 채워도 처음부터 보인다 — 원본도 그렇다
                    Field("활동 지역") {
                        FlowLayout(spacing: MyFisSpacing.sm) {
                            // 목록에 없는 동네는 찾아서 고른다 (원본과 같은 자리)
                            PickChip("검색", icon: "ic_header_search", action: onSearchRegion)
                            ForEach(GroupPlaceholder.regions, id: \.self) { item in
                                PickChip(item, selected: item == region) {
                                    instantly { region = (region == item) ? nil : item }
                                }
                            }
                        }
                    }
                    .padding(.top, MyFisSpacing.xxl)

                    // 지역을 고르면 **얼마나 넓게 볼지**가 그다음 물음이다 (원본과 같은 순서)
                    if region != nil {
                        Field("활동 범위") {
                            MyFisSlider(step: $range)
                            HStack(spacing: 0) {
                                Text("가까운 동네")
                                Spacer(minLength: MyFisSpacing.md)
                                Text("먼 동네")
                            }
                            .font(MyFisFont.bodySm)
                            .foregroundStyle(MyFisColor.textTertiary)

                            RangePreview(step: range)
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
                onNext(name.trimmed, category ?? .weight, region)
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
                    instantly { selection = (selection == item) ? nil : item }
                }
            }
            PickChip(expanded ? "접기" : "더보기", chevronUp: expanded) {
                instantly { expanded.toggle() }
            }
        }
        // 들어온 애니메이션을 여기서 끊는다 — 칩이 미끄러지면 고르는 동작이 기다리는 동작이 된다
        .transaction { $0.animation = nil }
    }

    /// 칩 자리는 **그 자리에서 바뀐다** (2026-09-04, 사용자 지정)
    private func instantly(_ change: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, change)
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
    /// 글자 앞에 붙는 그림. 지역 `검색` 칩만 쓴다
    var icon: String?
    let action: () -> Void

    init(_ title: String, selected: Bool = false, chevronUp: Bool? = nil,
         icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.selected = selected
        self.chevronUp = chevronUp
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: MyFisSpacing.xs) {
                if let icon {
                    Image(icon)
                        .resizable()
                        .frame(width: 16, height: 16)
                }
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
            .padding(.horizontal, MyFisSpacing.lg)
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

/// 고른 범위가 얼마나 넓은지 보여 주는 판.
///
/// ⚠️ **지도가 아니다.** 원본은 진짜 지도 위에 반경을 얹는데 우리에겐 지도가 없다 —
/// **가짜 길과 가짜 동네 이름을 그리지 않는다.** 진짜 자리처럼 보이는 게 없다는 것보다 나쁘다.
/// 원과 눈금만으로 "이만큼"을 말하고, 지도는 붙을 때 이 판을 통째로 갈아 끼운다.
///
/// TODO(지도): MapKit / Google Maps 가 붙으면 여기를 지도 + 반경 원으로 바꾼다
private struct RangePreview: View {
    let step: Int

    var body: some View {
        ZStack {
            // 눈금 원 — 단계가 몇인지 원 하나만으로는 안 보인다
            ForEach(0 ..< 4, id: \.self) { index in
                Circle()
                    .strokeBorder(MyFisColor.surface3, lineWidth: 1)
                    .frame(width: diameter(index), height: diameter(index))
            }
            Circle()
                .fill(MyFisColor.surface3.opacity(0.5))
                .frame(width: diameter(step), height: diameter(step))
                .overlay(
                    Circle().strokeBorder(MyFisColor.borderStrong, lineWidth: 1)
                        .frame(width: diameter(step), height: diameter(step))
                )
            Image("ic_header_branch")
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(MyFisColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(
            MyFisColor.surface2,
            in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        )
        // 원이 커지는 건 **값이 자라는 것**이라 애니메이션을 준다 (칩과 반대다, §7)
        .animation(MyFisMotion.base, value: step)
    }

    private func diameter(_ index: Int) -> CGFloat { 60 + CGFloat(index) * 44 }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
