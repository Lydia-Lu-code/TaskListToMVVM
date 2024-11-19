//
//  Models.swift
//  TaskListToMVVM
//
//  Created by Lydia Lu on 2024/11/18.
//

import Foundation

// Model
struct Task: Codable {
    var id: UUID
    var title: String
    var description: String?
    var dueDate: Date
    var status: TaskStatus
    var priority: TaskPriority
    var notificationEnabled: Bool
}

enum TaskStatus: String, Codable {
    case todo = "待辦"
    case inProgress = "進行中"
    case completed = "完成"
}

enum TaskPriority: String, Codable {
    case low = "低"
    case medium = "中"
    case high = "高"
}
