# Task Manager

A modern, feature-rich task management application built with SwiftUI for macOS.

## Features

- **Task Management**: Create, edit, and delete tasks with rich metadata
- **Priority Levels**: Set task priority (Low, Medium, High, Urgent)
- **Status Tracking**: Track task status (Pending, In Progress, Completed, Cancelled)
- **Due Dates**: Set and track due dates with overdue notifications
- **Tags**: Organize tasks with custom tags
- **Time Tracking**: Built-in timer to track time spent on tasks
- **Search & Filter**: Advanced search and filtering capabilities
- **Modern UI**: Clean, native macOS interface built with SwiftUI

## Screenshots

*Screenshots will be added here*

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later (for development)
- Swift 6.0 or later

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/task-manager.git
   cd task-manager
   ```

2. Build the project:
   ```bash
   swift build
   ```

3. Run the application:
   ```bash
   swift run TaskManagerMac
   ```

### Alternative: Run from Executable

1. Build the project:
   ```bash
   swift build
   ```

2. Navigate to the build directory and run the executable:
   ```bash
   .build/debug/TaskManagerMac
   ```

## Project Structure

```
TaskManager/
├── Sources/
│   ├── Core/           # Business logic and data models
│   │   ├── Task.swift
│   │   ├── TaskManager.swift
│   │   └── TaskRepository.swift
│   ├── UI/             # SwiftUI views and components
│   │   ├── TaskFormView.swift
│   │   ├── TaskListView.swift
│   │   └── TaskRowView.swift
│   ├── CLI/            # Command line interface
│   │   └── main.swift
│   └── MacOS/          # macOS application entry point
│       └── main.swift
├── Tests/              # Unit tests
│   ├── TaskManagerCoreTests/
│   └── TaskManagerUITests/
├── Package.swift       # Swift Package Manager configuration
└── README.md
```

## Usage

### Creating Tasks

1. Click the "+" button in the main window
2. Fill in the task details:
   - **Title**: Required task name
   - **Description**: Optional detailed description
   - **Priority**: Choose from Low, Medium, High, or Urgent
   - **Status**: Set initial status (default: Pending)
   - **Due Date**: Optional due date and time
   - **Tags**: Comma-separated tags for organization
3. Click "Save" to create the task

### Editing Tasks

1. Click the pencil icon on any task row
2. Modify the task details as needed
3. Click "Save" to update the task

### Time Tracking

- Click the play button to start timing a task
- Click the stop button to pause timing
- The timer will show elapsed time in the task row

### Search and Filter

- Use the search bar to find tasks by title or description
- Click the filter button to set advanced filters:
  - Status filter
  - Priority filter
  - Tag filter
  - Show/hide completed tasks

## Development

### Building for Development

```bash
swift build
```

### Running Tests

```bash
swift test
```

### Code Style

This project follows Swift style guidelines and uses SwiftLint for code formatting.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and Swift Package Manager
- Icons from SF Symbols
- Inspired by modern task management applications

## Roadmap

- [ ] Cloud synchronization
- [ ] iOS companion app
- [ ] Export/import functionality
- [ ] Custom themes
- [ ] Keyboard shortcuts
- [ ] Widget support
