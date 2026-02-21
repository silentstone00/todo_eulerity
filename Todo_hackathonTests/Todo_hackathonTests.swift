import XCTest
@testable import Todo_hackathon

@MainActor
final class Todo_hackathonTests: XCTestCase {
    
    // MARK: - Task Model Tests
    func testTaskCreation() {
        let task = Task(title: "Test Task", createdAt: Date())
        
        XCTAssertFalse(task.isCompleted)
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertNotNil(task.id)
    }
    
    func testTaskIsExpired_WithNoExpirationTime() {
        let task = Task(title: "Test Task", createdAt: Date(), expirationTime: nil)
        
        XCTAssertFalse(task.isExpired)
    }
    
    func testTaskIsExpired_WithFutureExpirationTime() {
        let futureTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let task = Task(title: "Test Task", createdAt: Date(), expirationTime: futureTime)
        
        XCTAssertFalse(task.isExpired)
    }
    
    func testTaskIsExpired_WithPastExpirationTime() {
        let pastTime = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let task = Task(title: "Test Task", createdAt: Date(), expirationTime: pastTime)
        
        XCTAssertTrue(task.isExpired)
    }
    
    // MARK: - DateService Tests
    
    func testDateServiceIsToday() {
        let dateService = DateServiceImpl()
        let today = Date()
        
        XCTAssertTrue(dateService.isToday(today))
    }
    
    func testDateServiceIsTodayWithYesterday() {
        let dateService = DateServiceImpl()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        XCTAssertFalse(dateService.isToday(yesterday))
    }
    
    func testDateServiceStartOfToday() {
        let dateService = DateServiceImpl()
        let startOfToday = dateService.startOfToday()
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startOfToday)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    // MARK: - StorageService Tests
    
    func testStorageSaveAndLoad() async throws {
        let storageService = StorageServiceImpl()
        let task = Task(title: "Test Task", createdAt: Date())
        
        try await storageService.save(task)
        let loadedTasks = try await storageService.loadAll()
        
        XCTAssertTrue(loadedTasks.contains(where: { $0.id == task.id }))
    }
    
    func testStorageDelete() async throws {
        let storageService = StorageServiceImpl()
        let task = Task(title: "Test Task", createdAt: Date())
        
        try await storageService.save(task)
        try await storageService.delete(task.id)
        let loadedTasks = try await storageService.loadAll()
        
        XCTAssertFalse(loadedTasks.contains(where: { $0.id == task.id }))
    }
    
    // MARK: - TaskService Tests
    
    func testTaskServiceValidateTitle() {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        XCTAssertTrue(taskService.validateTitle("Valid Title"))
        XCTAssertFalse(taskService.validateTitle(""))
        XCTAssertFalse(taskService.validateTitle("   "))
    }
    
    func testTaskServiceValidateExpirationTime_WithFutureToday() {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let futureToday = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        XCTAssertTrue(taskService.validateExpirationTime(futureToday))
    }
    
    func testTaskServiceValidateExpirationTime_WithPastToday() {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let pastToday = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        XCTAssertFalse(taskService.validateExpirationTime(pastToday))
    }
    
    func testTaskServiceValidateExpirationTime_WithTomorrow() {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertFalse(taskService.validateExpirationTime(tomorrow))
    }
    
    func testTaskServiceCreateTask() async throws {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let task = try await taskService.createTask(title: "New Task", expirationTime: nil)
        
        XCTAssertEqual(task.title, "New Task")
        XCTAssertFalse(task.isCompleted)
    }
    
    func testTaskServiceToggleCompletion() async throws {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let task = try await taskService.createTask(title: "Toggle Task", expirationTime: nil)
        let toggledTask = try await taskService.toggleCompletion(taskId: task.id)
        
        XCTAssertTrue(toggledTask.isCompleted)
    }
    
    func testTaskServiceLoadTodaysTasks() async throws {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let todayTask = try await taskService.createTask(title: "Today's Task", expirationTime: nil)
        
        let tasks = try await taskService.loadTodaysTasks()
        
        XCTAssertTrue(tasks.contains(where: { $0.id == todayTask.id }))
    }
    
    func testTaskServiceCreateTask_WithInvalidTitle() async {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        do {
            _ = try await taskService.createTask(title: "", expirationTime: nil)
            XCTFail("Should throw invalidTitle error")
        } catch let error as TaskError {
            if case .invalidTitle = error {
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTaskServiceCreateTask_WithTitleTooLong() async {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let longTitle = String(repeating: "a", count: 501)
        
        do {
            _ = try await taskService.createTask(title: longTitle, expirationTime: nil)
            XCTFail("Should throw titleTooLong error")
        } catch let error as TaskError {
            if case .titleTooLong = error {
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTaskServiceDeleteTask() async throws {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let task = try await taskService.createTask(title: "Delete Me", expirationTime: nil)
        try await taskService.deleteTask(taskId: task.id)
        
        let tasks = try await taskService.loadTodaysTasks()
        XCTAssertFalse(tasks.contains(where: { $0.id == task.id }))
    }
    
    func testTaskServiceDeleteYesterdaysTasks() async throws {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
    
        let todayTask = try await taskService.createTask(title: "Today's Task", expirationTime: nil)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayTask = Task(title: "Yesterday's Task", createdAt: yesterday)
        try await storageService.save(yesterdayTask)
        
        try await taskService.deleteYesterdaysTasks()
        
        let allTasks = try await storageService.loadAll()
    
        XCTAssertTrue(allTasks.contains(where: { $0.id == todayTask.id }))
    
        XCTAssertFalse(allTasks.contains(where: { $0.id == yesterdayTask.id }))
    }
    
    func testTaskServiceToggleCompletion_TaskNotFound() async {
        let dateService = DateServiceImpl()
        let storageService = StorageServiceImpl()
        let notificationService = NotificationServiceImpl()
        let taskService = TaskServiceImpl(dateService: dateService, storageService: storageService, notificationService: notificationService)
        
        let nonExistentId = UUID()
        
        do {
            _ = try await taskService.toggleCompletion(taskId: nonExistentId)
            XCTFail("Should throw taskNotFound error")
        } catch let error as TaskError {
            if case .taskNotFound = error {
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Cleanup
    
    override func tearDown() async throws {
        let storageService = StorageServiceImpl()
        let tasks = try await storageService.loadAll()
        for task in tasks {
            try await storageService.delete(task.id)
        }
    }
}
