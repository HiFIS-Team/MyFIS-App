import SwiftUI

/// 고르는 목록 — **우리 면으로 그린다** 🟢 (2026-09-04, 사용자 지정).
///
/// 전에는 `Menu` 를 썼는데, iOS 26 의 `Menu` 는 목록을 **유리(liquid glass)** 로 띄운다.
/// 뒤가 비치는 판은 이 앱에서 그 자리에만 생기는 낯선 재질이고,
/// 안드로이드는 같은 자리를 이미 `surface.2` 평면(`DropdownMenu`)으로 그리고 있어
/// **두 판이 어긋나 있었다** (§10).
///
/// 시스템 위젯(스위치·스크롤·전환)은 여전히 네이티브 그대로 쓴다 —
/// 여기서 바꾸는 건 **재질 하나**지 동작이 아니다. 띄우고 닫고 바깥을 눌러 닫는 일은
/// `popover` 가 그대로 한다.
extension View {
    /// - Parameters:
    ///   - isPresented: 열림 여부. 트리거 쪽에서 켠다
    ///   - options: 고를 것들
    ///   - selection: 고른 값
    ///   - title: 값 → 보이는 글자
    func myFisDropdown<Value: Hashable>(
        isPresented: Binding<Bool>,
        options: [Value],
        selection: Binding<Value>,
        title: @escaping (Value) -> String
    ) -> some View {
        popover(isPresented: isPresented,
                attachmentAnchor: .rect(.bounds),
                arrowEdge: .top) {
            MyFisDropdownList(options: options, selection: selection,
                              title: title, isPresented: isPresented)
                // 아이폰에서도 **시트로 바뀌지 않게** 못 박는다 — 시트로 자라면
                // 값 하나 고르는 일이 화면 절반을 덮는 일이 된다
                .presentationCompactAdaptation(.popover)
                // 유리를 우리 면으로 갈아 끼우는 곳이 여기다
                .presentationBackground(MyFisColor.surface2)
        }
    }
}

/// 목록 알맹이. 고른 값만 `text.primary`, 나머지는 `text.tertiary` —
/// 안드로이드 `DropdownMenu` 와 같은 규칙이다
private struct MyFisDropdownList<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let title: (Value) -> String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                    isPresented = false
                } label: {
                    Text(title(option))
                        .font(MyFisFont.body)
                        .foregroundStyle(option == selection
                                         ? MyFisColor.textPrimary : MyFisColor.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, MyFisSpacing.lg)
                        .frame(height: MyFisSize.minTouchTarget)
                }
                .buttonStyle(.myFisTap)
            }
        }
        .padding(.vertical, MyFisSpacing.sm)
        .frame(minWidth: 160)
        .fixedSize()
    }
}
