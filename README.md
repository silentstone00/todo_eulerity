# Today - A Today-Only Todo App

> A minimalist iOS todo app where tasks only exist for the current day. Built with Swift, SwiftUI, and modern iOS architecture patterns.

![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

## 📱 Overview

**Today** is a unique todo app with one central constraint: tasks only exist for the current day. No backlogs, no future planning, no overdue tasks. Just focus on what matters today.

### Key Features

- ✅ **Today-Only Tasks** - Add and manage tasks for the current day only
- ✅ **Automatic Day Reset** - Old tasks disappear automatically when a new day begins
- ✅ **Tap to Complete** - Tap anywhere on a task to mark it complete/incomplete
- ✅ **Clean UI** - Minimalist design with thoughtful empty states
- ✅ **Dark Mode** - Full support for light and dark appearance
- ✅ **Offline First** - All data stored locally, no internet required
- ✅ **Modern Architecture** - MVVM with protocol-based services

## 🎯 Design Philosophy

This app embraces constraints as a feature:
- **Today-only focus** eliminates decision paralysis
- **Automatic expiration** prevents task accumulation
- **No deletion needed** - tasks expire naturally at day boundary
- **Simple interactions** - tap to complete, that's it

## 🏗️ Architecture

### MVVM + Services Pattern

```
┌─────────────────────────────────────────┐
│              Views (SwiftUI)            │
│  TaskListView, TaskRowView, EmptyState │
└──────────────┬──────────────────────────┘
               │ @Published
               ▼
┌─────────────────────────────────────────┐
│           ViewModel Layer               │
│        TaskListViewModel                │
└──────────────┬──────────────────────────┘
               │ Protocols
               ▼
┌─────────────────────────────────────────┐
│           Service Layer                 │
│  TaskService, StorageService,           │
│  DateService, NotificationService       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│              Models                     │
│              Task                       │
└─────────────────────────────────────────┘
```

### Project Structure

```
Todo_hackathon/
├── Models/
│   └── Task.swift                    # Core data model (Codable, Sendable)
├── Services/
│   ├── DateService.swift             # Date/time abstraction
│   ├── StorageService.swift          # JSON persistence layer
│   ├── TaskService.swift             # Business logic
│   └── NotificationService.swift     # Local notifications
├── ViewModels/
│   └── TaskListViewModel.swift       # Presentation logic (@MainActor)
└── Views/
    ├── TaskListView.swift            # Main task list
    ├── TaskRowView.swift             # Individual task row
    └── EmptyStateView.swift          # Empty state with animation
```

## 🚀 Getting Started

### Requirements

- Xcode 15.0+
- iOS 16.0+
- Swift 6.0

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd Todo_hackathon
```

2. Open in Xcode
```bash
open Todo_hackathon.xcodeproj
```

3. Build and run
- Select an iOS simulator (iOS 16.0+)
- Press `Cmd + R` to build and run
- Press `Cmd + U` to run unit tests

## 💡 Key Technical Decisions

### 1. Protocol-Based Services
All services use protocols for dependency injection and testability:
```swift
protocol TaskService: Sendable {
    func createTask(title: String, expirationTime: Date?) async throws -> Task
    func toggleCompletion(taskId: UUID) async throws -> Task
    func loadTodaysTasks() async throws -> [Task]
}
```

### 2. JSON File Storage
- Chose JSON over SwiftData/CoreData for iOS 16 compatibility
- Simple, lightweight, and sufficient for daily tasks
- Stored in Documents directory for persistence

### 3. Modern Swift Concurrency
- All async operations use `async/await`
- `@MainActor` on ViewModel ensures UI updates on main thread
- `Sendable` conformance for thread-safe data sharing
- `nonisolated(unsafe)` for FileManager compatibility

### 4. Automatic Day Boundary Detection
```swift
.onChange(of: scenePhase) { newPhase in
    if newPhase == .active {
        Task {
            await viewModel.refreshIfNeeded()
        }
    }
}
```

### 5. Tap-to-Complete UX
Entire task row is tappable with haptic feedback:
```swift
.onTapGesture {
    handleToggle() // Haptic + animation + state change
}
```

## 🧪 Testing

### Unit Test Coverage

- ✅ **Task Model** - Creation, expiration logic, equality
- ✅ **DateService** - Today detection, timezone handling
- ✅ **StorageService** - Save, load, delete, update operations
- ✅ **TaskService** - Task creation, validation, completion, filtering

Run tests:
```bash
xcodebuild test -scheme Todo_hackathon -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or in Xcode: `Cmd + U`

### Test Philosophy
- Focus on business logic and critical paths
- Protocol-based design enables easy mocking
- Async test support with `async throws`
- Proper cleanup in `tearDown()`

## 🎨 UI/UX Highlights

### Empty State
- Animated pulsing circle with checkmark icon
- Clear call-to-action pointing to input field
- iOS 16 compatible animations

### Task Rows
- System gray background for consistency
- Tap anywhere to toggle completion
- Haptic feedback on interaction
- Smooth scale animation

### Task Sections
- **To Do** - Active tasks (blue icon)
- **Expired** - Past expiration time (red icon)
- **Completed** - Finished tasks (green icon)
- Thin font weight for elegant section headers

### Launch Screen
- Dark background (#343434)
- App icon centered
- Modern iOS 16+ Info.plist approach

## 📋 Features Implemented

### Must-Have ✅
- [x] Add tasks for today
- [x] Mark tasks complete/incomplete
- [x] Local persistence (JSON)
- [x] Today-only filtering
- [x] Automatic day reset

### Optional Enhancements ✅
- [x] MVVM architecture
- [x] Protocol-based services
- [x] Unit tests
- [x] Date/time abstractions
- [x] Empty states
- [x] Light/Dark mode
- [x] Haptic feedback
- [x] Tap-to-complete UX
- [x] Launch screen

### Not Implemented (By Design)
- ❌ Task expiration time picker
- ❌ Local notifications
- ❌ Widgets
- ❌ App Intents/Siri

## 🔧 Technical Stack

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Concurrency**: async/await, @MainActor
- **Storage**: JSON file-based
- **Testing**: XCTest
- **Minimum iOS**: 16.0

## 🚧 Future Improvements

### High Priority
1. **Local Notifications** - Remind users before task expiration
2. **Swipe to Delete** - Remove tasks mid-day if needed
3. **Task Reordering** - Drag and drop to prioritize
4. **Undo/Redo** - Accidental completion recovery

### Medium Priority
5. **Home Screen Widget** - Quick glance at today's tasks
6. **App Intents** - Siri integration for voice task creation
7. **Task Categories** - Color-coded task types
8. **Statistics** - Daily completion rate tracking

### Low Priority
9. **iCloud Sync** - Sync across devices (same day only)
10. **Themes** - Custom color schemes
11. **Sounds** - Completion sound effects
12. **Accessibility** - Enhanced VoiceOver support

## 📝 Code Quality

### Swift 6 Features
- ✅ Sendable conformance
- ✅ @MainActor isolation
- ✅ async/await throughout
- ✅ nonisolated(unsafe) for compatibility
- ✅ Modern concurrency patterns

### Best Practices
- ✅ Protocol-oriented design
- ✅ Dependency injection
- ✅ Error handling with custom types
- ✅ Comprehensive unit tests
- ✅ Clean code organization
- ✅ No warnings or errors

## 🤝 Contributing

This is a take-home exercise project, but feedback and suggestions are welcome!

## 📄 License

MIT License - feel free to use this code for learning purposes.

## 👤 Author

Built as part of the Eulerity iOS Take-Home Exercise

---

**Time Spent**: ~6 hours  
**Focus**: Clean architecture, testability, and core functionality  
**Status**: ✅ Ready for submission (pending demo video)
