//
//  PuzzleGameEngine+Logic.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

extension PuzzleGameEngine {
    
    func beginSession() {
        currentScore = 0
        sessionTime = 0
        focusedIndex = 0
        
        movementRate = selectedStyle.initialVelocity
        styleBadge.text = selectedStyle == .relaxed ? "RELAXED MODE" : "INTENSE MODE ⚡"
        
        updateScore()
        populateGrid()
        startClock()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startTargetFlow()
        }
    }
    
    func populateGrid() {
        pieceGrid.subviews.forEach { $0.removeFromSuperview() }
        activePieces = createBalancedSet(count: 30)
        
        let isCompact = UIDevice.current.userInterfaceIdiom == .phone
        let unitSize: CGFloat = isCompact ? 48 : 72
        let gap: CGFloat = 6
        let columns = isCompact ? 6 : 8
        
        for (idx, piece) in activePieces.enumerated() {
            let row = idx / columns
            let col = idx % columns
            
            let control = UIButton(type: .custom)
            control.tag = idx
            control.setImage(piece.visual, for: .normal)
            control.imageView?.contentMode = .scaleAspectFill
            control.layer.cornerRadius = 6
            control.clipsToBounds = true
            control.layer.borderWidth = 2.5
            control.layer.borderColor = StyleConfig.Palette.accent.withAlphaComponent(0.75).cgColor
            control.layer.shadowColor = UIColor.black.cgColor
            control.layer.shadowOffset = CGSize(width: 0, height: 2)
            control.layer.shadowRadius = 4
            control.layer.shadowOpacity = 0.4
            control.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            control.isUserInteractionEnabled = true
            control.isEnabled = true
            control.isExclusiveTouch = false
            control.addTarget(self, action: #selector(piecePressed(_:)), for: .touchDown)
            control.addTarget(self, action: #selector(pieceChosen(_:)), for: .touchUpInside)
            control.accessibilityIdentifier = "piece_\(piece.value)_\(idx)"
            
            let xPos = CGFloat(col) * (unitSize + gap) + gap / 2
            let yPos = CGFloat(row) * (unitSize * 1.4 + gap) + gap / 2
            control.frame = CGRect(x: xPos, y: yPos, width: unitSize, height: unitSize * 1.4)
            pieceGrid.addSubview(control)
            
            control.alpha = 0.3
            UIView.animate(withDuration: 0.3, delay: Double(idx) * 0.01, options: .allowUserInteraction) {
                control.alpha = 1
            }
        }
        
        let rows = (activePieces.count - 1) / columns + 1
        let gridWidth = CGFloat(columns) * (unitSize + gap) + gap
        let gridHeight = CGFloat(rows) * (unitSize * 1.4 + gap) + gap
        let containerWidth = pieceContainer.bounds.width
        let xShift = max((containerWidth - gridWidth) / 2, 0)
        
        pieceGrid.frame = CGRect(x: xShift, y: 0, width: gridWidth, height: gridHeight)
        pieceContainer.contentSize = pieceContainer.bounds.size
        pieceContainer.isScrollEnabled = false
        pieceContainer.showsVerticalScrollIndicator = false
    }
    
    @objc func piecePressed(_ control: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            control.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            control.alpha = 0.8
        }
    }
    
    @objc func pieceChosen(_ control: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .allowUserInteraction) {
            control.transform = .identity
            control.alpha = 1.0
        }
        
        guard control.tag < activePieces.count else { return }
        guard focusedIndex < targetList.count else { return }
        guard control.isEnabled else { return }
        
        let chosen = activePieces[control.tag]
        let target = targetList[focusedIndex]
        
        animateChoice(control)
        
        if chosen.value == target.neededValue {
            animateMatch(from: control, to: target, piece: chosen)
            triggerSuccess()
        } else {
            target.showMismatch()
            vibrateError()
            animateWrong(control)
        }
    }
    
    func animateChoice(_ control: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: [.allowUserInteraction, .curveEaseOut]) {
            control.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
                control.transform = .identity
            }
        }
    }
    
    func animateWrong(_ control: UIButton) {
        let savedTint = control.layer.borderColor
        UIView.animate(withDuration: 0.1, animations: {
            control.layer.borderColor = StyleConfig.Palette.negative.cgColor
            control.transform = CGAffineTransform(translationX: -10, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                control.transform = CGAffineTransform(translationX: 10, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    control.transform = .identity
                }) { _ in
                    UIView.animate(withDuration: 0.2) {
                        control.layer.borderColor = savedTint
                    }
                }
            }
        }
    }
    
    func triggerSuccess() {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
    }
    
    func animateMatch(from control: UIButton, to target: TargetSlot, piece: GamePiece) {
        let controlIdx = control.tag
        control.isEnabled = false
        
        let sprite = UIImageView(image: piece.visual)
        sprite.contentMode = .scaleAspectFill
        sprite.layer.cornerRadius = 6
        sprite.clipsToBounds = true
        sprite.layer.borderWidth = 2
        sprite.layer.borderColor = StyleConfig.Palette.accent.cgColor
        
        let origin = control.convert(control.bounds, to: view)
        sprite.frame = origin
        view.addSubview(sprite)
        
        let presentation = target.layer.presentation() ?? target.layer
        var dest = presentation.frame
        if let parent = target.superview {
            dest = parent.convert(dest, to: view)
        }
        let final = dest.insetBy(dx: 5, dy: 5)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            sprite.frame = final
            sprite.transform = CGAffineTransform(rotationAngle: .pi / 6)
        }) { _ in
            sprite.removeFromSuperview()
            target.completeWith(piece) {
                self.advanceFocus()
            }
            self.incrementScore()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
            control.alpha = 0
            control.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { _ in
            control.removeFromSuperview()
            self.replaceAtIndex(controlIdx)
        }
    }
    
    func advanceFocus() {
        if focusedIndex < targetList.count {
            targetList[focusedIndex].deactivateFocus()
        }
        focusedIndex += 1
        if focusedIndex < targetList.count {
            targetList[focusedIndex].activateFocus()
        }
    }
    
    func replaceAtIndex(_ idx: Int) {
        guard let fresh = PieceSource.shared.randomPieces(count: 1).first else { return }
        
        let isCompact = UIDevice.current.userInterfaceIdiom == .phone
        let unitSize: CGFloat = isCompact ? 48 : 72
        let gap: CGFloat = 6
        let columns = isCompact ? 6 : 8
        
        let row = idx / columns
        let col = idx % columns
        let xPos = CGFloat(col) * (unitSize + gap) + gap / 2
        let yPos = CGFloat(row) * (unitSize * 1.4 + gap) + gap / 2
        
        let control = UIButton(type: .custom)
        control.tag = idx
        control.setImage(fresh.visual, for: .normal)
        control.imageView?.contentMode = .scaleAspectFill
        control.layer.cornerRadius = 6
        control.clipsToBounds = true
        control.layer.borderWidth = 2.5
        control.layer.borderColor = StyleConfig.Palette.accent.withAlphaComponent(0.75).cgColor
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOffset = CGSize(width: 0, height: 2)
        control.layer.shadowRadius = 4
        control.layer.shadowOpacity = 0.4
        control.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        control.isUserInteractionEnabled = true
        control.isEnabled = true
        control.isExclusiveTouch = false
        control.addTarget(self, action: #selector(piecePressed(_:)), for: .touchDown)
        control.addTarget(self, action: #selector(pieceChosen(_:)), for: .touchUpInside)
        control.accessibilityIdentifier = "piece_\(fresh.value)_\(idx)"
        control.frame = CGRect(x: xPos, y: yPos, width: unitSize, height: unitSize * 1.4)
        control.transform = .identity
        
        if idx < activePieces.count {
            activePieces[idx] = fresh
        }
        pieceGrid.addSubview(control)
        
        control.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut]) {
            control.alpha = 1
        }
    }
    
    func startTargetFlow() {
        let spawnRate = selectedStyle.targetSpawnRate
        targetTimer = Timer.scheduledTimer(withTimeInterval: spawnRate, repeats: true) { [weak self] _ in
            self?.spawnTarget()
        }
        spawnTarget()
    }
    
    func spawnTarget() {
        let available = getAvailableValues()
        let value = available.isEmpty ? Int.random(in: 1...9) : (available.randomElement() ?? Int.random(in: 1...9))
        
        let target = TargetSlot(value: value)
        
        let isCompact = UIDevice.current.userInterfaceIdiom == .phone
        let targetWidth: CGFloat = isCompact ? 65 : 95
        let targetHeight: CGFloat = isCompact ? 85 : 125
        let zoneHeight = targetZone.bounds.height
        let yPos = max((zoneHeight - targetHeight) / 2, 0)
        let startX = view.bounds.width + 20
        
        target.frame = CGRect(x: startX, y: yPos, width: targetWidth, height: targetHeight)
        targetZone.addSubview(target)
        targetList.append(target)
        
        if targetList.count == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                target.activateFocus()
            }
        }
        
        slideTarget(target)
    }
    
    func getAvailableValues() -> [Int] {
        let enabled = pieceGrid.subviews.compactMap { $0 as? UIButton }.filter { $0.isEnabled }
        var values = Set<Int>()
        for button in enabled {
            if button.tag < activePieces.count {
                values.insert(activePieces[button.tag].value)
            }
        }
        return Array(values).sorted()
    }
    
    func slideTarget(_ target: TargetSlot) {
        let duration: TimeInterval = 20.0 / Double(movementRate)
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            target.frame.origin.x = -target.frame.width - 20
        }) { completed in
            if completed && !target.isMatched {
                self.handleMissed(target)
            }
            target.removeFromSuperview()
        }
    }
    
    func handleMissed(_ target: TargetSlot) {
        if let idx = targetList.firstIndex(of: target) {
            targetList.remove(at: idx)
            if idx < focusedIndex {
                focusedIndex -= 1
            } else if idx == focusedIndex {
                if focusedIndex < targetList.count {
                    targetList[focusedIndex].activateFocus()
                }
            }
        }
    }
    
    func startClock() {
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.sessionTime += 1
            self.updateClock()
            
            let accelPeriod = Int(self.selectedStyle.accelerationPeriod)
            if Int(self.sessionTime) % accelPeriod == 0 && self.movementRate < self.selectedStyle.velocityCap {
                let old = self.movementRate
                self.movementRate += self.selectedStyle.velocityIncrement
                self.movementRate = min(self.movementRate, self.selectedStyle.velocityCap)
                self.showSpeedBoost(from: old, to: self.movementRate)
            }
        }
    }
    
    func showSpeedBoost(from old: CGFloat, to new: CGFloat) {
        let factor = String(format: "%.1f", new / selectedStyle.initialVelocity)
        let notice = UILabel()
        notice.text = selectedStyle == .intense ? "🚀 SPEED x\(factor)!" : "⚡ FASTER!"
        notice.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        notice.textColor = StyleConfig.Palette.accent
        notice.textAlignment = .center
        notice.layer.shadowColor = UIColor.black.cgColor
        notice.layer.shadowOffset = CGSize(width: 0, height: 3)
        notice.layer.shadowRadius = 5
        notice.layer.shadowOpacity = 0.8
        notice.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notice)
        
        NSLayoutConstraint.activate([
            notice.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notice.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        notice.alpha = 0
        notice.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            notice.alpha = 1
            notice.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
                notice.alpha = 0
                notice.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                notice.removeFromSuperview()
            }
        }
    }
    
    func updateScore() {
        scoreDisplay.text = "SCORE: \(currentScore)"
        UIView.animate(withDuration: 0.2, animations: {
            self.scoreDisplay.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.scoreDisplay.transform = .identity
            }
        }
    }
    
    func updateClock() {
        let mins = Int(sessionTime) / 60
        let secs = Int(sessionTime) % 60
        clockDisplay.text = String(format: "TIME: %02d:%02d", mins, secs)
    }
    
    func incrementScore() {
        currentScore += 10
        updateScore()
    }
    
    func haltTimers() {
        clockTimer?.invalidate()
        clockTimer = nil
        targetTimer?.invalidate()
        targetTimer = nil
    }
    
    func vibrateError() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
    }
    
    func createBalancedSet(count: Int) -> [GamePiece] {
        var pieces: [GamePiece] = []
        for val in 1...9 {
            if let piece = PieceSource.shared.piecesByValue(val).randomElement() {
                pieces.append(piece)
            }
        }
        let remaining = count - pieces.count
        if remaining > 0 {
            pieces.append(contentsOf: PieceSource.shared.randomPieces(count: remaining))
        }
        pieces.shuffle()
        return pieces
    }
}

