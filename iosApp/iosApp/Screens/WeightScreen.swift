import SwiftUI

// MARK: - 모델
//
// TODO(서버): 주간 루틴 API (SPEC §8) 가 붙으면 이 자리를 받아온 값으로 채운다.

/// 그 운동을 하는 **구역** — M-08 기구 찾기가 나누는 넷과 같은 단위다 (§6.26).
enum RoutineGear {
    case free, machine, stretch

    var icon: String {
        switch self {
        case .free: "ic_place_free"
        case .machine: "ic_place_machine"
        case .stretch: "ic_benefit_stretch"
        }
    }
}

/// 오늘 루틴의 운동 한 줄
struct RoutineExercise: Identifiable, Equatable {
    let id: Int
    let name: String
    let gear: RoutineGear
    let sets: Int
    /// `20kg` · 맨몸이면 `nil`
    let load: String?
    let reps: Int

    /// `4세트 × 20kg × 12회` — SPEC W-02 표기. 곱하기 기호는 SPEC 을 따른다
    var prescription: String {
        [["\(sets)세트"], load.map { [$0] } ?? [], ["\(reps)회"]]
            .flatMap { $0 }
            .joined(separator: " × ")
    }
}

/// 이번 주 띠의 한 칸
struct RoutineDay: Identifiable {
    let id: Int
    let weekday: String
    /// 그날의 부위. 쉬는 날은 `휴식`
    let focus: String
    let rest: Bool
    let done: Bool
    let today: Bool
}

/// TODO(서버): 아래 전부 자리 표시다 (SPEC W-01)
enum RoutinePlaceholder {
    static let week: [RoutineDay] = [
        RoutineDay(id: 0, weekday: "일", focus: "휴식", rest: true, done: false, today: false),
        RoutineDay(id: 1, weekday: "월", focus: "등", rest: false, done: true, today: false),
        RoutineDay(id: 2, weekday: "화", focus: "하체", rest: false, done: true, today: false),
        RoutineDay(id: 3, weekday: "수", focus: "휴식", rest: true, done: false, today: false),
        RoutineDay(id: 4, weekday: "목", focus: "어깨", rest: false, done: true, today: false),
        RoutineDay(id: 5, weekday: "금", focus: "가슴", rest: false, done: false, today: true),
        RoutineDay(id: 6, weekday: "토", focus: "팔", rest: false, done: false, today: false),
    ]

    static let warmup = ["목 돌리기", "어깨 돌리기", "가슴 열기", "팔 돌리기", "손목 풀기"]
    static let warmupMinutes = 6

    static let exercises: [RoutineExercise] = [
        RoutineExercise(id: 1, name: "스미스 머신 벤치 프레스", gear: .machine, sets: 4, load: "20kg", reps: 12),
        RoutineExercise(id: 2, name: "인클라인 덤벨 프레스", gear: .free, sets: 3, load: "10kg", reps: 12),
        RoutineExercise(id: 3, name: "체스트 프레스 머신", gear: .machine, sets: 3, load: "25kg", reps: 15),
        RoutineExercise(id: 4, name: "케이블 크로스오버", gear: .machine, sets: 3, load: "7.5kg", reps: 15),
        RoutineExercise(id: 5, name: "딥스", gear: .free, sets: 3, load: nil, reps: 10),
        RoutineExercise(id: 6, name: "케이블 푸시다운", gear: .machine, sets: 3, load: "15kg", reps: 15),
    ]

    /// 오늘 쓸 수 있는 시간 — 고르면 서버가 분량을 맞춰 다시 짠다
    static let minuteOptions = [30, 45, 60, 75, 90]
    static let minutes = 60
    /// 오늘 몸 상태. 낮추면 세트·중량이 내려간다
    static let conditionOptions = [100, 80, 60, 40]
    static let condition = 100
}

// MARK: - 화면

/// SPEC.md W-01 웨이트 탭 — **오늘의 루틴** (DESIGN.md §6.33)
///
/// 레퍼런스는 사용자가 준 다른 앱의 `오늘의 추천 운동` 화면이다.
/// **뼈대만 가져오고 표면은 우리 것으로 다시 짠다** (§3.2) —
/// 원본은 운동마다 3D 근육 렌더에 민트를 칠해 **색이 여덟 곳**이지만
/// 우리는 액센트가 화면당 두 곳이라 **알약 하나**에만 쓴다. 위계는 표면 밝기로 세운다 (§5.4).
///
/// **썸네일이 말하는 것도 바꿨다** — 원본은 *어느 근육*, 우리는 **어느 구역의 기구**다.
/// 초보자가 헬스장에서 실제로 막히는 지점은 근육 이름이 아니라 *그 기구가 어디 있나*이고,
/// 그 답은 M-08 기구 찾기가 이미 들고 있다 (§6.26 과 같은 넷으로 나눈다).
///
/// **SPEC 의 W-01(이번 주)과 W-02(오늘)를 한 장으로 합쳤다** 🟢 (2026-09-04, 사용자 지정) —
/// 주간 목록만 있는 화면은 §6.28 유산소에서 이미 한 번 걸린 함정이다. *다 본 뒤에 할 일이 없다.*
/// 주차는 맨 위 **요일 일곱 칸 띠**로 압축하고 본문은 오늘 할 것에 준다.
struct WeightScreen: View {
    /// 순서를 바꾸므로 화면이 들고 있는다. TODO(서버): 바뀐 순서를 올린다
    @State private var exercises = RoutinePlaceholder.exercises
    @State private var warmupOpen = MyFisDebug.weightWarmupOpen
    @State private var reordering = MyFisDebug.weightReordering
    @State private var minutes = RoutinePlaceholder.minutes
    @State private var condition = RoutinePlaceholder.condition

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        WeekStrip(days: RoutinePlaceholder.week)
                        conditionRow
                            .padding(.top, MyFisSpacing.sectionGap)
                        listHeader
                            .padding(.top, MyFisSpacing.sectionGap)
                        list
                            .padding(.top, MyFisSpacing.sm)
                    }
                    .padding(.horizontal, MyFisSpacing.screenHorizontal)
                    // 알약이 마지막 줄을 가리지 않게 그만큼 비워 둔다 (§6.28 과 같은 값)
                    .padding(.bottom, MyFisSize.buttonSecondary + MyFisSpacing.xxxl)
                }

                // 이 화면의 액션은 이 하나뿐 (§2 원칙 5). 폭을 다 쓰면 떠 있는 탭 바와
                // 둥근 덩어리가 둘로 겹치므로 **알약**으로 맞춘다 (§6.28)
                MyFisPrimaryButton(title: "운동 시작", pill: true, action: {})
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, MyFisSpacing.screenHorizontal)
                    .padding(.bottom, MyFisSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// 유산소(§6.28) · 모임(§6.29) 과 같은 꼴 — **화면 이름 한 줄 + 마일리지 칩**
    private var header: some View {
        HStack(spacing: MyFisSpacing.md) {
            Text("웨이트")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textPrimary)

            Spacer(minLength: MyFisSpacing.md)

            MileageChip(balance: BenefitPlaceholder.balance)
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }

    /// 오늘의 조건 두 칸 — 고치면 **분량이 다시 짜인다**.
    ///
    /// 원본은 칸마다 아이콘을 달았지만 우리는 **글자만 둔다** —
    /// `시계`·`번개` 는 28px 에서 다른 뜻으로 읽히기 쉬운 그림이고(§8),
    /// 두 글자짜리 라벨이 이미 충분히 짧다.
    private var conditionRow: some View {
        HStack(spacing: MyFisSpacing.cardGap) {
            SelectorCard(label: "운동 시간", options: RoutinePlaceholder.minuteOptions,
                         format: { "\($0)분" }, value: $minutes)
            SelectorCard(label: "컨디션", options: RoutinePlaceholder.conditionOptions,
                         format: { "\($0)%" }, value: $condition)
        }
    }

    /// `총 n개` ↔ `순서 변경`.
    ///
    /// **슈퍼세트는 두지 않았다** 🟢 (2026-09-04, 사용자 지정) — 두 운동을 쉬지 않고 묶는 건
    /// 중급자 개념이고, 우리 타깃은 *기구를 거의 안 써 본* 회원이다 (SPEC `BEGINNER`).
    private var listHeader: some View {
        HStack(spacing: MyFisSpacing.md) {
            Text("총 \(exercises.count + 1)개")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.textSecondary)

            Spacer(minLength: 0)

            MyFisSmallButton(title: reordering ? "완료" : "순서 변경") {
                withAnimation(MyFisMotion.base) {
                    reordering.toggle()
                    if reordering { warmupOpen = false }
                }
            }
        }
    }

    /// 웜업 한 줄 + 운동들. 구분선은 **좌측 인덴트 없이 전체 너비**다 (§6.5)
    private var list: some View {
        VStack(spacing: 0) {
            // 웜업은 순서를 바꾸는 대상이 아니다 — 몸을 푸는 게 먼저라서 늘 맨 앞이다.
            // 순서 모드에서는 아예 빼서 **번호가 운동만 세게** 한다
            if !reordering {
                WarmupRow(open: $warmupOpen)
                divider
            }

            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, item in
                ExerciseRow(item: item, index: index, reordering: reordering,
                            last: index == exercises.count - 1,
                            onUp: { move(index, by: -1) },
                            onDown: { move(index, by: 1) })
                if index < exercises.count - 1 { divider }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(MyFisColor.borderSubtle)
            .frame(height: 1)
    }

    private func move(_ index: Int, by delta: Int) {
        let target = index + delta
        guard exercises.indices.contains(target) else { return }
        withAnimation(MyFisMotion.base) { exercises.swapAt(index, target) }
    }
}

// MARK: - 이번 주 띠

/// 요일 일곱 칸 — SPEC W-01 의 요일 카드 7장을 **한 줄로 압축한 것**이다.
///
/// **라임을 쓰지 않는다.** 홈 캘린더(§6.11)와 같은 이유로, 늘 떠 있는 것에
/// 액센트 예산을 쓰지 않는다. 오늘은 `surface.2`, 이미 한 날은 `surface.1` —
/// 위계를 **표면 밝기**로 세운다 (§5.4).
private struct WeekStrip: View {
    let days: [RoutineDay]

    private var total: Int { days.filter { !$0.rest }.count }
    private var done: Int { days.filter { $0.done }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: MyFisSpacing.sm) {
            HStack(spacing: MyFisSpacing.md) {
                Text("이번 주")
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.textSecondary)
                Spacer(minLength: 0)
                Text("\(done) / \(total)일 완료")
                    .font(MyFisFont.label.monospacedDigit())
                    .foregroundStyle(MyFisColor.textTertiary)
            }

            HStack(spacing: MyFisSpacing.xs) {
                ForEach(days) { cell($0) }
            }
        }
    }

    /// 한 칸 — 요일 · 부위 · 완료 자국.
    ///
    /// 완료 자국은 **자리를 늘 비워 둔다.** 있는 칸만 높아지면 띠가 들쭉날쭉해진다
    private func cell(_ day: RoutineDay) -> some View {
        VStack(spacing: MyFisSpacing.xs) {
            Text(day.weekday)
                .font(MyFisFont.caption)
                .foregroundStyle(
                    day.today
                        ? MyFisColor.textSecondary
                        : MyFisCalendar.weekendColor(label: day.weekday) ?? MyFisColor.textTertiary
                )

            Text(day.focus)
                .font(MyFisFont.label)
                .foregroundStyle(focusColor(day))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Image("ic_check")
                .renderingMode(.template)
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundStyle(MyFisColor.textTertiary)
                .opacity(day.done ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MyFisSpacing.md)
        .background(background(day),
                    in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
        // 오늘만 테두리를 두른다 — 표면 밝기 한 단계 차이(`surface.1`→`surface.2`)로는
        // 완료한 날과 잘 안 갈린다. 테두리는 "지금 이것" 표시로만 쓴다 (§6.2)
        .overlay {
            if day.today {
                RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                    .strokeBorder(MyFisColor.borderStrong, lineWidth: 1)
            }
        }
    }

    private func focusColor(_ day: RoutineDay) -> Color {
        if day.today { return MyFisColor.textPrimary }
        if day.rest { return MyFisColor.textTertiary }
        return MyFisColor.textSecondary
    }

    private func background(_ day: RoutineDay) -> Color {
        if day.today { return MyFisColor.surface2 }
        if day.done { return MyFisColor.surface1 }
        return .clear
    }
}

// MARK: - 조건 칸

/// 라벨 위 · 값 아래 — 숫자 카드(§6.3)와 같은 읽는 순서다. 누르면 목록이 뜬다
private struct SelectorCard: View {
    let label: String
    let options: [Int]
    let format: (Int) -> String
    @Binding var value: Int

    var body: some View {
        Menu {
            Picker("", selection: $value) {
                ForEach(options, id: \.self) { Text(format($0)).tag($0) }
            }
        } label: {
            MyFisCard {
                Text(label)
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.textSecondary)

                HStack(spacing: MyFisSpacing.sm) {
                    Text(format(value))
                        .font(MyFisFont.titleMd.monospacedDigit())
                        .foregroundStyle(MyFisColor.textPrimary)
                    Spacer(minLength: 0)
                    Chevron(degrees: 0, size: 18)
                }
                .padding(.top, MyFisSpacing.xs)
            }
        }
        .buttonStyle(.myFisTap)
        // TODO(서버): 값이 바뀌면 그 조건으로 루틴을 다시 받아온다
    }
}

// MARK: - 목록의 행

/// 웜업 — 스트레칭 다섯 개는 **접어 둔다.** 펴 보는 사람만 보면 되는 목록이다
private struct WarmupRow: View {
    @Binding var open: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(MyFisMotion.base) { open.toggle() } } label: {
                HStack(spacing: MyFisSpacing.md) {
                    MyFisIconTile(dimmed: true) {
                        Image(RoutineGear.stretch.icon)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(MyFisColor.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                        Text("웜업 스트레칭")
                            .font(MyFisFont.titleSm)
                            .foregroundStyle(MyFisColor.textPrimary)
                        Text("\(RoutinePlaceholder.warmup.count)개 · \(RoutinePlaceholder.warmupMinutes)분")
                            .font(MyFisFont.bodySm.monospacedDigit())
                            .foregroundStyle(MyFisColor.textSecondary)
                    }

                    Spacer(minLength: MyFisSpacing.md)

                    Chevron(degrees: open ? 180 : 0)
                }
                .padding(.vertical, MyFisSpacing.md)
                .frame(minHeight: MyFisSize.listRowMin)
            }
            .buttonStyle(.myFisTap)

            if open {
                VStack(alignment: .leading, spacing: MyFisSpacing.sm) {
                    ForEach(RoutinePlaceholder.warmup, id: \.self) { name in
                        Text(name)
                            .font(MyFisFont.bodySm)
                            .foregroundStyle(MyFisColor.textSecondary)
                    }
                }
                // 글자를 위 줄의 이름과 맞춰 세운다 — 타일 `56` + 사이 `12`
                .padding(.leading, MyFisSize.listRowMin + MyFisSpacing.md)
                .padding(.bottom, MyFisSpacing.md)
            }
        }
    }
}

/// 운동 한 줄. 순서 모드에서는 **타일·처방이 빠지고 번호와 화살표만 남는다** —
/// 순서를 바꿀 때 필요한 건 이름뿐이고, 화살표는 `44` 를 확보해야 한다 (§5.3)
private struct ExerciseRow: View {
    let item: RoutineExercise
    let index: Int
    let reordering: Bool
    var last = false
    var onUp: () -> Void = {}
    var onDown: () -> Void = {}

    var body: some View {
        HStack(spacing: MyFisSpacing.md) {
            if reordering {
                Text("\(index + 1)")
                    .font(MyFisFont.bodySm.monospacedDigit())
                    .foregroundStyle(MyFisColor.textTertiary)
                    .frame(width: 20)
            } else {
                MyFisIconTile {
                    Image(item.gear.icon)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(MyFisColor.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                Text(item.name)
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(1)
                if !reordering {
                    // 세트·중량·횟수는 자릿수가 바뀌어도 안 흔들려야 한다 (SPEC W 공통)
                    Text(item.prescription)
                        .font(MyFisFont.bodySm.monospacedDigit())
                        .foregroundStyle(MyFisColor.textSecondary)
                }
            }

            Spacer(minLength: MyFisSpacing.md)

            if reordering {
                // 갈 곳이 없는 화살표는 **색으로 죽인다** — 투명도를 쓰지 않는다 (§9 이탈 #2)
                arrow(degrees: 180, enabled: index > 0, action: onUp)
                arrow(degrees: 0, enabled: !last, action: onDown)
            }
        }
        .padding(.vertical, MyFisSpacing.md)
        .frame(minHeight: MyFisSize.listRowMin)
        // TODO(W-03): 행을 누르면 시연 영상이 있는 운동 상세로 간다
    }

    private func arrow(degrees: Double, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Chevron(degrees: degrees,
                    color: enabled ? MyFisColor.textSecondary : MyFisColor.borderSubtle)
                .frame(width: MyFisSize.minTouchTarget, height: MyFisSize.minTouchTarget)
        }
        .buttonStyle(.myFisTap)
        .disabled(!enabled)
    }
}

#Preview {
    WeightScreen().preferredColorScheme(.dark)
}
