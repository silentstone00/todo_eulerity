import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var newTaskTitle = ""
    @State private var showExpirationPicker = false
    @State private var selectedExpirationTime: Date?
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isTextFieldFocused: Bool
    
    init(viewModel: TaskListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                taskListContent
                bottomInputBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    statsView
                }
            }
            .task {
                await viewModel.requestNotificationPermission()
                await viewModel.loadTasks()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    _Concurrency.Task {
                        await viewModel.refreshIfNeeded()
                    }
                }
            }
        }
    }
    
    private var statsView: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .imageScale(.small)
                Text("\(completedCount)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "circle")
                    .foregroundStyle(.blue)
                    .imageScale(.small)
                Text("\(activeCount)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
    
    @ViewBuilder
    private var taskListContent: some View {
        if viewModel.tasks.isEmpty {
            EmptyStateView()
                .contentShape(Rectangle())
                .onTapGesture {
                    isTextFieldFocused = false
                }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    if !activeTasks.isEmpty {
                        taskSection(title: "To Do", tasks: activeTasks, icon: "circle")
                    }
                    
                    if !expiredTasks.isEmpty {
                        taskSection(title: "Expired", tasks: expiredTasks, icon: "clock.badge.exclamationmark", color: .red)
                    }
                    
                    if !completedTasks.isEmpty {
                        taskSection(title: "Completed", tasks: completedTasks, icon: "checkmark.circle.fill", color: .green)
                    }
                }
                .fontWeight(.light)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
    }
    
    private func taskSection(title: String, tasks: [Task], icon: String, color: Color = .blue) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .imageScale(.small)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(tasks.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            
            ForEach(tasks) { task in
                TaskRowView(task: task) {
                    _Concurrency.Task {
                        await viewModel.toggleTaskCompletion(task.id)
                    }
                }
            }
        }
    }
    
    private var activeTasks: [Task] {
        viewModel.tasks.filter { !$0.isCompleted && !$0.isExpired }
    }
    
    private var expiredTasks: [Task] {
        viewModel.tasks.filter { !$0.isCompleted && $0.isExpired }
    }
    
    private var completedTasks: [Task] {
        viewModel.tasks.filter { $0.isCompleted }
    }
    
    private var bottomInputBar: some View {
        VStack(spacing: 0) {
            if showExpirationPicker {
                expirationPickerSection
            }
            
            if let errorMessage = viewModel.errorMessage {
                errorMessageBanner(errorMessage)
            }
            
            if let expTime = selectedExpirationTime {
                selectedTimeBadge(expTime)
            }
            
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                HStack(spacing: 8) {
                    TextField("Add a task...", text: $newTaskTitle, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            addTask()
                        }
                    
                    if !newTaskTitle.isEmpty {
                        Button(action: {
                            newTaskTitle = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                                .imageScale(.small)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showExpirationPicker.toggle()
                        }
                    }) {
                        Image(systemName: showExpirationPicker ? "clock.fill" : "clock")
                            .foregroundStyle(selectedExpirationTime != nil ? .blue : .gray)
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        addTask()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(canSendTask ? .blue : .gray)
                            .font(.system(size: 28))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSendTask)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, y: -2)
    }
    
    private var expirationPickerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Set Reminder Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showExpirationPicker = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            DatePicker(
                "Expiration Time",
                selection: Binding(
                    get: { selectedExpirationTime ?? defaultExpirationTime },
                    set: { selectedExpirationTime = $0 }
                ),
                in: Date()...endOfToday,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 120)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func selectedTimeBadge(_ time: Date) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.fill")
                .foregroundStyle(.orange)
                .imageScale(.small)
            
            Text("Reminder: \(time, style: .time)")
                .font(.subheadline)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    selectedExpirationTime = nil
                    showExpirationPicker = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.1))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func errorMessageBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .imageScale(.small)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.red.opacity(0.1))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var defaultExpirationTime: Date {
        Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    }
    
    private var endOfToday: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
    }
    
    private var completedCount: Int {
        viewModel.tasks.filter { $0.isCompleted }.count
    }
    
    private var activeCount: Int {
        viewModel.tasks.filter { !$0.isCompleted }.count
    }
    
    private var canSendTask: Bool {
        !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addTask() {
        guard canSendTask else { return }
        
        isTextFieldFocused = false
        
        _Concurrency.Task {
            await viewModel.addTask(title: newTaskTitle, expirationTime: selectedExpirationTime)
            newTaskTitle = ""
            selectedExpirationTime = nil
            withAnimation {
                showExpirationPicker = false
            }
        }
    }
}
