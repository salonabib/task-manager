import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view
        view.backgroundColor = UIColor.systemBackground
        
        // Create and configure the title label
        let titleLabel = UILabel()
        titleLabel.text = "Welcome to DemoApp!"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create and configure the subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "This is a demo iOS application created with Xcode command-line tools"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create and configure a demo button
        let demoButton = UIButton(type: .system)
        demoButton.setTitle("Tap Me!", for: .normal)
        demoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        demoButton.backgroundColor = UIColor.systemBlue
        demoButton.setTitleColor(UIColor.white, for: .normal)
        demoButton.layer.cornerRadius = 8
        demoButton.translatesAutoresizingMaskIntoConstraints = false
        demoButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Add views to the main view
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(demoButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Subtitle label constraints
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Demo button constraints
            demoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            demoButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            demoButton.widthAnchor.constraint(equalToConstant: 200),
            demoButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func buttonTapped() {
        let alert = UIAlertController(title: "Button Tapped!", 
                                    message: "Congratulations! Your demo app is working.", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
