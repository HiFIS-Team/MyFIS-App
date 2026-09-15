import SwiftUI
import UIKit

/// **툴바 유리 알약 안의 시스템 검색 입력칸** (`UISearchTextField`) — 스토어 머리 (DESIGN §6.9 · §6.12).
///
/// 🟢 (2026-09-15, 사용자 — *"ios 검색 화면 그거 시스템 검색창으로 하자 … 크림처럼 해줘 영상보고"*).
/// 크림은 머리 한 줄에 **넓은 유리 검색창 + 아이콘 알약**이 서고, 누르면 알약이 `취소` 로 녹아 바뀐다 (60fps 녹화).
///
/// **유리는 툴바 알약이 깐다** — 오른쪽 아이콘 알약과 같은 체계라 줄 · 높이 · 잎에 다녀올 때의 유리를 시스템이 맞춘다.
/// 입력칸은 판을 그리지 않는다 (`borderStyle = .none`) — 또 그리면 두 겹이다
/// - ❌ SwiftUI `.searchable` — `toolbarPrincipal` · `navigationBarDrawer` · `toolbar` · 자동 **넷 다 둘째 줄**에 섰다
/// - ❌ UIKit `.integrated` — 한 줄이지만 **검색창이 오른쪽**
/// - ❌ 제목 자리(`titleView`)에 `UISearchBar` — 평소 모습은 크림과 같았지만
///   ① **오른쪽 알약보다 5pt 아래**였다 (내비 바가 제목 자리를 64 높이 가운데에 둔다. 입력칸을 옮겨도 그림은 안 따라왔다)
///   ② **장바구니 · 스토어 마이에 다녀오면 유리 판만 사라졌다** (사용자 지적 · 캡처로 재현)
///   ③ SwiftUI 가 항목을 다시 설정할 때마다 제목 자리를 비워 **메서드를 바꿔 끼워 막아야** 했다
///
/// 켜짐(`active`)은 셸이 든다 — 오른쪽 `취소` 도 셸의 툴바에 있다
struct ToolbarSearchField: UIViewRepresentable {
    @Binding var text: String
    @Binding var active: Bool
    let placeholder: String
    /// 키보드의 `검색` 을 눌렀을 때
    var onSubmit: (String) -> Void = { _ in }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UISearchTextField {
        let field = UISearchTextField()
        field.placeholder = placeholder
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.returnKeyType = .search
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        // 커서는 액센트 — 전에 직접 그린 검색 필드와 같다 (§6.9)
        field.tintColor = UIColor(MyFisColor.accent)
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .editingChanged)
        // 폭은 SwiftUI 가 준다 — 글자 길이로 줄거나 늘지 않게
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        sessionTrace("검색칸 — 새로 만듦 #\(abs(ObjectIdentifier(field).hashValue) % 10000)")
        return field
    }

    func updateUIView(_ field: UISearchTextField, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        if field.text != text { field.text = text }
        // **초점은 꺼짐 → 켜짐으로 바뀔 때만** 준다 — 스크롤로 키보드를 내린 뒤 다른 값이 바뀌어도 다시 올라오지 않게
        guard active != coordinator.shownActive else { return }
        coordinator.shownActive = active
        if active, !field.isFirstResponder {
            DispatchQueue.main.async { field.becomeFirstResponder() }
        } else if !active, field.isFirstResponder {
            field.resignFirstResponder()
        }
        // ✅ 오른쪽이 `취소` 로 바뀌어도 SwiftUI 는 이 입력칸을 새로 만들지 않는다 — 1초 뒤에도 같은 칸이 초점을 쥐고 있었다 (기록)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ToolbarSearchField
        /// 마지막으로 반영한 켜짐
        var shownActive = false

        init(_ parent: ToolbarSearchField) { self.parent = parent }

        @objc func changed(_ field: UITextField) {
            parent.text = field.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            guard !parent.active else { return }
            shownActive = true
            // 오른쪽 알약이 `취소` 로 녹아 바뀌는 것 · 본문이 검색 판으로 바뀌는 것이 이 값을 따른다
            withAnimation(MyFisMotion.slow) { parent.active = true }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSubmit(textField.text ?? "")
            textField.resignFirstResponder()
            return true
        }
    }
}
