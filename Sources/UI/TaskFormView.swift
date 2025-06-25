import SwiftUI
import TaskManagerCore
import AppKit

public struct TaskFormView: View {
    @Binding var task: TaskItem
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var status: TaskStatus
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    @State private var tags: String
    @State private var validationErrors: [String] = []
    @State private var showingValidationAlert = false
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case title, description, tags
    }
    
    public init(
        task: Binding<TaskItem>,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._task = task
        self.onSave = onSave
        self.onCancel = onCancel
        
        // Initialize state from task
        self._title = State(initialValue: task.wrappedValue.title)
        self._description = State(initialValue: task.wrappedValue.description)
        self._priority = State(initialValue: task.wrappedValue.priority)
        self._status = State(initialValue: task.wrappedValue.status)
        self._dueDate = State(initialValue: task.wrappedValue.dueDate)
        self._hasDueDate = State(initialValue: task.wrappedValue.dueDate != nil)
        self._tags = State(initialValue: Array(task.wrappedValue.tags).joined(separator: ", "))
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(task.isNew ? "New Task" : "Edit Task")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    onCancel()
                }
                
                Button("Save") {
                    saveTask()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Form Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .fontWeight(.medium)
                        TextField("Enter task title", text: $title)
                            .foregroundColor(.black)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .title)
                    }
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.medium)
                        TextField("Enter description", text: $description, axis: .vertical)
                            .foregroundColor(.black)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .lineLimit(4...8)
                    }
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .fontWeight(.medium)
                        TextField("Enter tags (comma-separated)", text: $tags)
                            .foregroundColor(.black)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    
                    // Priority and Status
                    HStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.headline)
                                .fontWeight(.medium)
                            Picker("Priority", selection: $priority) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Text(priority.displayName).tag(priority)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.headline)
                                .fontWeight(.medium)
                            Picker("Status", selection: $status) {
                                ForEach(TaskStatus.allCases, id: \.self) { status in
                                    Text(status.displayName).tag(status)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        
                        Spacer()
                    }
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Set Due Date", isOn: $hasDueDate)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        if hasDueDate {
                            DatePicker(
                                "Due Date",
                                selection: Binding(
                                    get: { dueDate ?? Date() },
                                    set: { dueDate = $0 }
                                ),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.leading, 20)
                        }
                    }
                }
                .padding(24)
            }
        }
        .frame(minWidth: 600, idealWidth: 700, minHeight: 700, idealHeight: 800)
        .onAppear {
            // Set focus to title field when form appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = .title
            }
        }
        .onChange(of: title) { _ in validateForm() }
        .onChange(of: description) { _ in validateForm() }
        .onChange(of: hasDueDate) { newValue in
            if !newValue {
                dueDate = nil
            }
        }
        .alert("Validation Error", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationErrors.joined(separator: "\n"))
        }
    }
    
    // MARK: - Private Methods
    private func validateForm() {
        var errors: [String] = []
        
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Task title cannot be empty")
        }
        
        if title.count > 100 {
            errors.append("Task title cannot exceed 100 characters")
        }
        
        if description.count > 1000 {
            errors.append("Task description cannot exceed 1000 characters")
        }
        
        if hasDueDate, let dueDate = dueDate, dueDate < Date() {
            errors.append("Due date cannot be in the past")
        }
        
        validationErrors = errors
    }
    
    private func parseTags() -> [String] {
        return tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private func saveTask() {
        validateForm()
        
        if !validationErrors.isEmpty {
            showingValidationAlert = true
            return
        }
        
        // Update the task with form values
        task = TaskItem(
            id: task.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            status: status,
            dueDate: hasDueDate ? dueDate : nil,
            tags: Set(parseTags()),
            createdAt: task.createdAt,
            updatedAt: Date()
        )
        
        onSave()
    }
}

// MARK: - Supporting Views
private struct TagsPreviewView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Convenience Initializers
public extension TaskFormView {
    static func createTask(
        onSave: @escaping (TaskItem) -> Void,
        onCancel: @escaping () -> Void
    ) -> TaskFormView {
        let newTask = TaskItem(title: "")
        return TaskFormView(
            task: .constant(newTask),
            onSave: { onSave(newTask) },
            onCancel: onCancel
        )
    }
} 