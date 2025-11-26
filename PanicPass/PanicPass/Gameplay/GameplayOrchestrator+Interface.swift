//
//  GameplayOrchestrator+Interface.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

extension GameplayOrchestrator {
    
    func configureInterface() {
        // Background
        backgroundIllustration = UIImageView()
        backgroundIllustration.image = UIImage(named: "passPhoto")
        backgroundIllustration.contentMode = .scaleAspectFill
        backgroundIllustration.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundIllustration)
        
        // Dimmer with gradient
        dimmerOverlay = UIView()
        dimmerOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        dimmerOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmerOverlay)
        
        // Add gradient overlay
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.view.bounds
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.4).cgColor,
                UIColor.black.withAlphaComponent(0.65).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
            self.dimmerOverlay.layer.addSublayer(gradientLayer)
        }
        
        // Retreat button
        retreatButton = fabricateRetreatButton()
        retreatButton.addTarget(self, action: #selector(executeRetreat), for: .touchUpInside)
        view.addSubview(retreatButton)
        
        // Accomplishment label
        accomplishmentLabel = UILabel()
        accomplishmentLabel.text = "SCORE: 0"
        accomplishmentLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        accomplishmentLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        accomplishmentLabel.textAlignment = .right
        accomplishmentLabel.layer.shadowColor = UIColor.black.cgColor
        accomplishmentLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        accomplishmentLabel.layer.shadowRadius = 4
        accomplishmentLabel.layer.shadowOpacity = 0.6
        accomplishmentLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(accomplishmentLabel)
        
        // Chronometer
        chronometer = UILabel()
        chronometer.text = "TIME: 00:00"
        chronometer.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        chronometer.textColor = UIColor.white.withAlphaComponent(0.9)
        chronometer.textAlignment = .right
        chronometer.layer.shadowColor = UIColor.black.cgColor
        chronometer.layer.shadowOffset = CGSize(width: 0, height: 1)
        chronometer.layer.shadowRadius = 3
        chronometer.layer.shadowOpacity = 0.5
        chronometer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chronometer)
        
        // Mode indicator
        modeIndicator = UILabel()
        modeIndicator.text = "CLASSIC"
        modeIndicator.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        modeIndicator.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        modeIndicator.textAlignment = .center
        modeIndicator.layer.shadowColor = UIColor.black.cgColor
        modeIndicator.layer.shadowOffset = CGSize(width: 0, height: 1)
        modeIndicator.layer.shadowRadius = 3
        modeIndicator.layer.shadowOpacity = 0.5
        modeIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeIndicator)
        
        // Upper slot container
        upperSlotContainer = UIView()
        upperSlotContainer.backgroundColor = .clear
        upperSlotContainer.clipsToBounds = true
        upperSlotContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upperSlotContainer)
        
        // Lower tile container - 使用自定义ScrollView
        lowerTileContainer = CustomScrollView()
        lowerTileContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        lowerTileContainer.layer.cornerRadius = 18
        lowerTileContainer.layer.borderWidth = 2
        lowerTileContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        lowerTileContainer.showsHorizontalScrollIndicator = false
        lowerTileContainer.showsVerticalScrollIndicator = true
        lowerTileContainer.indicatorStyle = .white
        lowerTileContainer.isScrollEnabled = true
        lowerTileContainer.isUserInteractionEnabled = true
        lowerTileContainer.bounces = true
        lowerTileContainer.alwaysBounceVertical = true
        lowerTileContainer.clipsToBounds = true
        lowerTileContainer.layer.shadowColor = UIColor.black.cgColor
        lowerTileContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        lowerTileContainer.layer.shadowRadius = 8
        lowerTileContainer.layer.shadowOpacity = 0.5
        lowerTileContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lowerTileContainer)
        
        // Tile palette - 使用frame布局
        tilePalette = UIView()
        tilePalette.isUserInteractionEnabled = true
        tilePalette.backgroundColor = .clear
        tilePalette.translatesAutoresizingMaskIntoConstraints = true
        lowerTileContainer.addSubview(tilePalette)
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
        let slotContainerHeight: CGFloat = isCompactDevice ? 100 : 140
        // 计算能容纳5行麻将的高度：5行 * (48 * 1.4 + 6间距) + 上下间距
        let tileContainerHeight: CGFloat = isCompactDevice ? 390 : 480
        
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
            
            // Accomplishment
            accomplishmentLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            accomplishmentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Chronometer
            chronometer.topAnchor.constraint(equalTo: accomplishmentLabel.bottomAnchor, constant: 8),
            chronometer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Mode indicator
            modeIndicator.topAnchor.constraint(equalTo: retreatButton.topAnchor),
            modeIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Upper slot container - 向下移动30
            upperSlotContainer.topAnchor.constraint(equalTo: modeIndicator.bottomAnchor, constant: 45),
            upperSlotContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upperSlotContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upperSlotContainer.heightAnchor.constraint(equalToConstant: slotContainerHeight),
            
            // Lower tile container
            lowerTileContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            lowerTileContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lowerTileContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lowerTileContainer.heightAnchor.constraint(equalToConstant: tileContainerHeight),
            
            // Tile palette
            tilePalette.topAnchor.constraint(equalTo: lowerTileContainer.topAnchor, constant: 10),
            tilePalette.leadingAnchor.constraint(equalTo: lowerTileContainer.leadingAnchor, constant: 10),
            tilePalette.bottomAnchor.constraint(equalTo: lowerTileContainer.bottomAnchor, constant: -10),
            tilePalette.heightAnchor.constraint(equalTo: lowerTileContainer.heightAnchor, constant: -20)
        ])
    }
    
    @objc func executeRetreat() {
        presentConfirmationDialog()
    }
    
    func presentConfirmationDialog() {
        let alert = UIAlertController(
            title: "Save & Exit?",
            message: "Your game will be saved to records.\n\nCurrent Score: \(currentAccomplishment)\nTime Played: \(formatTime(elapsedDuration))",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue Playing", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save & Exit", style: .default) { _ in
            // 保存游戏记录
            self.saveGameRecord()
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    func saveGameRecord() {
        // 只保存有分数的游戏，且只保存一次
        if currentAccomplishment > 0 && !hasRecordSaved {
            let modeName = gameMode == .classic ? "Classic" : "Speed Rush"
            let archive = GameArchive(accomplishment: currentAccomplishment, duration: elapsedDuration, modeName: modeName)
            ArchiveKeeper.shared.preserveArchive(archive)
            hasRecordSaved = true
        }
    }
    
    func formatTime(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

