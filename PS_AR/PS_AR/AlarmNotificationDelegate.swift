import Foundation
import UserNotifications
import UIKit

class AlarmNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = AlarmNotificationDelegate()

    func register() {
        UNUserNotificationCenter.current().delegate = self
    }

    // 앱이 background/locked 상태에서 알람 눌렀을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        // 🔥 알람 소리 재생 추가!!
        AlarmAudioManager.shared.playAlarmSound()

        // HomeView한테 신호
        NotificationCenter.default.post(name: Notification.Name("AlarmDidFire"), object: nil)

        completionHandler()
    }

    // 앱이 foreground일 때 알람 오는 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        // 🔥 foreground 알람도 소리 재생!!
        AlarmAudioManager.shared.playAlarmSound()

        // 게임 뷰 띄우기 위한 신호
        NotificationCenter.default.post(name: Notification.Name("AlarmDidFire"), object: nil)

        // 알림 화면에 표시
        completionHandler([.badge, .banner, .sound])
    }
}
