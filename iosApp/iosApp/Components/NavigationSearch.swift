import SwiftUI
import UIKit

/// **판 없는 시스템 검색 입력칸** (`UISearchTextField`) — 스토어 머리 (DESIGN §6.9 · §6.12).
///
/// 🟢 (2026-09-15, 사용자 — *"ios 검색 화면 그거 시스템 검색창으로 하자 … 크림처럼 해줘 영상보고"*).
/// 크림은 머리 한 줄에 **넓은 유리 검색창 + 아이콘 알약**이 서고, 누르면 알약이 `취소` 로 녹아 바뀐다 (60fps 녹화).
///
/// **유리는 담는 쪽이 깐다** — 지금은 `PageHeaderSearchField`(페이지에 붙은 `glassEffect` 알약).
/// 입력칸은 판을 그리지 않는다 (`borderStyle = .none`) — 또 그리면 두 겹이다
/// - ❌ 왼쪽 툴바 항목에 담기 — 잎이 드나들 때 시스템이 뒤로 버튼 원으로 녹여 **날개 달린 원**이 남았다 (같은 날 사용자 지적)
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
    /// 안내 글 — 바뀌면 따라 바꾼다 (접힌 검색칸은 비운다)
    let placeholder: String
    /// VoiceOver 이름 — 안내 글을 비워도 읽힌다. 없으면 안내 글
    var label: String? = nil
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
        if field.placeholder != placeholder { field.placeholder = placeholder }
        field.accessibilityLabel = label ?? placeholder
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

/// **페이지에 붙은 머리 검색칸** — 내비 바 줄에 서지만 툴바 항목이 아니라 **화면의 일부**다 (스토어 머리, DESIGN §6.9).
///
/// 🟢 (2026-09-15, 사용자 — *"크림 자세히 보니까 저 리퀴드 글래스 저거 그냥 고정해둔거 같은데 페이지 옆에서 나올때 같이 옆으로 이동하는거 보면"*).
/// 크림 60fps — 잎이 들어오고 나갈 때 **검색칸은 페이지와 같은 거리만큼 밀리고**(−12 → −8 → −4 → −2 → 0pt), 오른쪽 아이콘 알약만 제자리에서 흐려진다.
/// 툴바 항목이면 시스템이 넓은 알약을 뒤로 버튼 원으로 녹여 바꿔 **날개 달린 원**이 남았다.
///
/// 줄 높이는 **내비 바에서 읽는다**(`NavigationBarProbe`) — 기기 · 상태 막대 높이가 달라도 오른쪽 알약과 같은 줄에 선다.
/// 유리는 네이티브 `glassEffect`(iOS 26), 그 아래는 평평하다 (`HeaderGlass` 와 같다)
struct PageHeaderSearchField: View {
    @Binding var text: String
    @Binding var active: Bool
    let placeholder: String
    /// 입력칸 폭 — 알약은 여기에 안쪽 여백(`toolbarFieldInset`) 양쪽을 더한 폭이다
    let width: CGFloat
    var onSubmit: (String) -> Void = { _ in }

    /// 내비 바 항목 줄의 세로 가운데 (창 기준)
    @State private var barMidY: CGFloat?
    /// 내비 바에 "여기 누르기는 흘려보내라"고 알리는 이름표
    @State private var passID = UUID()

    private var platterWidth: CGFloat { width + MyFisSize.toolbarFieldInset * 2 }

    var body: some View {
        GeometryReader { proxy in
            if let barMidY {
                platter
                    .position(x: MyFisSize.toolbarEdge + platterWidth / 2,
                              y: barMidY - proxy.frame(in: .global).minY)
                    .animation(MyFisMotion.slow, value: width)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background { NavigationBarProbe { barMidY = $0 } }
        .onChange(of: passRect) { _, rect in NavigationBarPassThrough.set(passID, rect) }
        .onAppear { NavigationBarPassThrough.set(passID, passRect) }
        // 잎이 덮거나 탭을 옮기면 거둔다 — 다른 화면의 바 누르기를 흘려보내지 않게
        .onDisappear { NavigationBarPassThrough.set(passID, nil) }
    }

    /// 알약 자리 (창 기준) — 내비 바가 이 안의 누르기를 가로채지 않는다
    private var passRect: CGRect? {
        guard let barMidY else { return nil }
        return CGRect(x: MyFisSize.toolbarEdge, y: barMidY - MyFisSize.minTouchTarget / 2,
                      width: platterWidth, height: MyFisSize.minTouchTarget)
    }

    @ViewBuilder
    private var platter: some View {
        let field = ToolbarSearchField(text: $text, active: $active, placeholder: placeholder, onSubmit: onSubmit)
            .frame(width: width)
            .padding(.horizontal, MyFisSize.toolbarFieldInset)
            .frame(width: platterWidth, height: MyFisSize.minTouchTarget, alignment: .leading)
        if #available(iOS 26.0, *) {
            // **유리에 `surface.1` 틴트** 🟢 (2026-09-15, 사용자 — *"둘이 색이 다른건 너가 일부로 한거야?"*).
            // 틴트 없는 유리는 어두운 바탕을 그대로 비쳐 **바탕과 같은 26**이었고, 옆 시스템 툴바 알약은 **36,36,39**(≈ `surface.1`)였다 (캡처 픽셀).
            // 틴트 · 밑에 칠 둘 다 35,35,39 로 맞았다 — 틴트는 유리가 비치는 성질을 남겨 시스템 알약과 같게 둔다
            field.glassEffect(.regular.tint(MyFisColor.surface1).interactive(), in: .capsule)
        } else {
            field
        }
    }
}

/// **내비 바가 페이지 머리 검색칸 위의 누르기를 가로채지 않게** 한다.
///
/// 페이지에 붙은 검색칸은 내비 바 **아래**에 깔린다. iOS 26 바는 투명해도 빈 자리 누르기를 **바 내용 판**(`NavigationBarContentView`)이 받았다
/// (`MYFIS_HITTEST` 로그, 2026-09-15). 등록한 자리 안이고 **바의 버튼이 아닐 때만** `nil` 을 돌려 아래로 흘려보낸다
enum NavigationBarPassThrough {
    nonisolated(unsafe) private static var rects: [UUID: CGRect] = [:]
    nonisolated(unsafe) private static var installed = false

    static func set(_ id: UUID, _ rect: CGRect?) {
        install()
        rects[id] = rect
    }

    static func contains(_ point: CGPoint) -> Bool {
        rects.values.contains { $0.contains(point) }
    }

    /// `UINavigationBar` 에만 바꿔 끼운다 — 바가 `hitTest` 를 따로 두지 않았으면 먼저 붙여서 `UIView` 것을 건드리지 않는다
    private static func install() {
        guard !installed else { return }
        installed = true
        let cls: AnyClass = UINavigationBar.self
        let original = #selector(UIView.hitTest(_:with:))
        let replacement = #selector(UINavigationBar.myFis_passThroughHitTest(_:with:))
        guard let originalMethod = class_getInstanceMethod(cls, original),
              let replacementMethod = class_getInstanceMethod(cls, replacement) else { return }
        if class_addMethod(cls, original, method_getImplementation(replacementMethod), method_getTypeEncoding(replacementMethod)) {
            class_replaceMethod(cls, replacement, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, replacementMethod)
        }
    }
}

extension UINavigationBar {
    /// 바꿔 끼운 뒤에는 이 이름이 **원래** `hitTest` 다
    @objc func myFis_passThroughHitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = myFis_passThroughHitTest(point, with: event)
        guard let hit, let window, NavigationBarPassThrough.contains(convert(point, to: window)) else { return hit }
        // 바의 버튼(뒤로 · 장바구니 · `취소`)을 누른 건 그대로 둔다
        var view: UIView? = hit
        while let current = view, current !== self {
            if current is UIControl { return hit }
            view = current.superview
        }
        return nil
    }
}

/// 자기를 담은 내비게이션 컨트롤러의 **항목 줄 세로 가운데**(창 기준)를 알린다.
///
/// 바 틀의 가운데가 아니다 — iOS 26 바(62~116, 54 높이)에서 유리 알약(44)은 **바 윗변에 붙어** 선다 (가운데 84, 캡처 · 로그).
/// 바 가운데(89)에 맞추니 알약보다 5pt 아래였다. 그래서 `바 윗변 + 22`.
/// ❌ 바 버튼(`UIControl`)의 가운데를 읽기 — 스토어 아이콘은 SwiftUI 조각이라 버튼이 없어 **처음 뜰 때 못 찾았다** (잎의 뒤로 버튼이 남은 뒤에만 찾음)
private struct NavigationBarProbe: UIViewRepresentable {
    let report: (CGFloat) -> Void

    func makeUIView(context: Context) -> ProbeView {
        let view = ProbeView()
        view.isUserInteractionEnabled = false
        view.report = report
        return view
    }

    func updateUIView(_ view: ProbeView, context: Context) {
        view.report = report
        view.measure()
    }

    final class ProbeView: UIView {
        var report: ((CGFloat) -> Void)?
        private var reported: CGFloat?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            measure()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            measure()
        }

        private var retries = 0
        private var retryScheduled = false

        func measure() {
            guard let window else { return }
            var responder: UIResponder? = self
            while let current = responder, !(current is UIViewController) { responder = current.next }
            guard let bar = (responder as? UIViewController)?.navigationController?.navigationBar else {
                // 바가 아직 안 섰다 — **찾을 때까지** 다시 잰다 (화면에서 빠지면 멈춘다)
                scheduleRetry()
                return
            }
            retries = 0
            let mid = bar.convert(bar.bounds, to: window).minY + MyFisSize.minTouchTarget / 2
            guard mid != reported else { return }
            reported = mid
            DispatchQueue.main.async { self.report?(mid) }
            #if DEBUG
            // 누르기가 검색칸까지 닿는지 — 내비 바가 가로채면 안 된다 (`MYFIS_HITTEST=1`)
            if ProcessInfo.processInfo.environment["MYFIS_HITTEST"] == "1" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let point = CGPoint(x: MyFisSize.toolbarEdge + 80, y: mid)
                    var chain: [String] = []
                    var hit = window.hitTest(point, with: nil)
                    while let view = hit, chain.count < 6 { chain.append(String(describing: type(of: view))); hit = view.superview }
                    fputs("[hittest] 줄 가운데 \(mid) 바 \(bar.convert(bar.bounds, to: window)) → \(chain)\n", stderr)
                }
            }
            #endif
        }

        /// 처음 3초는 0.1초마다, 그 뒤로는 0.5초마다
        private func scheduleRetry() {
            guard !retryScheduled else { return }
            retryScheduled = true
            let delay = retries < 30 ? 0.1 : 0.5
            retries += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                retryScheduled = false
                guard window != nil else { return }
                measure()
            }
        }

    }
}

/// **내비 바 시스템 검색 — 돋보기 버튼이 검색창으로 펼쳐진다** (`UISearchController` + iOS 26 `integratedButton`) — 모임 머리 (DESIGN §6.9 · §6.29).
///
/// 🟢 (2026-09-15, 사용자 — *"검색 아이콘 위치가 안맞고 … 접히고 네모칸이 생겼다가 없어지거든 … 애플 developer 그거 좀 보고 한번에 해결해봐"*).
/// Apple 문서 `UINavigationItem.SearchBarPlacement.integratedButton` —
/// *"Integrated 와 같은 자리(끝 쪽)이되, 꺼진 검색창은 자리가 있어도 늘 버튼으로 보인다"*. 누르면 **시스템이** 버튼을 검색창으로 펼치고 닫기를 붙인다.
/// - ❌ 툴바 항목에 입력칸을 넣고 폭을 늘리던 방식 — 접힌 원 안 **돋보기가 한쪽으로 치우쳤고**,
///   `취소` 가 끼어들 때마다 시스템이 오른쪽 알약을 다시 짜서 **빈 원 · 네모 날개가 생겼다 사라졌다** (사용자 지적)
///
/// 이 조각은 화면 뒤에 깔려 **자기를 담은 스택 뿌리의 `navigationItem`** 에 검색 컨트롤러를 단다.
/// 켜짐(`active`) · 검색어는 셸이 든다 — 본문이 검색 판으로 바뀌는 게 이 값을 따른다
struct NavigationBarSearch: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var active: Bool
    let placeholder: String
    /// 키보드의 `검색` 을 눌렀을 때
    var onSubmit: (String) -> Void = { _ in }

    func makeUIViewController(context: Context) -> Host {
        Host(self)
    }

    func updateUIViewController(_ host: Host, context: Context) {
        host.parentView = self
        host.sync()
    }

    final class Host: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
        var parentView: NavigationBarSearch
        let search = UISearchController(searchResultsController: nil)

        init(_ parentView: NavigationBarSearch) {
            self.parentView = parentView
            super.init(nibName: nil, bundle: nil)
            search.delegate = self
            search.searchResultsUpdater = self
            // 결과는 화면이 제자리에서 그린다 — 시스템이 본문을 어둡게 덮지 않게
            search.obscuresBackgroundDuringPresentation = false
            let bar = search.searchBar
            bar.delegate = self
            bar.placeholder = parentView.placeholder
            bar.searchTextField.returnKeyType = .search
            bar.autocapitalizationType = .none
            bar.autocorrectionType = .no
            // 칸 안 ⓧ(글자 지우기)는 뺀다 — 오른쪽 시스템 닫기 `✕` 와 X 가 둘로 보였다 (2026-09-15 사용자 — *"칸 안의 동그란 x그거 없애버려"*)
            bar.searchTextField.clearButtonMode = .never
            // 커서는 액센트 — 스토어 검색칸과 같다 (§6.9). 버튼 색은 바 색을 따른다
            bar.searchTextField.tintColor = UIColor(MyFisColor.accent)
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = false
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            attach()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            attach()
        }

        /// 스택 뿌리(내비게이션 컨트롤러 바로 아래 자식)의 항목에 단다
        private func attach() {
            var controller: UIViewController? = parent
            while let current = controller, !(current.parent is UINavigationController) {
                controller = current.parent
            }
            guard let item = controller?.navigationItem, item.searchController !== search else { return }
            item.searchController = search
            if #available(iOS 26.0, *) {
                item.preferredSearchBarPlacement = .integratedButton
                // 아래 툴바로 옮기지 않는다 — 머리 오른쪽에 둔다
                item.searchBarPlacementAllowsToolbarIntegration = false
            }
            item.hidesSearchBarWhenScrolling = false
        }

        /// 셸의 켜짐을 시스템 검색에 옮긴다 — 디버그로 켜고 끌 때 · 탭 세트를 바꿔 끌 때
        func sync() {
            attach()
            if search.searchBar.placeholder != parentView.placeholder {
                search.searchBar.placeholder = parentView.placeholder
            }
            // 검색어를 **켜기 전에** 넣는다 — 켜지며 시스템이 칸의 글자를 셸로 돌려보낸다(`updateSearchResults`)
            if search.searchBar.text != parentView.text {
                search.searchBar.text = parentView.text
            }
            if parentView.active != search.isActive {
                search.isActive = parentView.active
            }
        }

        // MARK: 시스템 → 셸

        func willPresentSearchController(_ searchController: UISearchController) {
            guard !parentView.active else { return }
            withAnimation(MyFisMotion.base) { parentView.active = true }
        }

        func didPresentSearchController(_ searchController: UISearchController) {
            // 코드로 켰으면 초점이 없다 — 누른 것과 같게 키보드를 올린다
            if !searchController.searchBar.searchTextField.isFirstResponder {
                searchController.searchBar.searchTextField.becomeFirstResponder()
            }
        }

        func willDismissSearchController(_ searchController: UISearchController) {
            guard parentView.active else { return }
            parentView.text = ""
            withAnimation(MyFisMotion.base) { parentView.active = false }
        }

        func updateSearchResults(for searchController: UISearchController) {
            let text = searchController.searchBar.text ?? ""
            if parentView.text != text { parentView.text = text }
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            parentView.onSubmit(searchBar.text ?? "")
            searchBar.searchTextField.resignFirstResponder()
        }
    }
}
