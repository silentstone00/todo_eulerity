import Foundation
import UserNotifications

protocol NotificationService: Sendable {
    func requestAuthorization() async throws -> Bool
    
    func scheduleNotification(for task: Task) async throws
    
    func cancelNotification(for taskId: UUID)
    
    func cancelAllNotifications()
}

final class NotificationServiceImpl: NotificationService {
    private let notificationCenter: UNUserNotificationCenter
    
    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }
    
    func requestAuthorization() async throws -> Bool {
        try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleNotification(for task: Task) async throws {
        guard let expirationTime = task.expirationTime else {
            return
        }
        
        guard expirationTime > Date() else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        
        let notificationTime = expirationTime.addingTimeInterval(-5 * 60)
        
        guard notificationTime > Date() else {
            return
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    func cancelNotification(for taskId: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [taskId.uuidString])
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
