# MyFIS-App

[ MyFISㅣApp ] 피트니스스타 회원을 MyFIS App 하나로

Kotlin Multiplatform (KMP) 기반 모바일 앱입니다. 비즈니스 로직은 `shared` 모듈에 두고,
UI는 Android(Jetpack Compose)와 iOS(SwiftUI) 각각 네이티브로 구현합니다.

## 프로젝트 구조

```
MyFIS-App/
├── shared/          # Kotlin Multiplatform 공용 모듈 (Android + iOS)
│   └── src/
│       ├── commonMain/   # 공통 코드
│       ├── androidMain/   # Android 전용 actual 구현
│       ├── iosMain/       # iOS 전용 actual 구현
│       └── commonTest/    # 공통 테스트
├── androidApp/      # Android 앱 (Jetpack Compose)
├── iosApp/          # iOS 앱 (SwiftUI, Xcode 프로젝트)
└── gradle/
    └── libs.versions.toml   # 버전 카탈로그 (모든 의존성 버전은 여기서 관리)
```

`shared` 모듈은 iOS 쪽에 `SharedKit`이라는 이름의 static framework로 노출됩니다.
Swift에서는 `import SharedKit` 으로 사용합니다.

## 문서

| 문서 | 내용 |
|------|------|
| [DESIGN.md](.claude/DESIGN.md) | 디자인 시스템 — 원칙 / 컬러·타입 토큰 / 컴포넌트 / 의도된 이탈. **UI 작업 전 필독** |
| [SPEC.md](.claude/SPEC.md) | 기능 명세 — 화면 단위 명세 + 데이터 모델 |

## 서드파티 자산

| 자산 | 용도 | 라이선스 |
|------|------|----------|
| [Pretendard Std](https://github.com/orioncactus/pretendard) | 앱 전체 서체 (Android `res/font/`, iOS `iosApp/iosApp/*.otf`) | SIL OFL 1.1 — [LICENSES/OFL-Pretendard.txt](LICENSES/OFL-Pretendard.txt) |

## 요구 사항

| 도구 | 버전 |
|------|------|
| JDK | 17 이상 |
| Android SDK | Platform 37 (Android 17), Build-Tools 37.0.0 |
| Xcode | 26 이상 (iOS 빌드 시, macOS 전용) |
| Gradle | Wrapper 사용 (9.7.1, 별도 설치 불필요) |

## 초기 설정

1. 저장소 클론

   ```bash
   git clone <repo-url>
   cd MyFIS-App
   ```

2. `local.properties` 생성 (버전 관리에서 제외되어 있어 클론 후 직접 만들어야 합니다)

   ```bash
   echo "sdk.dir=$HOME/Library/Android/sdk" > local.properties
   ```

   Homebrew의 `android-commandlinetools`를 쓰는 경우:

   ```bash
   echo "sdk.dir=/opt/homebrew/share/android-commandlinetools" > local.properties
   ```

3. `JAVA_HOME` 설정 (터미널에서 빌드할 때 필요)

   ```bash
   export JAVA_HOME=$(/usr/libexec/java_home -v 17)
   ```

## 빌드 & 실행

### Android

```bash
# 디버그 APK 빌드 → androidApp/build/outputs/apk/debug/
./gradlew :androidApp:assembleDebug

# 연결된 기기/에뮬레이터에 설치
./gradlew :androidApp:installDebug

# 설치 후 실행
adb shell am start -n com.myfis.app/.MainActivity

# 릴리즈 APK
./gradlew :androidApp:assembleRelease
```

에뮬레이터 실행:

```bash
emulator -avd <AVD_NAME>   # 사용 가능한 목록: emulator -list-avds
```

### iOS

Xcode에서 `iosApp/iosApp.xcodeproj`를 열고 실행(⌘R)하면 됩니다.
빌드 시 `Build Kotlin/Native framework` 스크립트 단계가 자동으로
`./gradlew :shared:embedAndSignAppleFrameworkForXcode`를 실행해 `SharedKit`을 만들어 넣습니다.

커맨드라인으로 빌드하려면:

```bash
xcodebuild -project iosApp/iosApp.xcodeproj \
  -scheme iosApp \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

시뮬레이터에 설치/실행:

```bash
xcrun simctl install booted <빌드된 iosApp.app 경로>
xcrun simctl launch booted com.myfis.app
```

`shared` 프레임워크만 따로 빌드하려면:

```bash
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64
```

## 테스트

```bash
# 공용 모듈 전체 테스트 (JVM/Android + iOS)
./gradlew :shared:allTests

# 전체 빌드 + 검증 (lint 포함)
./gradlew build
```

## 기술 스택

- **Kotlin** 2.4.10 (Multiplatform)
- **Gradle** 9.7.1 (Wrapper, Kotlin DSL, 버전 카탈로그)
- **Android Gradle Plugin** 9.3.1
- **Android**: minSdk 24 / targetSdk 37 / compileSdk 37, Jetpack Compose (BOM 2026.08.00), Material 3
- **iOS**: SwiftUI, deployment target 17.0, 타겟 `iosArm64` / `iosSimulatorArm64` / `iosX64`
- **Application ID / Bundle ID**: `com.myfis.app`

의존성 버전은 모두 [gradle/libs.versions.toml](gradle/libs.versions.toml)에서 관리합니다.
