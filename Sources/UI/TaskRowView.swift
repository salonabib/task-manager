import SwiftUI
import TaskManagerCore

public struct TaskRowView: View {
    let task: TaskItem
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onStartTimer: () -> Void
    let onStopTimer: () -> Void
    let onResetTimer: () -> Void
    
    @State private var showingDeleteAlert = false
    @State private var showingTimerMenu = false
    
    public init(
        task: TaskItem,
        onToggleCompletion: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onStartTimer: @escaping () -> Void,
        onStopTimer: @escaping () -> Void,
        onResetTimer: @escaping () -> Void
    ) {
        self.task = task
        self.onToggleCompletion = onToggleCompletion
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onStartTimer = onStartTimer
        self.onStopTimer = onStopTimer
        self.onResetTimer = onResetTimer
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    Spacer()
                    
                    // Priority indicator
                    Image(systemName: task.priority.icon)
                        .foregroundColor(task.priority.color)
                        .font(.caption)
                }
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    // Status badge
                    StatusBadge(status: task.status)
                    
                    // Due date
                    if let dueDate = task.dueDate {
                        DueDateView(dueDate: dueDate, isCompleted: task.isCompleted)
                    }
                    
                    // Time tracking
                    TimeTrackingView(
                        task: task,
                        onStartTimer: onStartTimer,
                        onStopTimer: onStopTimer,
                        onResetTimer: onResetTimer
                    )
                    
                    // Tags
                    if !task.tags.isEmpty {
                        TagsView(tags: Array(task.tags))
                    }
                    
                    Spacer()
                }
            }
            
            // Action buttons
            HStack(spacing: 8) {
                // Timer button
                Button(action: {
                    if task.isTimerRunning {
                        onStopTimer()
                    } else {
                        onStartTimer()
                    }
                }) {
                    Image(systemName: task.isTimerRunning ? "stop.circle.fill" : "play.circle")
                        .foregroundColor(task.isTimerRunning ? .red : .green)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete '\(task.title)'? This action cannot be undone.")
        }
    }
}

// MARK: - Supporting Views
private struct StatusBadge: View {
    let status: TaskStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(status.color.opacity(0.2))
        )
        .foregroundColor(status.color)
    }
}

private struct DueDateView: View {
    let dueDate: Date
    let isCompleted: Bool
    
    private var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
    
    private var timeRemaining: String {
        let calendar = Calendar.current
        let now = Date()
        
        if isOverdue {
            let days = calendar.dateComponents([.day], from: dueDate, to: now).day ?? 0
            return "\(days) day\(days == 1 ? "" : "s") overdue"
        } else {
            let days = calendar.dateComponents([.day], from: now, to: dueDate).day ?? 0
            if days == 0 {
                return "Due today"
            } else if days == 1 {
                return "Due tomorrow"
            } else {
                return "Due in \(days) days"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption2)
            Text(timeRemaining)
                .font(.caption)
        }
        .foregroundColor(isOverdue ? .red : .secondary)
    }
}

private struct TimeTrackingView: View {
    let task: TaskItem
    let onStartTimer: () -> Void
    let onStopTimer: () -> Void
    let onResetTimer: () -> Void
    
    @State private var showingTimerMenu = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption2)
            
            Text(task.formattedTimeSpent)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(task.isTimerRunning ? .green : .secondary)
                .monospacedDigit()
            
            if task.currentTimeSpent > 0 {
                Button(action: { showingTimerMenu = true }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $showingTimerMenu) {
                    VStack(spacing: 8) {
                        Text("Time Tracking")
                            .font(.headline)
                        
                        Text("Total time: \(task.formattedTimeSpent)")
                            .font(.subheadline)
                        
                        HStack(spacing: 12) {
                            Button("Reset") {
                                onResetTimer()
                                showingTimerMenu = false
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Cancel") {
                                showingTimerMenu = false
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .frame(width: 200)
                }
            }
        }
    }
}

private struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                }
                
                if tags.count > 3 {
                    Text("+\(tags.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
} 