import SwiftUI

/// SPEC.md P-05 물 마시기 (DESIGN.md §6.25 활동 화면).
///
/// 레퍼런스는 **토스 `물 마시는 습관 만들기`** 다 (사용자 지정).
/// 짜임만 가져오고 표면은 우리 것으로 옮긴다 — 원본은 **라이트 + 민트·노랑·파랑**이지만
/// 우리는 다크 + 라임 하나다 (§9 이탈 #1 · §3.2).
///
/// ⚠️ **양을 쌓는 화면이 아니라 시간 미션 화면이다.** 아침·점심·저녁 정해진 때에 한 번씩 —
/// 다음 때까지 남은 시간이 이 화면의 답이다.
struct WaterScreen: View {
    /// 걸려 있는 미션 시각 (시각 고르기에서 저장한 값)
    var times: [String: String] = WaterSlot.defaultTimes
    var onClose: () -> Void = {}
    var onChangeTime: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // 다른 잎 화면과 **같은 뒤로가기**를 쓴다 (2026-08-28 사용자 지정).
            // 이 화면은 옆에서 밀려 들어오므로 `X`(덮개)보다 `←` 가 방향과 맞는다
            DetailHeader(title: "물 마시기", onBack: onClose, light: true)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    drop

                    // **배경 빛** (§9 이탈 #5, 2026-08-28 등재) — 평평한 검정 위에 글리프만 두면
                    // 화면이 죽어 보인다. 랜딩이 빛을 까는 것과 같은 이유다.
                    //
                    // ⚠️ 덮는 자리는 **제목부터 카드까지**다. 물방울 위와 알림 줄 아래는 빛이 없다 —
                    // 화면 전체에 깔면 띠가 아니라 그냥 다른 배경색이 된다.
                    // ⚠️ 움직이지 않는다 — 기다리는 화면이라 숨쉬면 시선을 계속 끈다
                    VStack(alignment: .leading, spacing: 0) {
                        head
                        NextMission(times: times)
                            .padding(.horizontal, MyFisSpacing.screenHorizontal)
                            .padding(.top, MyFisSpacing.sectionGap)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, MyFisSpacing.xl)
                    .background(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: MyFisColor.categoryCyan.opacity(0.12), location: 0.18),
                                .init(color: MyFisColor.categoryCyan.opacity(0.12), location: 0.82),
                                .init(color: .clear, location: 1),
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                    AlarmRow()
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)
                        .padding(.top, MyFisSpacing.cardGap)

                    StreakCard()
                        .padding(.horizontal, MyFisSpacing.screenHorizontal)
                        .padding(.top, MyFisSpacing.cardGap)
                }
                .padding(.bottom, MyFisSpacing.xxxl)
            }

            // **하단 고정** (§2 원칙 2 · 5). 아직 때가 아니면 비활성이다 —
            // 비활성에 opacity 를 쓰지 않는다. 색 토큰을 바꾼다 (§9 이탈 #2, 버튼이 이미 그렇게 한다)
            // TODO: 미션 시각이 되면 켠다 (SPEC P-05)
            MyFisPrimaryButton(
                title: "6시간 40분 뒤 마실 수 있어요",
                isEnabled: false,
                light: true,
                // 활동 화면의 Primary 는 **그 활동의 색**이다 (2026-08-28)
                fill: MyFisColor.lightAccentCyan,
                onFill: MyFisColor.lightBgBase
            )
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.vertical, MyFisSpacing.md)
                .background(MyFisColor.lightBgBase)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // **흰 바탕** — 혜택의 활동 화면은 밝다 (§9 이탈 #1, 2026-08-28 개정)
        .background(MyFisColor.lightBgBase)
    }

    /// 물방울 + 제목 + 남은 시간.
    ///
    /// **주인공은 글이다** — 원본과 같다. 이 화면은 아직 할 게 없는 상태로 열리므로
    /// 숫자를 크게 둘 자리가 없다 (§2 원칙 1 의 예외를 여기 적어 둔다).
    /// 원색 벌이라 tint 하지 않는다 (§8) — 갈래 색(cyan)은 그림이 이미 들고 있다
    private var drop: some View {
        Image("ic_benefit_water_color")
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(width: 72, height: 72)
            .padding(.horizontal, MyFisSpacing.screenHorizontal)
            .padding(.top, MyFisSpacing.sectionGap)
            .padding(.bottom, MyFisSpacing.xl)
    }

    private var head: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ⚠️ **한 줄로 둔다.** `display`(32) 로는 `물 마시는 습관을 / 만들어요` 로 깨져
            // 제목이 문장의 반 토막처럼 보였다 (2026-08-28). `title.lg`(24) 가 §4.2 의 "화면 제목" 이다
            Text("물 마시는 습관을 만들어요")
                .font(MyFisFont.titleLg)
                .foregroundStyle(MyFisColor.lightTextPrimary)
                .lineLimit(1)

            Text("6시간 40분 뒤 참여할 수 있어요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.lightTextSecondary)
                .padding(.top, MyFisSpacing.sm)

            TimeChip(onTap: onChangeTime)
                .padding(.top, MyFisSpacing.xl)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MyFisSpacing.screenHorizontal)
    }
}

/// `시간 바꾸기` — 알약 칩 (§5.2 `size.chip`). 액센트를 쓰지 않는다
private struct TimeChip: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MyFisSpacing.xs) {
                Image("ic_header_notification")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(MyFisColor.lightTextSecondary)
                Text("시간 바꾸기")
                    .font(MyFisFont.label)
                    .foregroundStyle(MyFisColor.lightTextPrimary)
            }
            .padding(.horizontal, MyFisSpacing.md)
            .frame(height: MyFisSize.chip)
            .background(MyFisColor.lightSurface2, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.myFisTap)
    }
}

/// 다음 미션 카드 — 안내 두 줄 + 세 때.
private struct NextMission: View {
    let times: [String: String]

    var body: some View {
        MyFisCard(light: true) {
            Text("다음 미션까지 6시간 40분 남았어요")
                .font(MyFisFont.body)
                .foregroundStyle(MyFisColor.lightTextPrimary)

            Text("놓쳐도 다음 미션 전까지 다시 할 수 있어요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.lightTextTertiary)
                .padding(.top, 2)

            HStack(spacing: MyFisSpacing.sm) {
                ForEach(WaterSlot.all) { slot in
                    MissionSlot(slot: slot, time: times[slot.name] ?? "")
                }
            }
            .padding(.top, MyFisSpacing.lg)
        }
    }
}

/// 때 한 칸 — 그림 · 이름 · 시각.
///
/// 그림은 **이모지**다 (사용자 지정). 해·구름·달 벌을 셋 새로 그리는 대신 시스템 글꼴에 맡긴다 —
/// 둥근 네모 안에 글자만 남으면 **꺼진 입력 칸처럼** 보인다 (§8).
/// ⚠️ 크기는 `display`(32) 를 빌려 쓴다. 이모지에 날글꼴 크기를 주면 §4.2 토큰 밖이 된다
private struct MissionSlot: View {
    let slot: WaterSlot
    let time: String

    var body: some View {
        VStack(spacing: 0) {
            Text(slot.emoji)
                .font(MyFisFont.display)
            Text(slot.name)
                .font(MyFisFont.titleSm)
                .foregroundStyle(MyFisColor.lightTextPrimary)
                .padding(.top, MyFisSpacing.sm)
            Text(time)
                .font(MyFisFont.bodySm.monospacedDigit())
                .foregroundStyle(MyFisColor.lightTextSecondary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MyFisSpacing.lg)
        .background(MyFisColor.lightSurface2, in: RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous))
    }
}

/// `알림 켜고 +10 P 받기` — **이 화면의 라임 한 곳**이다.
///
/// 판을 라임으로 채우지 않고 **테두리만** 두른다 — 채우면 위 카드보다 이 줄이 세진다
/// (§6.26 찾기 줄과 같은 판단). 하단 버튼은 지금 비활성이라 라임이 아니다
private struct AlarmRow: View {
    var body: some View {
        // TODO: 알림 권한 요청 · 적립 (SPEC P-05)
        Button {} label: {
            MyFisCard(light: true) {
                HStack(spacing: 0) {
                    Image("ic_header_notification")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(MyFisColor.lightTextPrimary)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("알림 켜고 +10 P 받기")
                            .font(MyFisFont.body)
                            .foregroundStyle(MyFisColor.lightTextPrimary)
                        Text("물 마실 시간을 알려드려요")
                            .font(MyFisFont.bodySm)
                            .foregroundStyle(MyFisColor.lightTextTertiary)
                            .padding(.top, 2)
                    }
                    .padding(.leading, MyFisSpacing.md)

                    Spacer(minLength: MyFisSpacing.sm)

                    Image("ic_chevron_down")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(MyFisColor.lightTextTertiary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: MyFisRadius.md, style: .continuous)
                    .strokeBorder(MyFisColor.lightAccentCyan, lineWidth: 1.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.myFisTap)
    }
}

// TODO(서버): 미션 시각 후보를 서버가 준다 (SPEC P-05)
struct WaterSlot: Identifiable {
    let emoji: String
    let name: String
    let times: [String]

    var id: String { name }

    /// 처음 걸려 있는 미션 시각. TODO(서버): 회원이 고른 값을 서버가 준다 (SPEC P-05)
    static let defaultTimes = ["아침": "8:00", "점심": "12:00", "저녁": "18:00"]

    static let all = [
        WaterSlot(emoji: "⛅", name: "아침", times: ["7:00", "7:30", "8:00", "8:30", "9:00"]),
        WaterSlot(emoji: "🌞", name: "점심", times: ["11:00", "11:30", "12:00", "12:30", "13:00"]),
        WaterSlot(emoji: "🌙", name: "저녁", times: ["17:00", "17:30", "18:00", "18:30", "19:00"]),
    ]
}

/// 7일 도장판 — **며칠째인지**를 보여 준다.
///
/// ⚠️ 원본은 오늘 칸과 `n일차` 를 민트로 칠하지만 우리는 **표면 밝기로** 표시한다.
/// 이 화면의 라임은 위 `알림 켜고` 테두리 하나뿐이다 (§2 원칙 3 — 화면당 두 곳).
/// 시각 고르기(P-05)에서 고른 칩을 표시한 방법과 같다.
private struct StreakCard: View {
    // TODO(서버): 며칠째인지 서버가 준다 (SPEC P-05)
    private let day = 1

    var body: some View {
        MyFisCard(light: true) {
            HStack(spacing: MyFisSpacing.sm) {
                Text("7일 성공하면 보상을 드려요")
                    .font(MyFisFont.titleSm)
                    .foregroundStyle(MyFisColor.lightTextPrimary)
                Spacer(minLength: 0)
                Text("\(day)일차")
                    .font(MyFisFont.titleSm.monospacedDigit())
                    .foregroundStyle(MyFisColor.lightTextPrimary)
            }

            HStack(spacing: 0) {
                // 앞 여섯 칸은 날짜, 마지막 한 칸은 **선물**이다 — 일곱 번째 날이 아니라 보상 자리다
                ForEach(1...6, id: \.self) { n in
                    DayDot(label: "\(n)", reached: n <= day)
                    Spacer(minLength: 0)
                }
                DayDot(label: "🎁", reached: false)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, MyFisSpacing.lg)

            Text("하루 2번 이상 마시면 1일 성공이에요")
                .font(MyFisFont.bodySm)
                .foregroundStyle(MyFisColor.lightTextTertiary)
                .padding(.top, MyFisSpacing.md)
        }
    }
}

/// 도장 한 칸. 지나온 날은 판을 한 단계 올리고 테두리를 두른다 (§5.4)
private struct DayDot: View {
    let label: String
    let reached: Bool

    var body: some View {
        Text(label)
            .font(MyFisFont.body.monospacedDigit())
            .foregroundStyle(reached ? MyFisColor.lightTextPrimary : MyFisColor.lightTextTertiary)
            .frame(width: MyFisSize.chip, height: MyFisSize.chip)
            .background(reached ? MyFisColor.lightSurface3 : MyFisColor.lightSurface2, in: Circle())
            .overlay {
                if reached {
                    // 지나온 칸은 **라임 테두리**. 칠은 그대로 둔다 — 채우면 일곱 칸이 시끄럽다
                    Circle().strokeBorder(MyFisColor.lightAccentCyan, lineWidth: 1.5)
                }
            }
    }
}
