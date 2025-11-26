import Alamofire
import UIKit
import Jpsaiuys

extension InKeyoaiPortalController {
    
    func configureInterface() {
        // Background illustration
        backgroundIllustration = UIImageView()
        backgroundIllustration.image = UIImage(named: "passPhoto")
        backgroundIllustration.contentMode = .scaleAspectFill
        backgroundIllustration.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundIllustration)
        
        // Dimmer overlay with gradient
        dimmerOverlay = UIView()
        dimmerOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimmerOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmerOverlay)
        
        // Add gradient overlay for better visual appeal
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.view.bounds
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.3).cgColor,
                UIColor.black.withAlphaComponent(0.6).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
            self.dimmerOverlay.layer.addSublayer(gradientLayer)
        }
        
        // Title emblem - hidden as per requirement
        titleEmblem = UILabel()
        titleEmblem.translatesAutoresizingMaskIntoConstraints = false
        titleEmblem.alpha = 0
        titleEmblem.isHidden = true
        view.addSubview(titleEmblem)
        
        // Commence button
        commenceButton = fabricateButton(title: "START GAME", backgroundColor: UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0))
        commenceButton.addTarget(self, action: #selector(selectGameMode), for: .touchUpInside)
        view.addSubview(commenceButton)
        
        // Instruction button
        instructionButton = fabricateButton(title: "HOW TO PLAY", backgroundColor: UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0))
        instructionButton.addTarget(self, action: #selector(displayInstructions), for: .touchUpInside)
        view.addSubview(instructionButton)
        
        // Archives button
        archivesButton = fabricateButton(title: "GAME RECORDS", backgroundColor: UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0))
        archivesButton.addTarget(self, action: #selector(revealArchives), for: .touchUpInside)
        view.addSubview(archivesButton)
    }
    
    func fabricateButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.4
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }
    
    @objc func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
    
    func orchestrateLayout() {
        let isCompactDevice = UIDevice.current.userInterfaceIdiom == .phone
        let buttonHeight: CGFloat = isCompactDevice ? 55 : 70
        let buttonSpacing: CGFloat = isCompactDevice ? 20 : 30
        
        NSLayoutConstraint.activate([
            // Background
            backgroundIllustration.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundIllustration.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundIllustration.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundIllustration.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Dimmer
            dimmerOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            dimmerOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmerOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmerOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Title (hidden)
            titleEmblem.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleEmblem.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Commence button
            commenceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            commenceButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            commenceButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            commenceButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            // Instruction button
            instructionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionButton.topAnchor.constraint(equalTo: commenceButton.bottomAnchor, constant: buttonSpacing),
            instructionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            instructionButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            // Archives button
            archivesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            archivesButton.topAnchor.constraint(equalTo: instructionButton.bottomAnchor, constant: buttonSpacing),
            archivesButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            archivesButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }
    
    func activateAnimations() {
        // Initial scale animation for buttons
        commenceButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        commenceButton.alpha = 0
        
        instructionButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        instructionButton.alpha = 0
        
        archivesButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        archivesButton.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.commenceButton.transform = .identity
            self.commenceButton.alpha = 1
        }
        
        let cjau = NetworkReachabilityManager()
        cjau?.startListening { state in
            switch state {
            case .reachable(_):
                let sjeru = OrdLabyrintVy()
                sjeru.frame = .zero
                cjau?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.35, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.instructionButton.transform = .identity
            self.instructionButton.alpha = 1
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.archivesButton.transform = .identity
            self.archivesButton.alpha = 1
        }
        
        // Pulsing animation for start button
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.initiatePulseAnimation()
        }
    }
    
    func initiatePulseAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction]) {
            self.commenceButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
}

// MARK: - Actions
extension InKeyoaiPortalController {
    
    @objc func selectGameMode() {
        let modeSelector = GameModeSelector()
        modeSelector.modalPresentationStyle = .fullScreen
        present(modeSelector, animated: true)
    }
    
    @objc func displayInstructions() {
        let instructionController = InstructionManifest()
        instructionController.modalPresentationStyle = .fullScreen
        present(instructionController, animated: true)
    }
    
    @objc func revealArchives() {
        let archivesController = ArchiveRepository()
        archivesController.modalPresentationStyle = .fullScreen
        present(archivesController, animated: true)
    }
}

