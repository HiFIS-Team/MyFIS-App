import CoreText
import SwiftUI

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
    }

    static let metricXl = Font.custom(Face.bold, size: 56).monospacedDigit()
    static let metricLg = Font.custom(Face.bold, size: 40).monospacedDigit()
    static let metricMd = Font.custom(Face.semibold, size: 28).monospacedDigit()

    static let titleLg = Font.custom(Face.bold, size: 24)
    static let titleMd = Font.custom(Face.semibold, size: 20)
    static let titleSm = Font.custom(Face.semibold, size: 17)

    static let body = Font.custom(Face.regular, size: 16)
    static let bodySm = Font.custom(Face.regular, size: 14)
    static let label = Font.custom(Face.medium, size: 13)
    static let caption = Font.custom(Face.regular, size: 12)

    /// 워드마크(MyFIS) 전용 — Kanit Bold Italic (OFL-1.1, LICENSES/OFL-Kanit.txt).
    /// 기울어져 있어 움직이는 느낌이 난다. 본문 서체와 별개이며 **로고에만 쓴다.**
    static let wordmark = Font.custom("Kanit-BoldItalic", size: 22)

    /// 번들에 들어 있는 Pretendard 를 프로세스에 등록한다. 앱 시작 시 한 번 호출한다.
    ///
    /// `INFOPLIST_KEY_UIAppFonts` 는 Xcode 가 지원하지 않는 키라 생성된 Info.plist 에 들어가지 않는다.
    /// Info.plist 를 직접 관리하는 대신 여기서 등록한다.
    static func register() {
        let faces: [(String, String)] = [
            (Face.regular, "otf"), (Face.medium, "otf"),
            (Face.semibold, "otf"), (Face.bold, "otf"),
            ("Kanit-BoldItalic", "ttf"),
        ]
        for (name, ext) in faces {
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
                // 폰트가 없다고 앱을 죽이지 않는다. 시스템 폰트로 떨어질 뿐이다.
                print("[MyFisFont] 번들에서 못 찾음: \(name).\(ext)")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                print("[MyFisFont] 등록 실패: \(name) — \(String(describing: error?.takeUnretainedValue()))")
            }
        }
    }
}
