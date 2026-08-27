import SwiftUI

// ⚠️ 이 파일은 **손으로 고치지 않는다.** `tools/floorplan/gen_floorplan.py` 가 굽는다.
// 안드로이드 쪽(`BranchFloorPlan.kt`)과 **같은 원본에서 나온다** —
// 좌표를 두 번 적으면 한쪽만 고쳐지는 날이 온다.

/// 평면도 안에서 쓰는 색갈래. 실제 색은 그리는 쪽에서 `MyFisColor` 로 푼다
enum PlanTint {
    case green, teal, violet, blue, orange, gold, pink, gray
}

/// 판 위의 물건 한 개. `tone` 은 몸통 / 얹은 것 / 기둥 / 화분
enum PlanTone {
    case body, cap, pillar, plant
}

struct PlanZone {
    let title: String
    let rect: CGRect
    let tint: PlanTint
}

struct PlanItem {
    let rect: CGRect
    let radius: CGFloat
    let tone: PlanTone
}

/// 200평 헬스장 견본 (SPEC M-08).
///
/// ⚠️ **단위는 미터가 아니다.** "재지 않고 보고 그린다"로 정했으므로 숫자는 **그림 안의 자리**다.
/// 실제와 맞아야 하는 건 셋뿐 — 상대 위치 / 뚫린 곳·막힌 곳 / 어느 구역에 몇 대.
enum BranchFloorPlan {
    static let size = CGSize(width: 300, height: 224)

    /// 바깥 벽. **닫힌 도형이 아니라 열린 선**이다 — 아래쪽 출입구에서 끊긴다
    static let outline: [CGPoint] = [
        CGPoint(x: 176, y: 224),
        CGPoint(x: 300, y: 224),
        CGPoint(x: 300, y: 0),
        CGPoint(x: 18, y: 0),
        CGPoint(x: 18, y: 26),
        CGPoint(x: 0, y: 26),
        CGPoint(x: 0, y: 224),
        CGPoint(x: 134, y: 224),
    ]

    /// 출입구 — 벽이 끊긴 자리에 서는 핀
    static let entrance = CGPoint(x: 155, y: 205)

    /// 내가 선 자리. **재서 얻은 값이 아니라 마지막으로 아는 자리**다 (SPEC M-08)
    static let mySpot = CGPoint(x: 155, y: 196)

    static let zones: [PlanZone] = [
        PlanZone(title: "카디오존", rect: CGRect(x: 10, y: 10, width: 190, height: 54), tint: .green),
        PlanZone(title: "스트레칭존", rect: CGRect(x: 208, y: 10, width: 84, height: 54), tint: .teal),
        PlanZone(title: "프리웨이트존", rect: CGRect(x: 10, y: 72, width: 104, height: 102), tint: .violet),
        PlanZone(title: "머신존", rect: CGRect(x: 122, y: 72, width: 112, height: 102), tint: .blue),
        PlanZone(title: "PT존", rect: CGRect(x: 242, y: 72, width: 50, height: 50), tint: .orange),
        PlanZone(title: "휴게존", rect: CGRect(x: 242, y: 130, width: 50, height: 44), tint: .gold),
    ]

    /// 아래 띠의 방들. 구역과 달리 **벽으로 막혀 있다**
    static let rooms: [PlanZone] = [
        PlanZone(title: "여자\n탈의실", rect: CGRect(x: 0, y: 182, width: 48, height: 42), tint: .pink),
        PlanZone(title: "여자\n샤워실", rect: CGRect(x: 48, y: 182, width: 48, height: 42), tint: .pink),
        PlanZone(title: "화장실", rect: CGRect(x: 96, y: 182, width: 38, height: 42), tint: .gray),
        PlanZone(title: "계단", rect: CGRect(x: 176, y: 182, width: 28, height: 42), tint: .gray),
        PlanZone(title: "엘리\n베이터", rect: CGRect(x: 204, y: 182, width: 28, height: 42), tint: .gray),
        PlanZone(title: "남자\n샤워실", rect: CGRect(x: 232, y: 182, width: 34, height: 42), tint: .blue),
        PlanZone(title: "남자\n탈의실", rect: CGRect(x: 266, y: 182, width: 34, height: 42), tint: .blue),
    ]

    static let items: [PlanItem] = [
        PlanItem(rect: CGRect(x: 18, y: 26, width: 14, height: 32), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 20, y: 26, width: 10, height: 7), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 38, y: 26, width: 14, height: 32), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 40, y: 26, width: 10, height: 7), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 58, y: 26, width: 14, height: 32), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 60, y: 26, width: 10, height: 7), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 78, y: 26, width: 14, height: 32), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 80, y: 26, width: 10, height: 7), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 98, y: 26, width: 14, height: 32), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 100, y: 26, width: 10, height: 7), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 123, y: 34, width: 12, height: 24), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 123.5, y: 24.5, width: 11, height: 11), radius: 5.5, tone: .cap),
        PlanItem(rect: CGRect(x: 143, y: 34, width: 12, height: 24), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 143.5, y: 24.5, width: 11, height: 11), radius: 5.5, tone: .cap),
        PlanItem(rect: CGRect(x: 163, y: 34, width: 12, height: 24), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 163.5, y: 24.5, width: 11, height: 11), radius: 5.5, tone: .cap),
        PlanItem(rect: CGRect(x: 183, y: 34, width: 12, height: 24), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 183.5, y: 24.5, width: 11, height: 11), radius: 5.5, tone: .cap),
        PlanItem(rect: CGRect(x: 216, y: 26, width: 20, height: 28), radius: 4, tone: .body),
        PlanItem(rect: CGRect(x: 240, y: 26, width: 20, height: 28), radius: 4, tone: .body),
        PlanItem(rect: CGRect(x: 264, y: 26, width: 20, height: 28), radius: 4, tone: .body),
        PlanItem(rect: CGRect(x: 280.5, y: 12.5, width: 11, height: 11), radius: 5.5, tone: .plant),
        PlanItem(rect: CGRect(x: 16, y: 90, width: 12, height: 30), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 16, y: 126, width: 12, height: 30), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 34, y: 90, width: 22, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 34, y: 90, width: 22, height: 6), radius: 3, tone: .cap),
        PlanItem(rect: CGRect(x: 34, y: 122, width: 22, height: 24), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 38, y: 128, width: 14, height: 9), radius: 3, tone: .cap),
        PlanItem(rect: CGRect(x: 66, y: 92, width: 42, height: 5), radius: 2.5, tone: .body),
        PlanItem(rect: CGRect(x: 66, y: 110, width: 42, height: 5), radius: 2.5, tone: .body),
        PlanItem(rect: CGRect(x: 66, y: 128, width: 42, height: 5), radius: 2.5, tone: .body),
        PlanItem(rect: CGRect(x: 66, y: 146, width: 42, height: 5), radius: 2.5, tone: .body),
        PlanItem(rect: CGRect(x: 14, y: 159, width: 12, height: 12), radius: 6, tone: .plant),
        PlanItem(rect: CGRect(x: 130, y: 92, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 132, y: 92, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 152, y: 92, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 154, y: 92, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 174, y: 92, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 176, y: 92, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 196, y: 92, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 198, y: 92, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 218, y: 92, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 220, y: 92, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 130, y: 134, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 132, y: 134, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 152, y: 134, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 154, y: 134, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 174, y: 134, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 176, y: 134, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 196, y: 134, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 198, y: 134, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 218, y: 134, width: 14, height: 22), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 220, y: 134, width: 10, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 250, y: 90, width: 12, height: 26), radius: 3, tone: .body),
        PlanItem(rect: CGRect(x: 250, y: 90, width: 12, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 271.5, y: 101.5, width: 13, height: 13), radius: 6.5, tone: .body),
        PlanItem(rect: CGRect(x: 272, y: 88, width: 14, height: 6), radius: 2, tone: .cap),
        PlanItem(rect: CGRect(x: 255, y: 149, width: 18, height: 18), radius: 9, tone: .cap),
        PlanItem(rect: CGRect(x: 247, y: 154, width: 8, height: 8), radius: 4, tone: .body),
        PlanItem(rect: CGRect(x: 273, y: 154, width: 8, height: 8), radius: 4, tone: .body),
        PlanItem(rect: CGRect(x: 260, y: 166, width: 8, height: 8), radius: 4, tone: .body),
        PlanItem(rect: CGRect(x: 279.5, y: 164.5, width: 11, height: 11), radius: 5.5, tone: .plant),
        PlanItem(rect: CGRect(x: 92, y: 4, width: 14, height: 12), radius: 2, tone: .pillar),
        PlanItem(rect: CGRect(x: 188, y: 4, width: 14, height: 12), radius: 2, tone: .pillar),
        PlanItem(rect: CGRect(x: 100, y: 168, width: 14, height: 12), radius: 2, tone: .pillar),
        PlanItem(rect: CGRect(x: 176, y: 168, width: 14, height: 12), radius: 2, tone: .pillar),
    ]
}
