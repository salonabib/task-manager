import Cocoa

class ViewController: NSViewController {
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 300))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the title label
        let titleLabel = NSTextField(labelWithString: "Welcome to DemoApp!")
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.alignment = .center
        titleLabel.textColor = NSColor.labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create and configure the subtitle label
        let subtitleLabel = NSTextField(labelWithString: "This is a demo macOS application created with Swift Package Manager")
        subtitleLabel.font = NSFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.alignment = .center
        subtitleLabel.textColor = NSColor.secondaryLabelColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create and configure a demo button
        let demoButton = NSButton(title: "Tap Me!", target: self, action: #selector(buttonClicked))
        demoButton.bezelStyle = .rounded
        demoButton.font = NSFont.systemFont(ofSize: 18, weight: .medium)
        demoButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to the main view
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(demoButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Subtitle label constraints
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Demo button constraints
            demoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            demoButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            demoButton.widthAnchor.constraint(equalToConstant: 200),
            demoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func buttonClicked() {
        let alert = NSAlert()
        alert.messageText = "Button Clicked!"
        alert.informativeText = "Congratulations! Your demo app is working."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
