import Foundation

struct AlarmItem: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var title: String
    var repeatDays: [String] = []   // ← 요일 반복 기능
    var isEnabled: Bool = true
    var isAI: Bool = false          // ← AI 알람 여부
}
