import SwiftUI

/// 홈 헤더의 **핀으로 들어오는 잎 화면** (SPEC M-08 지점 내부 지도).
///
/// 지금은 **맨 위 찾기 줄만** 있다. 밑에 들어갈 것(평면도 · 기구 핀)은 아직 미정이다.
///
/// 줄의 짜임은 **카카오 T 홈**에서 가져왔다 (사용자 지정) —
/// 큰 알약 하나에 **왼쪽은 물음, 오른쪽은 바로 가는 칸 둘**. 색은 우리 것을 쓴다.
struct BranchScreen: View {
    var onBack: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(title: nil, onBack: onBack)

            BranchSearchBar()
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.sm)

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
        HStack(spacing: MyFisSpacing.sm) {
            // TODO: 누르면 기구 검색으로 (M-08). 지금은 자리만 잡는다
            // 물음이 **이 줄의 제목**이라 흐리게 두지 않는다. `tertiary` 로 두면 꺼진 칸처럼 보인다
            Text("어떤 기구 찾으세요?")
                .font(MyFisFont.titleMd)
                .foregroundStyle(MyFisColor.textSecondary)
                .lineLimit(1)

            Spacer(minLength: MyFisSpacing.sm)

            QuickSlot("루틴")
            // 칸 둘을 가르는 선. 붙여 두면 글자 넷이 한 덩어리로 읽힌다
            Rectangle()
                .fill(MyFisColor.borderSubtle)
                .frame(width: 1, height: 16)
            QuickSlot("즐겨찾기")
        }
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

/// `⊕ 루틴` 처럼 **한 번에 가는 칸**. 아직 등록 전이라 `⊕` 를 달고 있다
private struct QuickSlot: View {
    let title: String

    init(_ title: String) { self.title = title }

    var body: some View {
        // TODO: 등록/이동을 연결한다
        Button {} label: {
            HStack(spacing: 2) {
                Image("ic_plus_circle")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 18, height: 18)
                    .foregroundStyle(MyFisColor.textSecondary)
                Text(title)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(1)
                    .fixedSize()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }
}
