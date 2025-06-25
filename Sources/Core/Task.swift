import Foundation
import SwiftUI

// MARK: - Task Item
public struct TaskItem: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let title: String
    public let description: String
    public let priority: TaskPriority
    public let status: TaskStatus
    public let dueDate: Date?
    public let tags: Set<String>
    public let createdAt: Date
    public let updatedAt: Date
    public let timeSpent: TimeInterval
    public let timerStartTime: Date?
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .pending,
        dueDate: Date? = nil,
        tags: Set<String> = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        timeSpent: TimeInterval = 0,
        timerStartTime: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.dueDate = dueDate
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.timeSpent = timeSpent
        self.timerStartTime = timerStartTime
    }
    
    // MARK: - Computed Properties
    public var isCompleted: Bool {
        status == .completed
    }
    
    public var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    public var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: dueDate).day
    }
    
    public var isTimerRunning: Bool {
        timerStartTime != nil
    }
    
    public var currentTimeSpent: TimeInterval {
        if let startTime = timerStartTime {
            return timeSpent + Date().timeIntervalSince(startTime)
        }
        return timeSpent
    }
    
    public var formattedTimeSpent: String {
        let totalSeconds = Int(currentTimeSpent)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    public var isNew: Bool {
        title.isEmpty
    }
    
    // MARK: - Time Tracking Methods
    public func startTimer() -> TaskItem {
        guard !isTimerRunning else { return self }
        return TaskItem(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            tags: tags,
            createdAt: createdAt,
            updatedAt: Date(),
            timeSpent: timeSpent,
            timerStartTime: Date()
        )
    }
    
    public func stopTimer() -> TaskItem {
        guard let startTime = timerStartTime else { return self }
        let additionalTime = Date().timeIntervalSince(startTime)
        return TaskItem(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            tags: tags,
            createdAt: createdAt,
            updatedAt: Date(),
            timeSpent: timeSpent + additionalTime,
            timerStartTime: nil
        )
    }
    
    public func resetTimer() -> TaskItem {
        return TaskItem(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            tags: tags,
            createdAt: createdAt,
            updatedAt: Date(),
            timeSpent: 0,
            timerStartTime: nil
        )
    }
}

// MARK: - Task Priority
public enum TaskPriority: Int, CaseIterable, Codable, Comparable, Sendable {
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4
    
    public static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    public var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high: return "arrow.up.circle"
        case .urgent: return "exclamationmark.triangle"
        }
    }
    
    public var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

// MARK: - Task Status
public enum TaskStatus: CaseIterable, Codable, Sendable {
    case pending
    case inProgress
    case completed
    case cancelled
    
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    public var icon: String {
        switch self {
        case .pending: return "clock"
        case .inProgress: return "play.circle"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
    
    public var color: Color {
        switch self {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - Task Filter
public struct TaskFilter: Sendable, Equatable {
    public let status: TaskStatus?
    public let priority: TaskPriority?
    public let searchText: String
    public let tags: Set<String>
    public let showCompleted: Bool
    
    public init(
        status: TaskStatus? = nil,
        priority: TaskPriority? = nil,
        searchText: String = "",
        tags: Set<String> = [],
        showCompleted: Bool = true
    ) {
        self.status = status
        self.priority = priority
        self.searchText = searchText
        self.tags = tags
        self.showCompleted = showCompleted
    }
    
    public func matches(_ task: TaskItem) -> Bool {
        // Status filter
        if let status = status, task.status != status {
            return false
        }
        
        // Priority filter
        if let priority = priority, task.priority != priority {
            return false
        }
        
        // Search text filter
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            let titleMatch = task.title.lowercased().contains(searchLower)
            let descriptionMatch = task.description.lowercased().contains(searchLower)
            if !titleMatch && !descriptionMatch {
                return false
            }
        }
        
        // Tags filter
        if !tags.isEmpty && !tags.isSubset(of: task.tags) {
            return false
        }
        
        // Completed filter
        if !showCompleted && task.isCompleted {
            return false
        }
        
        return true
    }
}

// MARK: - Color Extension
extension Color {
    static let orange = Color(red: 1.0, green: 0.5, blue: 0.0)
    static let red = Color(red: 1.0, green: 0.0, blue: 0.0)
    static let green = Color(red: 0.0, green: 1.0, blue: 0.0)
    static let blue = Color(red: 0.0, green: 0.0, blue: 1.0)
} 