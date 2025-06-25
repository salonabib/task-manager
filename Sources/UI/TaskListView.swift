import SwiftUI
import TaskManagerCore
import Foundation

public struct TaskListView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var showingAddTask = false
    @State private var showingEditTask = false
    @State private var editingTask: TaskItem?
    @State private var showingFilterSheet = false
    @State private var searchText = ""
    @State private var selectedFilter = TaskFilter()
    @State private var sortOrder: TaskSortOrder = .createdAt
    @State private var showingSortMenu = false
    
    public init(taskManager: TaskManager) {
        self.taskManager = taskManager
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Task Manager")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Time statistics
                TimeStatisticsView(taskManager: taskManager)
                
                // Sort menu
                Menu {
                    ForEach(TaskSortOrder.allCases, id: \.self) { sortOrder in
                        Button(sortOrder.displayName) {
                            self.sortOrder = sortOrder
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                
                // Add task button
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Search and Filter Bar
            SearchAndFilterBar(
                searchText: $searchText,
                selectedFilter: $selectedFilter,
                onFilterTap: { showingFilterSheet = true }
            )
            
            // Task List
            if taskManager.isLoading {
                LoadingView()
            } else if taskManager.tasks.isEmpty {
                EmptyStateView(
                    onAddTask: { showingAddTask = true }
                )
            } else {
                TaskListContent(
                    tasks: filteredAndSortedTasks,
                    taskManager: taskManager,
                    onToggleCompletion: { taskId in
                        _ = Task {
                            await taskManager.markTaskAsCompleted(id: taskId)
                        }
                    },
                    onEdit: { task in
                        editingTask = task
                        showingEditTask = true
                    },
                    onDelete: { taskId in
                        _ = Task {
                            await taskManager.deleteTask(id: taskId)
                        }
                    },
                    onStartTimer: { taskId in
                        _ = Task {
                            await taskManager.startTimer(for: taskId)
                        }
                    },
                    onStopTimer: { taskId in
                        _ = Task {
                            await taskManager.stopTimer(for: taskId)
                        }
                    },
                    onResetTimer: { taskId in
                        _ = Task {
                            await taskManager.resetTimer(for: taskId)
                        }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingAddTask) {
            AddTaskSheet(taskManager: taskManager)
                .frame(minWidth: 600, minHeight: 700)
        }
        .sheet(isPresented: $showingEditTask) {
            if let task = editingTask {
                EditTaskSheet(taskManager: taskManager, task: task)
                    .frame(minWidth: 600, minHeight: 700)
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(selectedFilter: $selectedFilter)
        }
        .onAppear {
            _ = Task {
                await taskManager.loadTasks()
            }
        }
        .onChange(of: searchText) { _ in
            applyFilters()
        }
        .onChange(of: selectedFilter) { _ in
            applyFilters()
        }
    }
    
    // MARK: - Computed Properties
    private var filteredAndSortedTasks: [TaskItem] {
        let filtered = taskManager.tasks.filter { task in
            let filter = TaskFilter(
                status: selectedFilter.status,
                priority: selectedFilter.priority,
                searchText: searchText,
                tags: selectedFilter.tags,
                showCompleted: selectedFilter.showCompleted
            )
            return filter.matches(task)
        }
        
        return filtered.sorted { first, second in
            switch sortOrder {
            case .title:
                return first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
            case .priority:
                return first.priority.rawValue > second.priority.rawValue
            case .dueDate:
                guard let firstDate = first.dueDate, let secondDate = second.dueDate else {
                    return first.dueDate != nil
                }
                return firstDate < secondDate
            case .createdAt:
                return first.createdAt > second.createdAt
            case .updatedAt:
                return first.updatedAt > second.updatedAt
            case .timeSpent:
                return first.currentTimeSpent > second.currentTimeSpent
            }
        }
    }
    
    // MARK: - Private Methods
    private func applyFilters() {
        let filter = TaskFilter(
            status: selectedFilter.status,
            priority: selectedFilter.priority,
            searchText: searchText,
            tags: selectedFilter.tags,
            showCompleted: selectedFilter.showCompleted
        )
        
        _ = Task {
            await taskManager.searchTasks(filter: filter)
        }
    }
}

// MARK: - Supporting Views
private struct TimeStatisticsView: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        let timeStats = taskManager.getTimeStatistics()
        
        HStack(spacing: 16) {
            VStack(alignment: .trailing, spacing: 2) {
                Text("Total Time")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(timeStats.formattedTotalTime)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Running")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(timeStats.currentlyRunning)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(timeStats.currentlyRunning > 0 ? .green : .secondary)
            }
        }
    }
}

private struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedFilter: TaskFilter
    let onFilterTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search tasks...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            
            // Filter button
            Button(action: onFilterTap) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(hasActiveFilters ? .blue : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var hasActiveFilters: Bool {
        selectedFilter.status != nil ||
        selectedFilter.priority != nil ||
        !selectedFilter.tags.isEmpty ||
        !selectedFilter.showCompleted
    }
}

private struct TaskListContent: View {
    let tasks: [TaskItem]
    let taskManager: TaskManager
    let onToggleCompletion: (UUID) -> Void
    let onEdit: (TaskItem) -> Void
    let onDelete: (UUID) -> Void
    let onStartTimer: (UUID) -> Void
    let onStopTimer: (UUID) -> Void
    let onResetTimer: (UUID) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(tasks) { task in
                    TaskRowView(
                        task: task,
                        onToggleCompletion: { onToggleCompletion(task.id) },
                        onEdit: { onEdit(task) },
                        onDelete: { onDelete(task.id) },
                        onStartTimer: { onStartTimer(task.id) },
                        onStopTimer: { onStopTimer(task.id) },
                        onResetTimer: { onResetTimer(task.id) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .refreshable {
            await taskManager.loadTasks()
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading tasks...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EmptyStateView: View {
    let onAddTask: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Tasks Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first task to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddTask) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Task")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                )
                .foregroundColor(.white)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AddTaskSheet: View {
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var task = TaskItem(title: "New Task")
    
    var body: some View {
        NavigationView {
            TaskFormView(
                task: $task,
                onSave: {
                    _ = Task {
                        await taskManager.addTask(task)
                        dismiss()
                    }
                },
                onCancel: { dismiss() }
            )
        }
        .navigationTitle("Add New Task")
    }
}

private struct EditTaskSheet: View {
    @ObservedObject var taskManager: TaskManager
    let task: TaskItem
    @Environment(\.dismiss) private var dismiss
    @State private var editedTask: TaskItem
    
    init(taskManager: TaskManager, task: TaskItem) {
        self.taskManager = taskManager
        self.task = task
        // Initialize with a copy of the task to avoid binding issues
        self._editedTask = State(initialValue: TaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            priority: task.priority,
            status: task.status,
            dueDate: task.dueDate,
            tags: task.tags,
            createdAt: task.createdAt,
            updatedAt: task.updatedAt,
            timeSpent: task.timeSpent,
            timerStartTime: task.timerStartTime
        ))
    }
    
    var body: some View {
        NavigationView {
            TaskFormView(
                task: $editedTask,
                onSave: {
                    _ = Task {
                        await taskManager.updateTask(editedTask)
                        dismiss()
                    }
                },
                onCancel: { dismiss() }
            )
        }
        .navigationTitle("Edit Task")
    }
}

public struct FilterSheet: View {
    @Binding var selectedFilter: TaskFilter
    @Environment(\.dismiss) private var dismiss
    
    @State private var status: TaskStatus?
    @State private var priority: TaskPriority?
    @State private var showCompleted: Bool
    @State private var tags: String
    
    public init(selectedFilter: Binding<TaskFilter>) {
        self._selectedFilter = selectedFilter
        self._status = State(initialValue: selectedFilter.wrappedValue.status)
        self._priority = State(initialValue: selectedFilter.wrappedValue.priority)
        self._showCompleted = State(initialValue: selectedFilter.wrappedValue.showCompleted)
        self._tags = State(initialValue: Array(selectedFilter.wrappedValue.tags).joined(separator: ", "))
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Status") {
                    Picker("Status", selection: $status) {
                        Text("Any").tag(nil as TaskStatus?)
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status as TaskStatus?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("Any").tag(nil as TaskPriority?)
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority as TaskPriority?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Options") {
                    Toggle("Show Completed Tasks", isOn: $showCompleted)
                }
                
                Section("Tags") {
                    TextField("Filter by tags (comma-separated)", text: $tags)
                }
            }
            .navigationTitle("Filter Tasks")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        status = nil
                        priority = nil
                        showCompleted = true
                        tags = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        selectedFilter = TaskFilter(
                            status: status,
                            priority: priority,
                            searchText: "",
                            tags: Set(tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }),
                            showCompleted: showCompleted
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Task Sort Order
public enum TaskSortOrder: CaseIterable {
    case title
    case priority
    case dueDate
    case createdAt
    case updatedAt
    case timeSpent
    
    var displayName: String {
        switch self {
        case .title: return "Title"
        case .priority: return "Priority"
        case .dueDate: return "Due Date"
        case .createdAt: return "Created"
        case .updatedAt: return "Updated"
        case .timeSpent: return "Time Spent"
        }
    }
} 