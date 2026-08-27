import SwiftUI

/// 홈 헤더의 **핀으로 들어오는 잎 화면** (SPEC M-08 지점 내부 지도).
///
/// 지금은 **찾기 줄 + 빠른 고르기**까지다. 밑에 들어갈 평면도 · 기구 핀은 아직 미정이다.
///
/// 줄의 짜임은 **카카오 T 홈**에서 가져왔다 (사용자 지정) —
/// 큰 알약 하나에 **물음 한 줄**. 색은 우리 것을 쓴다.
struct BranchScreen: View {
    var onBack: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: "기구 찾기", onBack: onBack)

            BranchSearchBar()
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.sm)

            PlaceQuickPick()
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.xl)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    /// **자기 색을 가진 그림**이라 tint 를 걸지 않는다 (§8 원색 벌).
    ///
    /// 색이 붙는 기준은 둘 중 하나다 — **① 색이 곧 뜻인 표지판**(화장실의 파랑·분홍은
    /// 남녀 표시 그 자체, 탈의실 커튼은 색이 빠지면 창문으로 읽힌다),
    /// **② 사용자가 준 원본이 원색인 것**(프리웨이트 · 유산소 · 스트레칭 — 혜택 행과 같은 그림).
    var colorIcon: Bool {
        switch self {
        case .free, .cardio, .stretch, .toilet, .fitting: true
        case .machine, .shower, .desk: false
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
                PlaceCell(place: place)
            }
        }
    }
}

/// 아이콘 판 + 라벨. 판의 짜임은 **혜택 행과 같다** (§6.23) — 같은 물건은 같게 그린다.
///
/// 아이콘은 **기본이 단색 아웃라인**이고, 표지판인 둘만 원색이다 (`colorIcon`).
/// 라임은 안 쓴다 — 이 화면의 액센트는 찾기 줄 테두리 하나다 (§3.2 액센트 예산).
private struct PlaceCell: View {
    let place: BranchPlace

    var body: some View {
        // TODO: 누르면 그 갈래를 지도에서 집는다 (M-08)
        Button {} label: {
            VStack(spacing: MyFisSpacing.sm) {
                Image(place.icon)
                    .resizable()
                    .renderingMode(place.colorIcon ? .original : .template)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .frame(width: MyFisSize.listRowMin, height: MyFisSize.listRowMin)
                    .background(
                        MyFisColor.surface2,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: MyFisRadius.tile, style: .continuous)
                            .strokeBorder(MyFisColor.borderSubtle, lineWidth: 1)
                    )

                Text(place.title)
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
