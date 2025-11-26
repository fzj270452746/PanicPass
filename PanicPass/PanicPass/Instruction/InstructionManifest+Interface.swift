//
//  InstructionManifest+Interface.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

extension InstructionManifest {
    
    func configureInterface() {
        // Background
        backgroundIllustration = UIImageView()
        backgroundIllustration.image = UIImage(named: "passPhoto")
        backgroundIllustration.contentMode = .scaleAspectFill
        backgroundIllustration.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundIllustration)
        
        // Dimmer with gradient
        dimmerOverlay = UIView()
        dimmerOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmerOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmerOverlay)
        
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.view.bounds
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.35).cgColor,
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
        titleEmblem.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        titleEmblem.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleEmblem.textAlignment = .center
        titleEmblem.layer.shadowColor = UIColor.black.cgColor
        titleEmblem.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleEmblem.layer.shadowRadius = 4
        titleEmblem.layer.shadowOpacity = 0.6
        titleEmblem.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleEmblem)
        
        // Scroll container
        scrollContainer = UIScrollView()
        scrollContainer.backgroundColor = .clear
        scrollContainer.showsVerticalScrollIndicator = true
        scrollContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollContainer)
        
        // Content vessel
        contentVessel = UIView()
        contentVessel.translatesAutoresizingMaskIntoConstraints = false
        scrollContainer.addSubview(contentVessel)
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
            titleEmblem.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleEmblem.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Scroll container - 向下移动30
            scrollContainer.topAnchor.constraint(equalTo: titleEmblem.bottomAnchor, constant: 50),
            scrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Content vessel
            contentVessel.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
            contentVessel.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor),
            contentVessel.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor),
            contentVessel.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor),
            contentVessel.widthAnchor.constraint(equalTo: scrollContainer.widthAnchor)
        ])
    }
    
    func populateInstructions() {
        let instructions = [
            ("Game quest", "Match mahjong tiles with the numbers in the moving slots!"),
            ("How to Play", "• Slots move from right to left at the top\n• Each slot shows a number (1-9)\n• Tap the matching mahjong tile from the bottom\n• The highlighted slot is your current target"),
            ("Scoring", "• Each correct match: 10 points\n• Wrong selections flash red\n• Speed increases every 30 seconds"),
            
        ]
        
        var previousView: UIView? = nil
        
        for (index, (title, description)) in instructions.enumerated() {
            let sectionView = fabricateInstructionSection(title: title, description: description)
            sectionView.translatesAutoresizingMaskIntoConstraints = false
            contentVessel.addSubview(sectionView)
            
            NSLayoutConstraint.activate([
                sectionView.leadingAnchor.constraint(equalTo: contentVessel.leadingAnchor),
                sectionView.trailingAnchor.constraint(equalTo: contentVessel.trailingAnchor)
            ])
            
            if let previous = previousView {
                sectionView.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
            } else {
                sectionView.topAnchor.constraint(equalTo: contentVessel.topAnchor, constant: 10).isActive = true
            }
            
            previousView = sectionView
            
            if index == instructions.count - 1 {
                sectionView.bottomAnchor.constraint(equalTo: contentVessel.bottomAnchor, constant: -20).isActive = true
            }
        }
    }
    
    func fabricateInstructionSection(title: String, description: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1.5
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOpacity = 0.3
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15)
        ])
        
        return containerView
    }
    
    @objc func executeRetreat() {
        dismiss(animated: true)
    }
}

