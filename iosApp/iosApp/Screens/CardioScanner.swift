import CoreNFC
import Foundation

/// SPEC.md C-02 기기 NFC 스캔 — **iOS 몫**.
///
/// ⚠️ **iOS 는 우리가 화면을 못 만든다.** `CoreNFC` 를 부르면 **시스템이 자기 시트를 띄우고**
/// 앱이 정할 수 있는 건 그 안의 안내 문구(`alertMessage`) 한 줄뿐이다.
/// 안드로이드는 반대다 — 시스템 NFC 화면이 아예 없어서 **우리가 바텀시트를 그린다**
/// (`CardioScanSheet`). 그래서 이 파일에는 뷰가 없다.
///
/// **실패해도 시트를 벗어나지 않는다** (SPEC) — 시스템 시트 안에서 문구만 갈아 끼운다.
///
/// 🔵 **실기기에서만 뜬다.** 시뮬레이터는 `readingAvailable` 이 `false` 라 아무 일도 안 일어난다.
/// 실기기에서도 Xcode 의 **Near Field Communication Tag Reading** 자격을 켜야 동작한다.
final class CardioScanner: NSObject {
    static let shared = CardioScanner()

    private var session: NFCTagReaderSession?

    /// 태그 대기를 시작한다.
    ///
    /// **NFC 미지원 단말용 대체 경로는 만들지 않는다** 🟢 (SPEC C-02) — 조용히 아무것도 안 한다.
    func start() {
        guard NFCTagReaderSession.readingAvailable else { return }

        // 우리 태그는 ISO14443(NFC-A/B) 이다 — 헬스장 기기에 붙일 스티커 규격
        let session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.alertMessage = "기기에 폰을 대주세요"
        session?.begin()
        self.session = session
    }
}

extension CardioScanner: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        self.session = nil
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        // TODO(C-03): 태그 id 로 세션 생성을 **서버에 요청한 뒤** `운동 중` 으로 넘긴다.
        // 낙관적 전환을 하지 않는다 (SPEC) — 두 사람이 같은 기기를 잡으면 안 된다
        session.alertMessage = "기기를 찾았어요"
        session.invalidate()
    }
}
