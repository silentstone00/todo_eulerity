import Foundation

protocol TaskService: Sendable {
    func createTask(title: String, expirationTime: Date?) async throws -> Task
    
    func toggleCompletion(taskId: UUID) async throws -> Task
    
    func deleteTask(taskId: UUID) async throws
    
    func loadTodaysTasks() async throws -> [Task]
    
    func deleteYesterdaysTasks() async throws
    
    func validateTitle(_ title: String) -> Bool
    
    func validateExpirationTime(_ date: Date?) -> Bool
}

enum TaskError: LocalizedError {
    case invalidTitle
    case titleTooLong
    case taskNotFound
    case persistenceFailure(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            "Task title cannot be empty or whitespace-only"
        case .titleTooLong:
            "Task title cannot exceed 500 characters"
        case .taskNotFound:
            "Task not found"
        case .persistenceFailure(let error):
            "Failed to save task: \(error.localizedDescription)"
        }
    }
}

final class TaskServiceImpl: TaskService {
    private let dateService: DateService
    private let storageService: StorageService
    private let notificationService: NotificationService
    
    init(dateService: DateService, storageService: StorageService, notificationService: NotificationService) {
        self.dateService = dateService
        self.storageService = storageService
        self.notificationService = notificationService
    }
    
    func createTask(title: String, expirationTime: Date?) async throws -> Task {
        guard validateTitle(title) else {
            throw TaskError.invalidTitle
        }
        
        guard title.count <= 500 else {
            throw TaskError.titleTooLong
        }
        
        let task = Task(
            title: title,
            createdAt: dateService.now(),
            isCompleted: false,
            expirationTime: expirationTime
        )
        
        do {
            try await storageService.save(task)
            
            // Schedule notification if expiration time is set
            if expirationTime != nil {
                try? await notificationService.scheduleNotification(for: task)
            }
            
            return task
        } catch {
            throw TaskError.persistenceFailure(underlying: error)
        }
    }
    
    func validateTitle(_ title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty
    }
    
    func validateExpirationTime(_ date: Date?) -> Bool {
        guard let date = date else {
            return true        }
        
        return dateService.isToday(date) && date > dateService.now()
    }
    
    func toggleCompletion(taskId: UUID) async throws -> Task {
        let tasks = try await storageService.loadAll()
        
        guard var task = tasks.first(where: { $0.id == taskId }) else {
            throw TaskError.taskNotFound
        }
        
        task.isCompleted.toggle()
        
        if task.isCompleted {
            notificationService.cancelNotification(for: taskId)
        } else if task.expirationTime != nil {
            try? await notificationService.scheduleNotification(for: task)
        }
        
        do {
            try await storageService.update(task)
            return task
        } catch {
            throw TaskError.persistenceFailure(underlying: error)
        }
    }
    
    func loadTodaysTasks() async throws -> [Task] {
        do {
            let allTasks = try await storageService.loadAll()
            let todaysTasks = allTasks.filter { dateService.isToday($0.createdAt) }
            return todaysTasks.sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw TaskError.persistenceFailure(underlying: error)
        }
    }
    
    func deleteYesterdaysTasks() async throws {
        do {
            let allTasks = try await storageService.loadAll()
            
            let yesterdaysTasks = allTasks.filter { !dateService.isToday($0.createdAt) }
            
            for task in yesterdaysTasks {

                notificationService.cancelNotification(for: task.id)
            
                try await storageService.delete(task.id)
            }
        } catch {
            throw TaskError.persistenceFailure(underlying: error)
        }
    }
    
    func deleteTask(taskId: UUID) async throws {
        
        notificationService.cancelNotification(for: taskId)
        
        do {
            try await storageService.delete(taskId)
        } catch {
            throw TaskError.persistenceFailure(underlying: error)
        }
    }
}
