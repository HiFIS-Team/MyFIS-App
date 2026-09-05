import SwiftUI

/// 토스트 — **"했다"를 알리는 자리** (DESIGN.md §6.35).
///
/// **위에서 내려온다** 🟢 (2026-09-06, 사용자 지정). 셸 맨 위에 얹히므로 잎 화면 위에도 뜬다.
///
/// ⚠️ **쓰지 않는 자리가 정해져 있다** (SPEC) —
/// 마일리지 **적립**은 화면 안에서 알리고, **에러**도 토스트로 끝내지 않는다.
/// 토스트는 *되돌아볼 일 없는 짧은 완료*만 맡는다 — 만들었다 · 담았다 · 지웠다.
///
/// **라임을 쓰지 않는다** (§3.2) — 2초 뜨는 것이 화면당 두 곳뿐인 액센트 예산을 먹으면 안 된다.
struct MyFisToast: View {
    let text: String

    var body: some View {
        Text(text)
            .font(MyFisFont.bodySm)
            .foregroundStyle(MyFisColor.textPrimary)
            .padding(.horizontal, MyFisSpacing.lg)
            .frame(height: MyFisSize.buttonSecondary)
            // 위계는 **표면 밝기**로 낸다 (§5.4) — 그림자를 쓰지 않는다.
            // `surface.3` 이 최상위 표면이라 헤더(불투명 검정) 위에서 떠 보인다
            .background(MyFisColor.surface3, in: Capsule())
            .overlay(Capsule().strokeBorder(MyFisColor.borderSubtle, lineWidth: 1))
    }
}

/// 셸이 들고 있는 토스트 자리 — **하나만 뜬다.** 새 게 오면 이전 걸 갈아 끼운다.
@Observable
final class ToastCenter {
    private(set) var text: String?

    /// 지금 뜬 것을 지울 때 쓰는 표. 늦게 도착한 예약이 새 토스트를 지우면 안 된다
    private var token = 0

    func show(_ text: String) {
        token += 1
        let mine = token
        withAnimation(MyFisMotion.base) { self.text = text }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(MyFisMotion.toastHold))
            guard mine == token else { return }
            withAnimation(MyFisMotion.base) { self.text = nil }
        }
    }
}

/// 셸 맨 위에 얹는 자리. 잎보다도 위다 — 잎에서 한 일도 알려야 한다.
struct ToastLayer: View {
    let center: ToastCenter

    var body: some View {
        VStack(spacing: 0) {
            if let text = center.text {
                MyFisToast(text: text)
                    // **헤더 밑에 뜬다** — 헤더 줄에 겹치면 헤더의 일부처럼 읽힌다
                    // (2026-09-06 확인). 헤더는 모든 화면이 `size.header`(56) 로 같다
                    .padding(.top, MyFisSize.header + MyFisSpacing.sm)
                    // 위에서 내려온다 — 들어온 곳으로 되돌아 나간다
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer(minLength: 0)
        }
        // 뜬 글자에 손이 닿을 일이 없다 — 밑 화면을 막지 않는다
        .allowsHitTesting(false)
    }
}
