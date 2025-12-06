//
//  AlarmStore.swift
//  PS_AR
//
//  Created by 심재현 on 12/6/25.
//


import Foundation
import UserNotifications

class AlarmStore: ObservableObject {
static let shared = AlarmStore()

@Published var alarms: [AlarmItem] = []

func add(_ alarm: AlarmItem) {
    alarms.append(alarm)
    schedule(alarm)
}

func addAlarm(time: Date, title: String) {
    let newAlarm = AlarmItem(
        time: time,
        title: title,
        isEnabled: true
    )
    add(newAlarm)
}

func update(_ alarm: AlarmItem) {
    if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
        alarms[index] = alarm
        schedule(alarm)
    }
}

func toggle(_ alarm: AlarmItem) {
    if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
        alarms[index].isEnabled.toggle()
        if alarms[index].isEnabled {
            schedule(alarms[index])
        } else {
            cancel(alarms[index])
        }
    }
}
    
func delete(_ alarm: AlarmItem) {
    alarms.removeAll { $0.id == alarm.id }
    cancel(alarm)
}


private func schedule(_ alarm: AlarmItem) {
    let content = UNMutableNotificationContent()
    content.title = alarm.title
    content.body = "Alarm"
    content.sound = .default

    let comps = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

    let request = UNNotificationRequest(
        identifier: alarm.id.uuidString,
        content: content,
        trigger: trigger
    )
    UNUserNotificationCenter.current().add(request)
}

private func cancel(_ alarm: AlarmItem) {
    UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
}
}
