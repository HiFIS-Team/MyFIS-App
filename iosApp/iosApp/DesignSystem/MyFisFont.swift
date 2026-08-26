import CoreText
import SwiftUI
import UIKit

/// DESIGN.md §4 타이포그래피.
///
/// metric* 은 숫자 전용 스케일이다. 변하는 숫자는 반드시 `.monospacedDigit()` —
/// 세트 카운트가 바뀔 때 자릿수 때문에 레이아웃이 흔들리면 안 된다.
///
///
/// Pretendard Std (KS X 1001 서브셋, OFL-1.1 — LICENSES/OFL-Pretendard.txt).
/// 한글·영문·숫자가 한 가족이라 섞인 문장에서 무게감이 어긋나지 않는다.
/// 서브셋에 없는 희귀 음절은 시스템 폰트로 폴백된다.
enum MyFisFont {
    private enum Face {
        static let regular = "PretendardStd-Regular"
        static let medium = "PretendardStd-Medium"
        static let semibold = "PretendardStd-SemiBold"
        static let bold = "PretendardStd-Bold"
        static let wordmark = "Kanit-BoldItalic"
    }

    static let metricXl = Font.custom(Face.bold, size: 56).monospacedDigit()
    static let metricLg = Font.custom(Face.bold, size: 40).monospacedDigit()
    static let metricMd = Font.custom(Face.semibold, size: 28).monospacedDigit()

    /// 활동 랜딩(§6.25) 제목 전용 — 두 줄짜리 큰 문장. 숫자 스케일(`metric.*`)을 글에 쓰지 않으려고 따로 둔다
    static let display = Font.custom(Face.bold, size: 32)

    static let titleLg = Font.custom(Face.bold, size: 24)
    static let titleMd = Font.custom(Face.semibold, size: 20)
    static let titleSm = Font.custom(Face.semibold, size: 17)

    // 본문은 **Medium(500)** 이다 (2026-08-26) — 한글은 400 으로 두면 검정 위에서 흐려 보인다
    static let body = Font.custom(Face.medium, size: 16)
    static let bodySm = Font.custom(Face.medium, size: 14)
    static let label = Font.custom(Face.medium, size: 13)
    static let caption = Font.custom(Face.regular, size: 12)

    /// 워드마크(MyFIS) 전용 — Kanit Bold Italic (OFL-1.1, LICENSES/OFL-Kanit.txt).
    /// 기울어져 있어 움직이는 느낌이 난다. 본문 서체와 별개이며 **로고에만 쓴다.**
    /// 안드로이드와 같은 값 — 22 / Bold Italic / letterSpacing `-0.01em`
    static let wordmark = Font.custom(Face.wordmark, size: 22)
    static let wordmarkTracking: CGFloat = -0.22

    /// 번들 폰트를 프로세스에 등록한다. 앱 시작 시 한 번 호출한다.
    ///
    /// `INFOPLIST_KEY_UIAppFonts` 는 Xcode 가 지원하지 않는 키라 생성된 Info.plist 에 안 들어간다.
    /// Info.plist 를 직접 관리하는 대신 여기서 등록한다.
    ///
    /// ⚠️ **워드마크(Kanit)를 빠뜨리면 조용히 시스템 폰트로 떨어진다** — 안 죽으니 눈으로만 잡힌다
    static func register() {
        let faces: [(name: String, ext: String)] = [
            (Face.regular, "otf"), (Face.medium, "otf"),
            (Face.semibold, "otf"), (Face.bold, "otf"),
            (Face.wordmark, "ttf"),
        ]
        for face in faces {
            guard let url = Bundle.main.url(forResource: face.name, withExtension: face.ext) else {
                assertionFailure("폰트를 번들에서 못 찾음: \(face.name).\(face.ext)")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                assertionFailure("폰트 등록 실패: \(face.name) — \(String(describing: error))")
            }
        }

        verify(faces.map(\.name))
    }

    /// **등록에 성공해도 이름이 틀리면 조용히 시스템 폰트로 떨어진다.**
    /// 앱이 죽지 않아 눈으로만 잡히므로(워드마크가 그렇게 한 번 빠졌다) 여기서 확인한다.
    private static func verify(_ names: [String]) {
        let missing = names.filter { UIFont(name: $0, size: 16) == nil }
        if missing.isEmpty {
            print("[MyFisFont] 서체 \(names.count)벌 적용됨: \(names.joined(separator: ", "))")
        } else {
            assertionFailure("[MyFisFont] 이름이 안 맞아 시스템 폰트로 떨어짐: \(missing)")
        }
    }
}
