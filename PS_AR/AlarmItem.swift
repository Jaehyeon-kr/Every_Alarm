//
//  AlarmItem.swift
//  PS_AR
//
//  Created by 심재현 on 12/6/25.
//


import Foundation

struct AlarmItem: Identifiable, Codable {
    let id = UUID()
    var time: Date
    var title: String
    var repeatDays: [String]
    var isEnabled: Bool
    var isAI: Bool
}
