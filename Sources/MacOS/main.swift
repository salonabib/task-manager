import SwiftUI
import TaskManagerCore
import TaskManagerUI
import AppKit

@main
struct TaskManagerMacApp: App {
    @StateObject private var taskManager = TaskManager(repository: InMemoryTaskRepository())
    
    var body: some Scene {
        WindowGroup {
            TaskListView(taskManager: taskManager)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Load initial tasks
                    Task {
                        await taskManager.loadTasks()
                    }
                    
                    // Ensure window is frontmost
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
} 