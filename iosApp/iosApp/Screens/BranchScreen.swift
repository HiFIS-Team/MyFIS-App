import SwiftUI

/// 홈 헤더의 **핀으로 들어오는 잎 화면** (SPEC M-08 지점 내부 지도).
///
/// 짜임은 **지도 앱 방식**이다 🟢 (2026-08-27) — 평면도가 화면을 채우고,
/// 찾기 줄은 그 위에 뜨고, 고르는 것들은 **바닥 시트** 안으로 들어간다.
///
/// ⚠️ 다만 **헤더 밑에서 시작한다.** 네이버·카카오맵이 지도를 끝까지 까는 건 그 화면에
/// **헤더가 없기** 때문이다 — 떠 있는 단추만 있다. 우리는 제목이 있는 진짜 헤더를 쓰는데,
/// 제목을 움직이는 배경 위에 올리려면 그늘을 그만큼 진하게 깔아야 하고
/// **그럴 거면 이미 불투명한 바**다. 떠 있어야 하는 건 헤더가 아니라 **찾기 줄**이다.
///
/// ⚠️ 처음엔 위에서부터 찾기 줄 → 빠른 고르기 → 자주 쓰는 기구 → 지도로 쌓았는데,
/// 그러면 지도에 **280pt** 밖에 안 남았다. 이 화면의 북극성은 "쉬는 시간 20초 안에"인데
/// 지도를 보려고 스크롤해야 하면 그 자체로 실패다 (SPEC M-08).
struct BranchScreen: View {
    var onBack: () -> Void = {}

    /// 시트가 펼쳐졌는지. **두 자리뿐이다** — 접힘(첫 줄만) / 펼침(전부).
    /// 자리를 셋 이상 두면 어디에 멈출지 손이 못 맞춘다
    @State private var expanded = MyFisDebug.sheetExpanded

    var body: some View {
        GeometryReader { geo in
            // 접힘은 **빠른 고르기 두 줄이 다 보이는 높이**다 (778 기준 186 + 바닥 여백).
            // 한 줄만 보이게 하면 나머지 넷이 있는 줄 모르고, 더 올리면 지도가 반으로 줄어든다
            let peek = geo.size.height * 0.24
            let full = geo.size.height * 0.56

            ZStack {
                VStack(spacing: 0) {
                    // 헤더는 **불투명한 바**다. 지도가 밑에서 시작한다
                    DetailHeader(title: "기구 찾기", onBack: onBack)
                        .background(MyFisColor.bgBase)

                    ZStack(alignment: .top) {
                        // 평면도가 **바탕**이다. 찾기 줄과 시트가 이 위에 얹힌다
                        BranchMap(bottomInset: peek)

                        // 찾기 줄만 **떠 있다.** 자기 판(`surface.1`)과 라임 테두리가 있어
                        // 그늘 없이도 지도 위에서 읽힌다
                        BranchSearchBar()
                            .padding(.horizontal, MyFisSpacing.screenHorizontal)
                            .padding(.top, MyFisSpacing.sm)
                    }
                }

                BranchSheet(expanded: $expanded, peek: peek, full: full)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // ⚠️ **바닥 안전영역까지 쓴다.** 안 그러면 시트를 끝까지 올려도 화면 맨 밑에
        // 바탕색 띠가 남아 시트가 바닥에서 뜬 것처럼 보인다.
        // 홈 인디케이터에 글자가 닿는 건 시트 안쪽 여백(`xxxl`)이 막는다
        .ignoresSafeArea(edges: .bottom)
    }
}

/// 평면도 — **화면의 바탕**. 확대 · 이동만 되고 돌리지는 않는다 (SPEC M-08).
///
/// 처음엔 **화면을 꽉 채운다** 🟢 (2026-08-27 수정). 폭에만 맞췄더니 도면이 화면 가운데
/// 떠 있는 그림처럼 보였다 — 지도 앱은 화면에 빈 데가 없고, 보고 싶은 데로 밀어서 간다.
///
/// - 처음 배율 = **덮기**(가로·세로 중 큰 쪽에 맞춤). 화면에 빈 데가 안 생긴다
/// - 가장 작게 = **전부 보기**. 한 번 오므리면 헬스장 전체가 들어온다
/// - 민 거리는 **가장자리에서 멈춘다.** 안 막으면 도면이 화면 밖으로 사라진다
private struct BranchMap: View {
    /// 시트에 가려지는 높이. **가려질 자리를 빼고 채운다**
    var bottomInset: CGFloat = 0

    /// 지금 배율. `0` 은 아직 못 정했다는 뜻이다 (화면 크기를 알아야 정할 수 있다)
    @State private var zoom: CGFloat = 0
    /// 전부 보고 있는 중인지. 버튼 글자가 이걸 따라 바뀐다
    @State private var showingAll = false
    @State private var pinchStart: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var dragStart: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let plan = BranchFloorPlan.size
            let visible = CGSize(width: geo.size.width,
                                 height: max(geo.size.height - bottomInset, 1))
            let fit = min((visible.width - MyFisSpacing.xxl * 2) / plan.width,
                          (visible.height - MyFisSpacing.xxl * 2) / plan.height)
            let cover = max(visible.width / plan.width, visible.height / plan.height)
            let current = zoom > 0 ? zoom : cover

            Canvas { context, size in
                draw(context: context, size: size, visible: visible, scale: current)
            }
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            if pinchStart == 0 { pinchStart = current }
                            zoom = min(max(pinchStart * value, fit), cover * 2.5)
                            showingAll = zoom <= fit * 1.05
                            offset = clamp(offset, plan: plan, visible: visible, scale: zoom)
                        }
                        .onEnded { _ in pinchStart = 0 },
                    DragGesture()
                        .onChanged { value in
                            if dragStart == .zero { dragStart = offset }
                            offset = clamp(
                                CGSize(width: dragStart.width + value.translation.width,
                                       height: dragStart.height + value.translation.height),
                                plan: plan, visible: visible, scale: current
                            )
                        }
                        .onEnded { _ in dragStart = .zero }
                )
            )
            .onAppear { if zoom == 0 { zoom = cover } }
            .overlay(alignment: .bottomTrailing) {
                // 꽉 채우면 헬스장 **전체가 안 보인다.** 한 번에 되돌아올 길을 둔다 —
                // 지도 앱이 `현위치` 단추를 띄워 두는 것과 같은 자리다
                Button {
                    withAnimation(MyFisMotion.slow) {
                        showingAll.toggle()
                        zoom = showingAll ? fit : cover
                        offset = .zero
                    }
                } label: {
                    Text(showingAll ? "채우기" : "전체 보기")
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .padding(.horizontal, MyFisSpacing.md)
                        .frame(height: MyFisSize.buttonSmall)
                        .background(
                            MyFisColor.surface2,
                            in: Capsule(style: .continuous)
                        )
                        .overlay(Capsule(style: .continuous)
                            .strokeBorder(MyFisColor.borderSubtle, lineWidth: 1))
                }
                .buttonStyle(.myFisTap)
                .padding(.trailing, MyFisSpacing.screenHorizontal)
                .padding(.bottom, bottomInset + MyFisSpacing.lg)
            }
        }
        .background(MyFisColor.bgBase)
        .clipped()
    }

    /// 민 거리를 **가장자리 안**으로 되돌린다. 도면이 화면보다 작으면 가운데에 못 박는다
    private func clamp(_ value: CGSize, plan: CGSize, visible: CGSize,
                       scale: CGFloat) -> CGSize {
        let slackX = max((plan.width * scale - visible.width) / 2, 0)
        let slackY = max((plan.height * scale - visible.height) / 2, 0)
        return CGSize(width: min(max(value.width, -slackX), slackX),
                      height: min(max(value.height, -slackY), slackY))
    }

    private func draw(context: GraphicsContext, size: CGSize,
                      visible: CGSize, scale s: CGFloat) {
        let plan = BranchFloorPlan.size
        let originX = (visible.width - plan.width * s) / 2 + offset.width
        let originY = (visible.height - plan.height * s) / 2 + offset.height

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: originX + x * s, y: originY + y * s)
        }
        func rect(_ r: CGRect) -> CGRect {
            CGRect(x: originX + r.minX * s, y: originY + r.minY * s,
                   width: r.width * s, height: r.height * s)
        }
        func rounded(_ r: CGRect, _ radius: CGFloat) -> Path {
            Path(roundedRect: rect(r), cornerRadius: radius * s, style: .continuous)
        }

        // ⓪ 바닥 결 — **오므려서 도면이 작아졌을 때 화면이 비지 않게** 한다.
        // 지도 앱의 바깥은 빈 검정이 아니라 늘 뭔가 깔려 있다
        let step = 20 * s
        if step > 6 {
            var grid = Path()
            var x = originX.truncatingRemainder(dividingBy: step)
            while x < size.width {
                grid.move(to: CGPoint(x: x, y: 0))
                grid.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y = originY.truncatingRemainder(dividingBy: step)
            while y < size.height {
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            context.stroke(grid, with: .color(MyFisColor.surface1), lineWidth: 1)
        }

        // ① 바닥 — **벽 모양 그대로** 칠한다. 네모로 칠하면 꺾인 구석 밖까지 바닥이 나온다
        var floor = Path()
        for (index, p) in BranchFloorPlan.outline.enumerated() {
            let cg = point(p.x, p.y)
            index == 0 ? floor.move(to: cg) : floor.addLine(to: cg)
        }
        floor.closeSubpath()
        context.fill(floor, with: .color(MyFisColor.surface1))

        // ② 구역 — 옅게 칠하고 테두리를 한 겹
        for zone in BranchFloorPlan.zones {
            let path = rounded(zone.rect, 5)
            context.fill(path, with: .color(zone.tint.color.opacity(0.14)))
            context.stroke(path, with: .color(zone.tint.color.opacity(0.45)), lineWidth: 1)
        }

        // ③ 방 — 구역과 달리 **벽으로 막힌 곳**이라 테두리를 진하게 두른다
        for room in BranchFloorPlan.rooms {
            let path = rounded(room.rect, 2)
            context.fill(path, with: .color(room.tint.color.opacity(0.12)))
            context.stroke(path, with: .color(MyFisColor.borderSubtle), lineWidth: 1)
        }

        // ④ 물건
        for item in BranchFloorPlan.items {
            context.fill(rounded(item.rect, item.radius), with: .color(item.tone.color))
        }

        // ⑤ 바깥 벽 — 물건 위에 그린다. 밑에 깔면 기둥에 먹힌다
        var wall = Path()
        for (index, p) in BranchFloorPlan.outline.enumerated() {
            let cg = point(p.x, p.y)
            index == 0 ? wall.move(to: cg) : wall.addLine(to: cg)
        }
        context.stroke(wall, with: .color(MyFisColor.borderStrong),
                       style: StrokeStyle(lineWidth: 2.5 * s, lineCap: .round, lineJoin: .round))

        // ⑥ 글자
        for zone in BranchFloorPlan.zones {
            label(context, zone.title, at: CGPoint(x: zone.rect.midX, y: zone.rect.minY + 9),
                  size: 10 * s, color: zone.tint.color, point: point)
        }
        for room in BranchFloorPlan.rooms {
            label(context, room.title, at: CGPoint(x: room.rect.midX, y: room.rect.midY + 9),
                  size: 8 * s, color: MyFisColor.textSecondary, point: point)
        }

        // ⑦ 출입구 — **이름만 둔다.** 벽이 끊긴 자리가 이미 문이라 핀까지 세우면
        // 바로 위 `내 위치` 와 표시가 둘이 되어 어느 쪽이 나인지 헷갈린다
        let e = BranchFloorPlan.entrance
        label(context, "출입구", at: CGPoint(x: e.x, y: e.y + 11),
              size: 8 * s, color: MyFisColor.textSecondary, point: point)

        // ⑧ 내 자리 — **화면에서 제일 먼저 찾아야 하는 점**이라 라임은 여기 쓴다 (§3.2).
        // 지도 앱의 파란 점과 같은 짜임 — 번짐 · 테두리 · 알맹이 세 겹이라야 배경에서 뜬다
        let me = BranchFloorPlan.mySpot
        context.fill(
            rounded(CGRect(x: me.x - 12, y: me.y - 12, width: 24, height: 24), 12),
            with: .color(MyFisColor.accent.opacity(0.18))
        )
        context.fill(
            rounded(CGRect(x: me.x - 6, y: me.y - 6, width: 12, height: 12), 6),
            with: .color(MyFisColor.bgBase)
        )
        context.fill(
            rounded(CGRect(x: me.x - 4.6, y: me.y - 4.6, width: 9.2, height: 9.2), 4.6),
            with: .color(MyFisColor.accent)
        )
        label(context, "내 위치", at: CGPoint(x: me.x, y: me.y - 15),
              size: 8 * s, color: MyFisColor.accent, point: point)
    }

    private func label(_ context: GraphicsContext, _ text: String, at spot: CGPoint,
                       size: CGFloat, color: Color,
                       point: (CGFloat, CGFloat) -> CGPoint) {
        // 지도 글자는 §4.2 스케일 밖이다 — 확대하면 같이 커지므로 크기를 고정할 수 없다
        guard size >= 7 else { return }
        context.draw(
            Text(text).font(MyFisFont.map(size)).foregroundStyle(color),
            at: point(spot.x, spot.y),
            anchor: .center
        )
    }
}

private extension PlanTint {
    var color: Color {
        switch self {
        case .green: MyFisColor.categoryGreen
        case .teal: MyFisColor.categoryTeal
        case .violet: MyFisColor.categoryViolet
        case .blue: MyFisColor.categoryBlue
        case .orange: MyFisColor.categoryOrange
        case .gold: MyFisColor.categoryGold
        case .pink: MyFisColor.categoryPink
        case .gray: MyFisColor.categoryGray
        }
    }
}

private extension PlanTone {
    var color: Color {
        switch self {
        case .body: MyFisColor.borderStrong
        case .cap: MyFisColor.textSecondary
        case .pillar: MyFisColor.surface3
        case .plant: MyFisColor.categoryGreen
        }
    }
}

/// 바닥 시트 — **빠른 고르기 + 자주 쓰는 기구**가 여기 들어간다.
///
/// ⚠️ SwiftUI 의 `.sheet` 는 **모달 표시**라 이 자리에 못 쓴다. 잎 화면 자체가 이미
/// 밀려 들어오는 중인데 그 위에 모달을 또 띄우면 전환이 둘로 겹치고,
/// 뒤로 가기로 잎을 닫을 때 시트가 따로 논다. 그래서 **화면 안에 그린다**.
/// (안드로이드는 `BottomSheetScaffold` 가 이 자리를 정확히 맡아 준다 — 거긴 그걸 쓴다)
private struct BranchSheet: View {
    @Binding var expanded: Bool
    let peek: CGFloat
    let full: CGFloat

    @State private var drag: CGFloat = 0

    private var offset: CGFloat {
        let base = expanded ? 0 : full - peek
        // 끝에서 더 끌면 **덜 따라온다.** 안 그러면 시트가 화면 밖으로 빠진다
        return min(max(base + drag, -24), full - peek + 24)
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(MyFisColor.borderStrong)
                .frame(width: 36, height: 4)
                .padding(.top, MyFisSpacing.md)
                .padding(.bottom, MyFisSpacing.lg)

            ScrollView(showsIndicators: false) {
                VStack(spacing: MyFisSpacing.xxl) {
                    PlaceQuickPick()
                    FavoriteMachines()
                }
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.bottom, MyFisSpacing.xxxl)
            }
            // 접혀 있을 땐 시트를 못 굴린다. 굴리면 첫 줄이 위로 사라져 빈 판만 남는다
            .disabled(!expanded)
        }
        .frame(maxWidth: .infinity)
        .frame(height: full, alignment: .top)
        .background(
            MyFisColor.surface1,
            in: UnevenRoundedRectangle(
                topLeadingRadius: MyFisRadius.lg,
                topTrailingRadius: MyFisRadius.lg,
                style: .continuous
            )
        )
        .offset(y: offset)
        .gesture(
            DragGesture()
                .onChanged { drag = $0.translation.height }
                .onEnded { value in
                    // 40 을 넘겨야 자리를 바꾼다. 손 떨림으로 넘어가면 안 된다
                    let moved = value.translation.height
                    withAnimation(MyFisMotion.slow) {
                        if moved < -40 { expanded = true }
                        if moved > 40 { expanded = false }
                        drag = 0
                    }
                }
        )
        .animation(MyFisMotion.slow, value: expanded)
    }
}

/// 찾기 줄 — **이 화면에서 제일 먼저 눈에 들어와야 하는 것**이라 테두리를 라임으로 두른다.
///
/// 판을 라임으로 채우지 않는다. 채우면 밑에 올 지도보다 이 줄이 더 세진다 (§3.2 액센트 예산).
private struct BranchSearchBar: View {
    var body: some View {
        // TODO: 누르면 기구 검색으로 (M-08). 지금은 자리만 잡는다
        // 물음이 **이 줄의 제목**이라 흐리게 두지 않는다. `tertiary` 로 두면 꺼진 칸처럼 보인다
        Text("어떤 기구 찾으세요?")
            .font(MyFisFont.titleMd)
            .foregroundStyle(MyFisColor.textSecondary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, MyFisSpacing.lg)
            .frame(height: MyFisSize.searchBar)
            .background(
                MyFisColor.surface1,
                in: RoundedRectangle(cornerRadius: MyFisRadius.lg, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: MyFisRadius.lg, style: .continuous)
                    .strokeBorder(MyFisColor.accent, lineWidth: 1.5)
            )
    }
}

/// 빠른 고르기 여덟 칸 (DESIGN §6.26).
///
/// **구역**이지 기구 낱개가 아니다 🟢 (2026-08-27). 기구 하나하나는 위 **찾기 줄**이 맡고,
/// 이 판은 지도의 **구역과 1:1** 로 맞춘다 — 스쿼트랙 · 벤치 · 덤벨은 셋 다 프리웨이트존 안이라
/// 나란히 놓을 것이 아니었다. 앞 넷은 운동 구역, 뒤 넷은 편의시설이다.
enum BranchPlace: String, CaseIterable, Identifiable {
    case free, machine, cardio, stretch
    case toilet, shower, fitting, desk

    var id: String { rawValue }

    /// ⚠️ **여덟이 전부 원색 벌**이다 (§8). 쓰는 쪽에서 tint 를 걸지 않는다 —
    /// 걸면 그림이 한 색으로 눌려 실루엣만 남는다
    var icon: String { "ic_place_\(rawValue)" }

    var title: String {
        switch self {
        case .free: "프리웨이트"
        case .machine: "머신"
        case .cardio: "유산소"
        case .stretch: "스트레칭"
        case .toilet: "화장실"
        case .shower: "샤워실"
        case .fitting: "탈의실"
        case .desk: "데스크"
        }
    }
}

/// **네 칸 × 두 줄.** 한 줄에 다섯을 넣으면 라벨(`프리웨이트`)이 줄어들고,
/// 셋으로 줄이면 판이 커져 밑에 올 지도를 밀어낸다.
private struct PlaceQuickPick: View {
    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: MyFisSpacing.md),
                count: 4
            ),
            // 줄 사이는 `16` 이다. 칸 사이(`12`)보다 넓어야 라벨이 아래 판에 붙지 않는다
            spacing: MyFisSpacing.lg
        ) {
            ForEach(BranchPlace.allCases) { place in
                PlaceCell(icon: place.icon, title: place.title)
            }
        }
    }
}

/// 아이콘 판 + 라벨. 판의 짜임은 **혜택 행과 같다** (§6.23) — 같은 물건은 같게 그린다.
///
/// 아이콘은 **여덟이 전부 원색**이라 tint 를 걸지 않는다.
/// 라임은 안 쓴다 — 이 화면의 액센트는 찾기 줄 테두리 하나다 (§3.2 액센트 예산).
private struct PlaceCell: View {
    let icon: String
    let title: String

    var body: some View {
        // TODO: 누르면 그 갈래를 지도에서 집는다 (M-08)
        Button {} label: {
            VStack(spacing: MyFisSpacing.sm) {
                Image(icon)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 28, height: 28)
                    .frame(width: MyFisSize.listRowMin, height: MyFisSize.listRowMin)
                    .background(
                        MyFisColor.surface2,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                            .strokeBorder(MyFisColor.borderSubtle, lineWidth: 1)
                    )

                Text(title)
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.textSecondary)
                    .lineLimit(1)
                    // `프리웨이트` 가 좁은 기기에서 잘리는 것보다 조금 줄어드는 편이 낫다
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }
}

/// 자주 쓰는 기구 — **꽂아 둔 기구로 바로 가는 자리** (DESIGN §6.27).
///
/// 짜임은 **카카오 T `자주 쓰는 서비스`** 에서 가져왔다 (사용자 지정) —
/// 카드 하나에 제목 + `편집`, 그 밑에 칸 넷. 빈 칸은 **압정**으로 자리를 보여 준다.
///
/// ⚠️ 레퍼런스는 칸이 다섯인데 **넷으로 줄였다.** 위 빠른 고르기가 4열이라 다섯을 두면
/// 판이 어긋나 두 묶음이 따로 노는 것처럼 보인다.
private struct FavoriteMachines: View {
    /// ⚠️ 여기 이름은 **기구**다. 위 빠른 고르기는 구역(`프리웨이트`)인데
    /// 여기까지 구역 이름을 쓰면 "자주 쓰는 기구"라는 제목과 어긋난다
    // TODO: 꽂아 둔 기구를 서버에서 받는다 (M-08). 지금은 보여 주기용이다
    private let pinned: [(icon: String, title: String)] = [
        ("ic_place_free", "벤치프레스"),
        ("ic_place_cardio", "러닝머신"),
    ]

    var body: some View {
        VStack(spacing: MyFisSpacing.lg) {
            HStack(spacing: MyFisSpacing.sm) {
                Text("자주 쓰는 기구")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.textPrimary)

                Spacer(minLength: 0)

                // TODO: 꽂기/빼기 편집으로 (M-08)
                Button {} label: {
                    Text("편집")
                        .font(MyFisFont.bodySm)
                        .foregroundStyle(MyFisColor.textSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.myFisTap)
            }

            HStack(spacing: MyFisSpacing.md) {
                ForEach(0..<4, id: \.self) { index in
                    if index < pinned.count {
                        PlaceCell(icon: pinned[index].icon, title: pinned[index].title)
                    } else {
                        EmptyPinSlot()
                    }
                }
            }
        }
        .padding(MyFisSpacing.cardPadding)
        .background(
            MyFisColor.surface1,
            in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
        )
    }
}

/// 빈 칸. **자리를 비워 두지 않고 압정을 놓는다** — 비워 두면 칸이 몇 개인지 안 보이고,
/// 꽂을 수 있다는 것도 안 보인다.
private struct EmptyPinSlot: View {
    var body: some View {
        // TODO: 누르면 기구 고르기로 (M-08)
        Button {} label: {
            VStack(spacing: MyFisSpacing.sm) {
                Image("ic_place_pin")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    // 찬 칸(28 원색)보다 작고 흐리다. 같은 무게로 두면 빈 칸이 먼저 읽힌다
                    .foregroundStyle(MyFisColor.textTertiary)
                    .frame(width: MyFisSize.listRowMin, height: MyFisSize.listRowMin)
                    .background(
                        MyFisColor.surface2,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                            .strokeBorder(MyFisColor.borderSubtle, lineWidth: 1)
                    )

                Text("추가")
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }
}
