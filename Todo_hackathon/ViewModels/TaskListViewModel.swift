import Foundation
import SwiftUI
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [Task] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let taskService: TaskService
    private let dateService: DateService
    private let notificationService: NotificationService
    
    init(taskService: TaskService, dateService: DateService, notificationService: NotificationService) {
        self.taskService = taskService
        self.dateService = dateService
        self.notificationService = notificationService
    }
    
    func requestNotificationPermission() async {
        do {
            _ = try await notificationService.requestAuthorization()
        } catch {
    
        }
    }
    
    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await taskService.deleteYesterdaysTasks()
            
            tasks = try await taskService.loadTodaysTasks()
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addTask(title: String, expirationTime: Date? = nil) async {
        guard taskService.validateTitle(title) else {
            errorMessage = "Task title cannot be empty"
            return
        }
        
        if let expTime = expirationTime, !taskService.validateExpirationTime(expTime) {
            errorMessage = "Expiration time must be today and in the future"
            return
        }
        
        errorMessage = nil
        
        do {
            let newTask = try await taskService.createTask(title: title, expirationTime: expirationTime)
            tasks.insert(newTask, at: 0)
        } catch {
            errorMessage = "Failed to create task: \(error.localizedDescription)"
        }
    }
    
    func toggleTaskCompletion(_ taskId: UUID) async {
        errorMessage = nil
        
        do {
            let updatedTask = try await taskService.toggleCompletion(taskId: taskId)
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                tasks[index] = updatedTask
            }
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
        }
    }
    
    func refreshIfNeeded() async {
        await loadTasks()
    }
}
