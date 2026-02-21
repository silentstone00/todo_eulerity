import SwiftUI

@main
struct Todo_hackathonApp: App {

    private let dateService: DateService
    private let storageService: StorageService
    private let notificationService: NotificationService
    private let taskService: TaskService
    private let viewModel: TaskListViewModel
    
    init() {

        self.dateService = DateServiceImpl()
        self.storageService = StorageServiceImpl()
        self.notificationService = NotificationServiceImpl()
        self.taskService = TaskServiceImpl(
            dateService: dateService,
            storageService: storageService,
            notificationService: notificationService
        )
        
        self.viewModel = TaskListViewModel(
            taskService: taskService,
            dateService: dateService,
            notificationService: notificationService
        )
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: viewModel)
        }
    }
}
