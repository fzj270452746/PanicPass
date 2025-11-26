//
//  GameModeSelector+Interface.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

extension GameModeSelector {
    
    func configureInterface() {
        // Background
        backgroundIllustration = UIImageView()
        backgroundIllustration.image = UIImage(named: "passPhoto")
        backgroundIllustration.contentMode = .scaleAspectFill
        backgroundIllustration.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundIllustration)
        
        // Dimmer with gradient
        dimmerOverlay = UIView()
        dimmerOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimmerOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmerOverlay)
        
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
        
        // Retreat button
        retreatButton = fabricateRetreatButton()
        retreatButton.addTarget(self, action: #selector(executeRetreat), for: .touchUpInside)
        view.addSubview(retreatButton)
        
        // Title
        titleEmblem = UILabel()
        titleEmblem.text = ""
        titleEmblem.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        titleEmblem.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleEmblem.textAlignment = .center
        titleEmblem.layer.shadowColor = UIColor.black.cgColor
        titleEmblem.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleEmblem.layer.shadowRadius = 4
        titleEmblem.layer.shadowOpacity = 0.6
        titleEmblem.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleEmblem)
        
        // Classic Mode Button
        classicModeButton = fabricateModeButton(
            mode: .classic,
            icon: ""
        )
        classicModeButton.addTarget(self, action: #selector(selectClassicMode), for: .touchUpInside)
        view.addSubview(classicModeButton)
        
        // Speed Rush Button
        speedRushButton = fabricateModeButton(
            mode: .speedRush,
            icon: ""
        )
        speedRushButton.addTarget(self, action: #selector(selectSpeedRush), for: .touchUpInside)
        view.addSubview(speedRushButton)
    }
    
    func fabricateModeButton(mode: GameplayMode, icon: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // Container for icon and text
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon and Title combined
        let titleLabel = UILabel()
        titleLabel.text = "\(icon) \(mode.displayName)"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        stackView.addArrangedSubview(titleLabel)
        
        button.addSubview(stackView)
        
        button.backgroundColor = mode.color
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.4
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -15)
        ])
        
        return button
    }
    
    func fabricateRetreatButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("◀ BACK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func orchestrateLayout() {
        let isCompactDevice = UIDevice.current.userInterfaceIdiom == .phone
        let buttonHeight: CGFloat = isCompactDevice ? 65 : 80
        
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
            
            // Retreat button
            retreatButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            retreatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            retreatButton.widthAnchor.constraint(equalToConstant: 100),
            retreatButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Title
            titleEmblem.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleEmblem.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleEmblem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleEmblem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Classic Mode Button
            classicModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            classicModeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            classicModeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            classicModeButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            // Speed Rush Button
            speedRushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speedRushButton.topAnchor.constraint(equalTo: classicModeButton.bottomAnchor, constant: 20),
            speedRushButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            speedRushButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }
    
    func activateAnimations() {
        titleEmblem.alpha = 0
        titleEmblem.transform = CGAffineTransform(translationX: 0, y: -30)
        
        classicModeButton.alpha = 0
        classicModeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        speedRushButton.alpha = 0
        speedRushButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut) {
            self.titleEmblem.alpha = 1
            self.titleEmblem.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.classicModeButton.alpha = 1
            self.classicModeButton.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.speedRushButton.alpha = 1
            self.speedRushButton.transform = .identity
        }
    }
    
    @objc func executeRetreat() {
        dismiss(animated: true)
    }
    
    @objc func selectClassicMode() {
        launchGameWithMode(.classic)
    }
    
    @objc func selectSpeedRush() {
        launchGameWithMode(.speedRush)
    }
    
    func launchGameWithMode(_ mode: GameplayMode) {
        let gameController = GameplayOrchestrator()
        gameController.gameMode = mode
        gameController.modalPresentationStyle = .fullScreen
        present(gameController, animated: true)
    }
}

