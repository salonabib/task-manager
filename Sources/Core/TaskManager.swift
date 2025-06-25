import Foundation
import Combine
import SwiftUI

// MARK: - Task Manager
@MainActor
public final class TaskManager: ObservableObject {
    @Published public private(set) var tasks: [TaskItem] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    
    private let repository: TaskRepositoryProtocol
    private nonisolated(unsafe) var timer: Timer?
    
    public init(repository: TaskRepositoryProtocol) {
        self.repository = repository
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    public func loadTasks() async {
        isLoading = true
        error = nil
        
        do {
            tasks = try await repository.loadTasks()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    public func addTask(_ task: TaskItem) async {
        do {
            try await repository.saveTask(task)
            await loadTasks()
        } catch {
            self.error = error
        }
    }
    
    public func updateTask(_ task: TaskItem) async {
        do {
            try await repository.updateTask(task)
            await loadTasks()
        } catch {
            self.error = error
        }
    }
    
    public func deleteTask(id: UUID) async {
        do {
            try await repository.deleteTask(id: id)
            await loadTasks()
        } catch {
            self.error = error
        }
    }
    
    public func markTaskAsCompleted(id: UUID) async {
        guard let task = tasks.first(where: { $0.id == id }) else { return }
        
        let completedTask = TaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            priority: task.priority,
            status: .completed,
            dueDate: task.dueDate,
            tags: task.tags,
            createdAt: task.createdAt,
            updatedAt: Date(),
            timeSpent: task.timeSpent,
            timerStartTime: task.timerStartTime
        )
        
        await updateTask(completedTask)
    }
    
    public func searchTasks(filter: TaskFilter) async {
        do {
            tasks = try await repository.searchTasks(filter: filter)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Time Tracking Methods
    public func startTimer(for taskId: UUID) async {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        
        // Stop any other running timers first
        await stopAllTimers()
        
        let updatedTask = task.startTimer()
        await updateTask(updatedTask)
    }
    
    public func stopTimer(for taskId: UUID) async {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        
        let updatedTask = task.stopTimer()
        await updateTask(updatedTask)
    }
    
    public func resetTimer(for taskId: UUID) async {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        
        let updatedTask = task.resetTimer()
        await updateTask(updatedTask)
    }
    
    public func stopAllTimers() async {
        for task in tasks where task.isTimerRunning {
            let updatedTask = task.stopTimer()
            await updateTask(updatedTask)
        }
    }
    
    // MARK: - Convenience Methods
    public func getTasksByStatus(_ status: TaskStatus) -> [TaskItem] {
        return tasks.filter { $0.status == status }
    }
    
    public func getTasksByPriority(_ priority: TaskPriority) -> [TaskItem] {
        return tasks.filter { $0.priority == priority }
    }
    
    public func getOverdueTasks() -> [TaskItem] {
        let now = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < now && task.status != .completed
        }
    }
    
    public func getUpcomingTasks(within days: Int) -> [TaskItem] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= now && dueDate <= futureDate && task.status != .completed
        }
    }
    
    public func getTaskStatistics() -> TaskStatistics {
        let total = tasks.count
        let completed = tasks.filter { $0.isCompleted }.count
        let pending = tasks.filter { $0.status == .pending }.count
        let inProgress = tasks.filter { $0.status == .inProgress }.count
        let overdue = getOverdueTasks().count
        
        return TaskStatistics(
            total: total,
            completed: completed,
            pending: pending,
            inProgress: inProgress,
            overdue: overdue
        )
    }
    
    public func getTimeStatistics() -> TimeStatistics {
        let totalTimeSpent = tasks.reduce(0) { $0 + $1.currentTimeSpent }
        let tasksWithTime = tasks.filter { $0.currentTimeSpent > 0 }
        let averageTimePerTask = tasksWithTime.isEmpty ? 0 : totalTimeSpent / Double(tasksWithTime.count)
        let currentlyRunning = tasks.filter { $0.isTimerRunning }
        
        return TimeStatistics(
            totalTimeSpent: totalTimeSpent,
            averageTimePerTask: averageTimePerTask,
            tasksWithTime: tasksWithTime.count,
            currentlyRunning: currentlyRunning.count
        )
    }
    
    public func clearError() {
        error = nil
    }
    
    // MARK: - Private Methods
    private nonisolated(unsafe) func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.objectWillChange.send()
            }
        }
    }
}

// MARK: - Task Validation
public struct TaskValidator {
    public static func validate(_ task: TaskItem) -> [String] {
        var errors: [String] = []
        
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Task title cannot be empty")
        }
        
        if task.title.count > 100 {
            errors.append("Task title cannot exceed 100 characters")
        }
        
        if task.description.count > 1000 {
            errors.append("Task description cannot exceed 1000 characters")
        }
        
        if let dueDate = task.dueDate, dueDate < Date() {
            errors.append("Due date cannot be in the past")
        }
        
        return errors
    }
    
    public static func isValid(_ task: TaskItem) -> Bool {
        return validate(task).isEmpty
    }
}

// MARK: - Task Statistics
public struct TaskStatistics {
    public let total: Int
    public let completed: Int
    public let pending: Int
    public let inProgress: Int
    public let overdue: Int
    
    public var completionRate: Double {
        guard total > 0 else { return 0.0 }
        return Double(completed) / Double(total)
    }
    
    public var overdueRate: Double {
        guard total > 0 else { return 0.0 }
        return Double(overdue) / Double(total)
    }
}

// MARK: - Time Statistics
public struct TimeStatistics {
    public let totalTimeSpent: TimeInterval
    public let averageTimePerTask: TimeInterval
    public let tasksWithTime: Int
    public let currentlyRunning: Int
    
    public var formattedTotalTime: String {
        let totalSeconds = Int(totalTimeSpent)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d hours %d minutes", hours, minutes)
        } else {
            return String(format: "%d minutes", minutes)
        }
    }
    
    public var formattedAverageTime: String {
        let totalSeconds = Int(averageTimePerTask)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        } else {
            return String(format: "%d min", minutes)
        }
    }
}

// MARK: - Task Analytics
public struct TaskAnalytics {
    public static func getTasksByPriorityDistribution(_ tasks: [TaskItem]) -> [TaskPriority: Int] {
        var distribution: [TaskPriority: Int] = [:]
        for priority in TaskPriority.allCases {
            distribution[priority] = tasks.filter { $0.priority == priority }.count
        }
        return distribution
    }
    
    public static func getTasksByStatusDistribution(_ tasks: [TaskItem]) -> [TaskStatus: Int] {
        var distribution: [TaskStatus: Int] = [:]
        for status in TaskStatus.allCases {
            distribution[status] = tasks.filter { $0.status == status }.count
        }
        return distribution
    }
    
    public static func getAverageCompletionTime(_ tasks: [TaskItem]) -> TimeInterval? {
        let completedTasks = tasks.filter { $0.isCompleted }
        guard !completedTasks.isEmpty else { return nil }
        
        let totalTime = completedTasks.compactMap { task -> TimeInterval? in
            guard task.status == .completed else { return nil }
            return task.updatedAt.timeIntervalSince(task.createdAt)
        }.reduce(0, +)
        
        return totalTime / Double(completedTasks.count)
    }
    
    public static func getProductivityScore(_ tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0.0 }
        
        let completedTasks = tasks.filter { $0.isCompleted }
        let overdueTasks = tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < Date() && !task.isCompleted
        }
        
        let completionScore = Double(completedTasks.count) / Double(tasks.count)
        let overduePenalty = Double(overdueTasks.count) * 0.1
        
        return max(0.0, completionScore - overduePenalty)
    }
} 