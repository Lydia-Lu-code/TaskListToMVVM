//
//  ViewModel.swift
//  TaskListToMVVM
//
//  Created by Lydia Lu on 2024/11/18.
//

import Foundation
import UserNotifications


class TaskListViewModel {
    private var taskStorage: [String: [Task]] = [:]
    var tasks: [Task] = [] {
        didSet {
            onTasksUpdated?()
        }
    }
    var onTasksUpdated: (() -> Void)?
 
}

extension TaskListViewModel {
    func loadTasks(for date: Date) {
        // 模擬從本地存儲加載數據
        let sampleTasks = [
            Task(id: UUID(), title: "完成專案報告", description: "需要提交給主管", dueDate: date, status: .todo, priority: .high, notificationEnabled: true),
            Task(id: UUID(), title: "回覆郵件", description: nil, dueDate: date, status: .inProgress, priority: .medium, notificationEnabled: false),
            Task(id: UUID(), title: "預約醫生", description: "年度檢查", dueDate: date, status: .todo, priority: .low, notificationEnabled: true)
        ]
        
        tasks = sampleTasks
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        if task.notificationEnabled {
            scheduleNotification(for: task)
        }
    }
    
    private func scheduleNotification(for task: Task) {
        // 在這裡實現本地通知的邏輯
        let content = UNMutableNotificationContent()
        content.title = "任務提醒"
        content.body = task.title
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}


extension TaskListViewModel {
    func updateTask(_ task: Task, at index: Int) {
        guard index < tasks.count else { return }
        tasks[index] = task
    }
}
