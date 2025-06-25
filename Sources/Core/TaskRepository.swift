import Foundation
import Collections

// MARK: - Task Repository Protocol
@MainActor
public protocol TaskRepositoryProtocol: Sendable {
    func loadTasks() async throws -> [TaskItem]
    func saveTask(_ task: TaskItem) async throws
    func updateTask(_ task: TaskItem) async throws
    func deleteTask(id: UUID) async throws
    func searchTasks(filter: TaskFilter) async throws -> [TaskItem]
}

// MARK: - Repository Errors
public enum TaskRepositoryError: LocalizedError, Equatable {
    case taskNotFound(UUID)
    case duplicateTask(UUID)
    case invalidTaskData(String)
    case storageError(String)
    case networkError(String)
    
    public var errorDescription: String? {
        switch self {
        case .taskNotFound(let id):
            return "Task with ID \(id) not found"
        case .duplicateTask(let id):
            return "Task with ID \(id) already exists"
        case .invalidTaskData(let message):
            return "Invalid task data: \(message)"
        case .storageError(let message):
            return "Storage error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - In-Memory Task Repository
@MainActor
public final class InMemoryTaskRepository: TaskRepositoryProtocol {
    private var tasks: [TaskItem] = []
    
    public init() {}
    
    public func loadTasks() async throws -> [TaskItem] {
        return tasks
    }
    
    public func saveTask(_ task: TaskItem) async throws {
        tasks.append(task)
    }
    
    public func updateTask(_ task: TaskItem) async throws {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            throw TaskRepositoryError.taskNotFound(task.id)
        }
    }
    
    public func deleteTask(id: UUID) async throws {
        tasks.removeAll { $0.id == id }
    }
    
    public func searchTasks(filter: TaskFilter) async throws -> [TaskItem] {
        return tasks.filter { filter.matches($0) }
    }
}

// MARK: - File-Based Task Repository
@MainActor
public final class FileTaskRepository: TaskRepositoryProtocol {
    private let fileURL: URL
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public convenience init(filename: String = "tasks.json") {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        self.init(fileURL: fileURL)
    }
    
    public func loadTasks() async throws -> [TaskItem] {
        do {
            let data = try Data(contentsOf: fileURL)
            let tasks = try JSONDecoder().decode([TaskItem].self, from: data)
            return tasks
        } catch {
            // If file doesn't exist or is empty, return empty array
            return []
        }
    }
    
    public func saveTask(_ task: TaskItem) async throws {
        var tasks = try await loadTasks()
        tasks.append(task)
        try saveTasks(tasks)
    }
    
    public func updateTask(_ task: TaskItem) async throws {
        var tasks = try await loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            try saveTasks(tasks)
        } else {
            throw TaskRepositoryError.taskNotFound(task.id)
        }
    }
    
    public func deleteTask(id: UUID) async throws {
        var tasks = try await loadTasks()
        tasks.removeAll { $0.id == id }
        try saveTasks(tasks)
    }
    
    public func searchTasks(filter: TaskFilter) async throws -> [TaskItem] {
        let tasks = try await loadTasks()
        return tasks.filter { filter.matches($0) }
    }
    
    // MARK: - Private Methods
    private func saveTasks(_ tasks: [TaskItem]) throws {
        let data = try JSONEncoder().encode(tasks)
        try data.write(to: fileURL)
    }
} 