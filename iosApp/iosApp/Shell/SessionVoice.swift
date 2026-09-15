import AVFoundation

/// 운동 세션 **음성 가이드** — 시스템 음성 합성(`AVSpeechSynthesizer`)으로 읽는다 (DESIGN §6.37 · NATIVE §3).
///
/// 🟢 (2026-09-15, 사용자 지정 — *안내 음성 · 무음 모드여도 말한다*). 읽을 말은 `shared` 의 `SessionVoiceScript` 한 벌이다.
/// 언제 말할지는 `WorkoutSessionStore` 가 정한다
/// - **무음 스위치를 따르지 않는다** (`.playback`) — 음성 가이드를 켠 사람은 들으려는 것이다
/// - 말하는 동안 **다른 앱 음악을 줄였다가**(`.duckOthers`) 끝나면 돌려놓는다(`.notifyOthersOnDeactivation`).
///   팟캐스트처럼 말하는 소리는 줄이지 않고 잠깐 멈춘다 (`.interruptSpokenAudioAndMixWithOthers`)
/// - 새 말은 **하던 말을 끊는다** — `⏭` 를 연달아 누르면 마지막 단계만 읽는다
/// - ⚠️ **화면이 켜져 있는 동안만** 말한다 — 백그라운드 오디오 모드를 켜지 않았다. 세션 화면은 스스로 안 꺼지니 보통은 켜져 있다
@MainActor
final class SessionVoice: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private let korean = AVSpeechSynthesisVoice(language: "ko-KR")

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func say(_ text: String) {
        sessionTrace("음성 — \(text)")
        activateSession()
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = korean
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        deactivateSession()
    }

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .voicePrompt,
                                    options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers])
            try session.setActive(true)
        } catch {
            sessionTrace("음성 세션 켜기 실패 — \(error)")
        }
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// 말을 다 했거나 끊겼을 때 — **이어 말할 게 없으면** 줄여 둔 음악을 돌려놓는다
    private func settle() {
        if !synthesizer.isSpeaking { deactivateSession() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.settle() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.settle() }
    }
}
