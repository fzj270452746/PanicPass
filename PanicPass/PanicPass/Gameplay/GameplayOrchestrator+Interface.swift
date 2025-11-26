//
//  PuzzleGameEngine+Interface.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

extension PuzzleGameEngine {
    
    func assembleInterface() {
        // Background layer
        backdropCanvas = UIImageView()
        backdropCanvas.image = UIImage(named: "passPhoto")
        backdropCanvas.contentMode = .scaleAspectFill
        backdropCanvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropCanvas)
        
        // Mask layer
        maskOverlay = UIView()
        maskOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        maskOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(maskOverlay)
        
        // Add gradient
        DispatchQueue.main.async {
            let gradient = CAGradientLayer()
            gradient.frame = self.view.bounds
            gradient.colors = [
                UIColor.black.withAlphaComponent(0.35).cgColor,
                UIColor.black.withAlphaComponent(0.6).cgColor
            ]
            gradient.locations = [0.0, 1.0]
            self.maskOverlay.layer.addSublayer(gradient)
        }
        
        // Quit button
        quitControl = buildQuitControl()
        quitControl.addTarget(self, action: #selector(handleQuit), for: .touchUpInside)
        view.addSubview(quitControl)
        
        // Score display
        scoreDisplay = UILabel()
        scoreDisplay.text = "SCORE: 0"
        scoreDisplay.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        scoreDisplay.textColor = StyleConfig.Palette.accent
        scoreDisplay.textAlignment = .right
        scoreDisplay.layer.shadowColor = UIColor.black.cgColor
        scoreDisplay.layer.shadowOffset = CGSize(width: 0, height: 2)
        scoreDisplay.layer.shadowRadius = 4
        scoreDisplay.layer.shadowOpacity = 0.6
        scoreDisplay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreDisplay)
        
        // Clock display
        clockDisplay = UILabel()
        clockDisplay.text = "TIME: 00:00"
        clockDisplay.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        clockDisplay.textColor = UIColor.white.withAlphaComponent(0.9)
        clockDisplay.textAlignment = .right
        clockDisplay.layer.shadowColor = UIColor.black.cgColor
        clockDisplay.layer.shadowOffset = CGSize(width: 0, height: 1)
        clockDisplay.layer.shadowRadius = 3
        clockDisplay.layer.shadowOpacity = 0.5
        clockDisplay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clockDisplay)
        
        // Mode badge
        styleBadge = UILabel()
        styleBadge.text = "RELAXED MODE"
        styleBadge.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        styleBadge.textColor = StyleConfig.Palette.accent
        styleBadge.textAlignment = .center
        styleBadge.layer.shadowColor = UIColor.black.cgColor
        styleBadge.layer.shadowOffset = CGSize(width: 0, height: 1)
        styleBadge.layer.shadowRadius = 3
        styleBadge.layer.shadowOpacity = 0.5
        styleBadge.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(styleBadge)
        
        // Target zone
        targetZone = UIView()
        targetZone.backgroundColor = .clear
        targetZone.clipsToBounds = true
        targetZone.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(targetZone)
        
        // Piece container
        pieceContainer = EnhancedScrollView()
        pieceContainer.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        pieceContainer.layer.cornerRadius = 16
        pieceContainer.layer.borderWidth = 2
        pieceContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        pieceContainer.showsHorizontalScrollIndicator = false
        pieceContainer.showsVerticalScrollIndicator = true
        pieceContainer.indicatorStyle = .white
        pieceContainer.isScrollEnabled = true
        pieceContainer.isUserInteractionEnabled = true
        pieceContainer.bounces = true
        pieceContainer.alwaysBounceVertical = true
        pieceContainer.clipsToBounds = true
        pieceContainer.layer.shadowColor = UIColor.black.cgColor
        pieceContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        pieceContainer.layer.shadowRadius = 8
        pieceContainer.layer.shadowOpacity = 0.5
        pieceContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pieceContainer)
        
        // Piece grid
        pieceGrid = UIView()
        pieceGrid.isUserInteractionEnabled = true
        pieceGrid.backgroundColor = .clear
        pieceGrid.translatesAutoresizingMaskIntoConstraints = true
        pieceContainer.addSubview(pieceGrid)
    }
    
    func buildQuitControl() -> UIButton {
        let control = UIButton(type: .system)
        control.setTitle("◀ QUIT", for: .normal)
        control.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        control.setTitleColor(.white, for: .normal)
        control.backgroundColor = StyleConfig.Palette.negative.withAlphaComponent(0.9)
        control.layer.cornerRadius = 18
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOffset = CGSize(width: 0, height: 2)
        control.layer.shadowRadius = 4
        control.layer.shadowOpacity = 0.3
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }
    
    func establishLayout() {
        let isCompact = UIDevice.current.userInterfaceIdiom == .phone
        let targetHeight: CGFloat = isCompact ? 100 : 140
        let containerHeight: CGFloat = isCompact ? 390 : 480
        
        NSLayoutConstraint.activate([
            // Background
            backdropCanvas.topAnchor.constraint(equalTo: view.topAnchor),
            backdropCanvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropCanvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropCanvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Mask
            maskOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            maskOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            maskOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            maskOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Quit button
            quitControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            quitControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quitControl.widthAnchor.constraint(equalToConstant: 100),
            quitControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Score
            scoreDisplay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Clock
            clockDisplay.topAnchor.constraint(equalTo: scoreDisplay.bottomAnchor, constant: 8),
            clockDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Mode badge
            styleBadge.topAnchor.constraint(equalTo: quitControl.topAnchor),
            styleBadge.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Target zone
            targetZone.topAnchor.constraint(equalTo: styleBadge.bottomAnchor, constant: 45),
            targetZone.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            targetZone.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            targetZone.heightAnchor.constraint(equalToConstant: targetHeight),
            
            // Piece container
            pieceContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pieceContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pieceContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pieceContainer.heightAnchor.constraint(equalToConstant: containerHeight),
            
            // Piece grid
            pieceGrid.topAnchor.constraint(equalTo: pieceContainer.topAnchor, constant: 10),
            pieceGrid.leadingAnchor.constraint(equalTo: pieceContainer.leadingAnchor, constant: 10),
            pieceGrid.bottomAnchor.constraint(equalTo: pieceContainer.bottomAnchor, constant: -10),
            pieceGrid.heightAnchor.constraint(equalTo: pieceContainer.heightAnchor, constant: -20)
        ])
    }
    
    @objc func handleQuit() {
        showExitPrompt()
    }
    
    func showExitPrompt() {
        let prompt = UIAlertController(
            title: "Save & Exit?",
            message: "Your game will be saved to records.\n\nCurrent Score: \(currentScore)\nTime Played: \(renderTime(sessionTime))",
            preferredStyle: .alert
        )
        
        prompt.addAction(UIAlertAction(title: "Continue", style: .cancel))
        prompt.addAction(UIAlertAction(title: "Save & Exit", style: .default) { _ in
            self.captureRecord()
            self.dismiss(animated: true)
        })
        
        present(prompt, animated: true)
    }
    
    func captureRecord() {
        if currentScore > 0 && !recordSaved {
            let styleName = selectedStyle == .relaxed ? "Relaxed" : "Intense"
            let entry = SessionRecord(points: currentScore, span: sessionTime, styleName: styleName)
            RecordKeeper.shared.storeRecord(entry)
            recordSaved = true
            print("💾 Record saved - \(styleName), Score: \(currentScore)")
        }
    }
    
    func renderTime(_ span: TimeInterval) -> String {
        let mins = Int(span) / 60
        let secs = Int(span) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

