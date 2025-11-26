//
//  GameplayOrchestrator+Logic.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

extension GameplayOrchestrator {
    
    func initiateGameplay() {
        currentAccomplishment = 0
        elapsedDuration = 0
        activeSlotIndex = 0
        
        // 根据游戏模式设置初始速度
        slotVelocity = gameMode.initialVelocity
        
        // 更新模式指示器
        modeIndicator.text = gameMode == .classic ? "CLASSIC" : "SPEED RUSH ⚡"
        
        refreshAccomplishment()
        generateTilePalette()
        commenceChronometer()
        
        // Small delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.commenceSlotGeneration()
        }
    }
    
    func generateTilePalette() {
        // Clear existing tiles
        tilePalette.subviews.forEach { $0.removeFromSuperview() }
        
        // Generate tiles ensuring all magnitudes (1-9) are present
        availableTiles = generateBalancedTiles(quantity: 30)
        
        let isCompactDevice = UIDevice.current.userInterfaceIdiom == .phone
        // Smaller tile sizes
        let tileSize: CGFloat = isCompactDevice ? 48 : 72
        let tileSpacing: CGFloat = 6
        let tilesPerRow = isCompactDevice ? 6 : 8
        
        for (index, tile) in availableTiles.enumerated() {
            let row = index / tilesPerRow
            let col = index % tilesPerRow
            
            let tileButton = UIButton(type: .custom)
            tileButton.tag = index
            tileButton.setImage(tile.illustration, for: .normal)
            tileButton.imageView?.contentMode = .scaleAspectFill
            tileButton.layer.cornerRadius = 6
            tileButton.clipsToBounds = true
            tileButton.layer.borderWidth = 2.5
            tileButton.layer.borderColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.8).cgColor
            tileButton.layer.shadowColor = UIColor.black.cgColor
            tileButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            tileButton.layer.shadowRadius = 4
            tileButton.layer.shadowOpacity = 0.4
            tileButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            
            // 确保交互启用
            tileButton.isUserInteractionEnabled = true
            tileButton.isEnabled = true
            tileButton.isExclusiveTouch = false
            
            // 添加所有触摸事件
            tileButton.addTarget(self, action: #selector(tileTouchDown(_:)), for: .touchDown)
            tileButton.addTarget(self, action: #selector(tileSelected(_:)), for: .touchUpInside)
            
            // Store magnitude in accessibility identifier
            tileButton.accessibilityIdentifier = "tile_\(tile.magnitude)_\(index)"
            
            let xPosition = CGFloat(col) * (tileSize + tileSpacing) + tileSpacing / 2
            let yPosition = CGFloat(row) * (tileSize * 1.4 + tileSpacing) + tileSpacing / 2
            
            tileButton.frame = CGRect(x: xPosition, y: yPosition, width: tileSize, height: tileSize * 1.4)
            
            // 先添加到视图
            tilePalette.addSubview(tileButton)
            
            // 简单淡入，不阻塞交互
            tileButton.alpha = 0.3
            UIView.animate(withDuration: 0.3, delay: Double(index) * 0.01, options: .allowUserInteraction) {
                tileButton.alpha = 1
            }
        }
        
        
        let totalRows = (availableTiles.count - 1) / tilesPerRow + 1
        let contentWidth = CGFloat(tilesPerRow) * (tileSize + tileSpacing) + tileSpacing
        let contentHeight = CGFloat(totalRows) * (tileSize * 1.4 + tileSpacing) + tileSpacing
        
        // 计算居中位置
        let containerWidth = lowerTileContainer.bounds.width
        let xOffset = max((containerWidth - contentWidth) / 2, 0)
        
        // 设置tilePalette的frame，居中显示
        tilePalette.frame = CGRect(x: xOffset, y: 0, width: contentWidth, height: contentHeight)
        
        // 关闭滚动，因为所有麻将都能显示
        lowerTileContainer.contentSize = lowerTileContainer.bounds.size
        lowerTileContainer.isScrollEnabled = false
        lowerTileContainer.showsVerticalScrollIndicator = false
        

    }
    
    @objc func tileTouchDown(_ sender: UIButton) {
        
        // 按下动画 - 立即缩小
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            sender.alpha = 0.8
        }
    }
    
    @objc func tileSelected(_ sender: UIButton) {
        
        // 恢复动画
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .allowUserInteraction) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
        
        guard sender.tag < availableTiles.count else {
            return
        }
        
        guard activeSlotIndex < slotQueue.count else {
            return
        }
        
        guard sender.isEnabled else {
            return
        }
        
        let selectedTile = availableTiles[sender.tag]
        let currentSlot = slotQueue[activeSlotIndex]
        
        
        // 添加选中动画 - 弹跳效果
        animateTileSelection(sender)
        
        if selectedTile.magnitude == currentSlot.requiredMagnitude {
            // Correct selection
            executeTileAnimation(from: sender, to: currentSlot, tile: selectedTile)
            generateSuccessFeedback()
        } else {
            // Wrong selection
            currentSlot.manifestError()
            vibrateDevice()
            animateIncorrectTile(sender)
        }
    }
    
    func animateTileSelection(_ button: UIButton) {
        // 选中时的弹跳动画
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: [.allowUserInteraction, .curveEaseOut]) {
            button.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
                button.transform = .identity
            }
        }
    }
    
    func animateIncorrectTile(_ button: UIButton) {
        let originalColor = button.layer.borderColor
        
        UIView.animate(withDuration: 0.1, animations: {
            button.layer.borderColor = UIColor.red.cgColor
            button.transform = CGAffineTransform(translationX: -10, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = CGAffineTransform(translationX: 10, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    button.transform = .identity
                }) { _ in
                    UIView.animate(withDuration: 0.2) {
                        button.layer.borderColor = originalColor
                    }
                }
            }
        }
    }
    
    func generateSuccessFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func executeTileAnimation(from button: UIButton, to slot: SlotVessel, tile: TileEntity) {
        // 保存按钮索引，用于重新计算位置
        let buttonIndex = button.tag
        
        // Disable button immediately to prevent double-tap
        button.isEnabled = false
        
        // Create animated tile
        let animatedTile = UIImageView(image: tile.illustration)
        animatedTile.contentMode = .scaleAspectFill
        animatedTile.layer.cornerRadius = 6
        animatedTile.clipsToBounds = true
        animatedTile.layer.borderWidth = 2
        animatedTile.layer.borderColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0).cgColor
        
        // 获取起始位置
        let startFrame = button.convert(button.bounds, to: view)
        animatedTile.frame = startFrame
        view.addSubview(animatedTile)
        
        // 获取slot当前在屏幕上的实际位置
        let slotPresentationLayer = slot.layer.presentation() ?? slot.layer
        var slotCurrentFrame = slotPresentationLayer.frame
        
        // 将slot的frame转换到主view坐标系
        if let slotSuperview = slot.superview {
            slotCurrentFrame = slotSuperview.convert(slotCurrentFrame, to: view)
        }
        
        let endFrame = slotCurrentFrame.insetBy(dx: 5, dy: 5)
        
        
        // 使用UIView动画，更简单直接
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            animatedTile.frame = endFrame
            animatedTile.transform = CGAffineTransform(rotationAngle: .pi / 6)
        }) { finished in
            animatedTile.removeFromSuperview()
            
            // Fill the slot with the tile
            slot.fulfillWithTile(tile) {
                self.advanceToNextSlot()
            }
            
            self.incrementAccomplishment()
        }
        
        // 淡出使用过的按钮并在原位置补充新麻将
        UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
            button.alpha = 0
            button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { _ in
            button.removeFromSuperview()
            
            // 使用索引重新计算位置，完全不依赖旧frame
            self.addNewTileAtIndex(buttonIndex)
        }
    }
    
    func advanceToNextSlot() {
        if activeSlotIndex < slotQueue.count {
            slotQueue[activeSlotIndex].extinguishHighlight()
        }
        
        activeSlotIndex += 1
        
        if activeSlotIndex < slotQueue.count {
            slotQueue[activeSlotIndex].illuminateHighlight()
        }
    }
    
    func addNewTileAtIndex(_ index: Int) {
        // 添加一个新的麻将，完全重新计算位置和尺寸
        let randomTile = TileRepository.shared.fetchRandomTiles(quantity: 1).first
        guard let tile = randomTile else { return }
        
        // 使用固定的尺寸参数重新计算（与generateTilePalette中完全相同）
        let isCompactDevice = UIDevice.current.userInterfaceIdiom == .phone
        let tileSize: CGFloat = isCompactDevice ? 48 : 72  // 固定尺寸
        let tileSpacing: CGFloat = 6  // 固定间距
        let tilesPerRow = isCompactDevice ? 6 : 8  // 固定每行数量
        
        // 根据索引重新计算行列
        let row = index / tilesPerRow
        let col = index % tilesPerRow
        
        // 重新计算精确位置
        let xPosition = CGFloat(col) * (tileSize + tileSpacing) + tileSpacing / 2
        let yPosition = CGFloat(row) * (tileSize * 1.4 + tileSpacing) + tileSpacing / 2
        
        // 创建新按钮
        let tileButton = UIButton(type: .custom)
        tileButton.tag = index
        tileButton.setImage(tile.illustration, for: .normal)
        tileButton.imageView?.contentMode = .scaleAspectFill
        tileButton.layer.cornerRadius = 6
        tileButton.clipsToBounds = true
        tileButton.layer.borderWidth = 2.5
        tileButton.layer.borderColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.8).cgColor
        tileButton.layer.shadowColor = UIColor.black.cgColor
        tileButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        tileButton.layer.shadowRadius = 4
        tileButton.layer.shadowOpacity = 0.4
        tileButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tileButton.isUserInteractionEnabled = true
        tileButton.isEnabled = true
        tileButton.isExclusiveTouch = false
        tileButton.addTarget(self, action: #selector(tileTouchDown(_:)), for: .touchDown)
        tileButton.addTarget(self, action: #selector(tileSelected(_:)), for: .touchUpInside)
        tileButton.accessibilityIdentifier = "tile_\(tile.magnitude)_\(index)"
        
        // 使用重新计算的frame（固定尺寸）
        let calculatedFrame = CGRect(x: xPosition, y: yPosition, width: tileSize, height: tileSize * 1.4)
        tileButton.frame = calculatedFrame
        
        // 确保transform是identity
        tileButton.transform = .identity
        
        // 更新availableTiles数组
        if index < availableTiles.count {
            availableTiles[index] = tile
        }
        
        // 添加到视图
        tilePalette.addSubview(tileButton)
        
        
        // 只使用透明度动画，完全不碰transform
        tileButton.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut]) {
            tileButton.alpha = 1
        }
    }
    
    func commenceSlotGeneration() {
        // 根据游戏模式设置生成间隔
        let generationInterval = gameMode.slotGenerationInterval
        
        // Timer for continuous slot generation
        slotTimer = Timer.scheduledTimer(withTimeInterval: generationInterval, repeats: true) { [weak self] _ in
            self?.generateSlot()
        }
        
        // Generate first slot immediately
        generateSlot()
    }
    
    func generateSlot() {
        // 获取当前可用的麻将面值
        let availableMagnitudes = getAvailableMagnitudes()
        
        // 如果没有可用麻将，使用1-9随机（fallback）
        let randomMagnitude: Int
        if availableMagnitudes.isEmpty {
            randomMagnitude = Int.random(in: 1...9)
        } else {
            randomMagnitude = availableMagnitudes.randomElement() ?? Int.random(in: 1...9)
        }
        
        let slot = SlotVessel(magnitude: randomMagnitude)
        
        let isCompactDevice = UIDevice.current.userInterfaceIdiom == .phone
        let slotWidth: CGFloat = isCompactDevice ? 65 : 95
        let slotHeight: CGFloat = isCompactDevice ? 85 : 125
        
        // Calculate y position to vertically center in container
        let containerHeight = upperSlotContainer.bounds.height
        let yPosition = max((containerHeight - slotHeight) / 2, 0)
        
        // Always start from the same position (right edge of screen + offset)
        let startX = view.bounds.width + 20
        
        slot.frame = CGRect(x: startX, y: yPosition, width: slotWidth, height: slotHeight)
        upperSlotContainer.addSubview(slot)
        slotQueue.append(slot)
        
        // Highlight the first slot or the active slot
        if slotQueue.count == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                slot.illuminateHighlight()
            }
        }
        
        // Start animation with fixed duration
        animateSlot(slot)
    }
    
    func getAvailableMagnitudes() -> [Int] {
        // 获取所有启用的按钮
        let enabledButtons = tilePalette.subviews.compactMap { $0 as? UIButton }.filter { $0.isEnabled }
        
        // 获取这些按钮对应的麻将面值
        var magnitudes = Set<Int>()
        for button in enabledButtons {
            if button.tag < availableTiles.count {
                let magnitude = availableTiles[button.tag].magnitude
                magnitudes.insert(magnitude)
            }
        }
        
        let result = Array(magnitudes).sorted()
        return result
    }
    
    func animateSlot(_ slot: SlotVessel) {
        // Use fixed duration for all slots to maintain consistent speed and spacing
        let baseDuration: TimeInterval = 20.0 / Double(slotVelocity)
        
        UIView.animate(withDuration: baseDuration, delay: 0, options: .curveLinear, animations: {
            slot.frame.origin.x = -slot.frame.width - 20
        }) { finished in
            if finished && !slot.isFulfilled {
                self.handleMissedSlot(slot)
            }
            slot.removeFromSuperview()
        }
    }
    
    func handleMissedSlot(_ slot: SlotVessel) {
        if let index = slotQueue.firstIndex(of: slot) {
            // Simply remove the slot without game over
            slotQueue.remove(at: index)
            
            // Adjust active index if needed
            if index < activeSlotIndex {
                activeSlotIndex -= 1
            } else if index == activeSlotIndex {
                // If we missed the active slot, move to the next one
                // Active index stays the same but now points to the next slot
                if activeSlotIndex < slotQueue.count {
                    slotQueue[activeSlotIndex].illuminateHighlight()
                }
            }
        }
    }
    
    func commenceChronometer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedDuration += 1
            self.refreshChronometer()
            
            // 根据游戏模式增加难度
            let increaseInterval = Int(self.gameMode.speedIncreaseInterval)
            if Int(self.elapsedDuration) % increaseInterval == 0 && self.slotVelocity < self.gameMode.maxVelocity {
                let oldVelocity = self.slotVelocity
                
                if self.gameMode == .speedRush {
                    // 速度狂飙模式：速度递增50%
                    self.slotVelocity += self.gameMode.speedIncreaseAmount
                    self.slotVelocity = min(self.slotVelocity, self.gameMode.maxVelocity)
                } else {
                    // 经典模式：线性增加
                    self.slotVelocity += self.gameMode.speedIncreaseAmount
                }
                
                // 显示速度提升提示
                self.showSpeedIncreaseAlert(from: oldVelocity, to: self.slotVelocity)
            }
        }
    }
    
    func showSpeedIncreaseAlert(from oldSpeed: CGFloat, to newSpeed: CGFloat) {
        let speedMultiplier = String(format: "%.1f", newSpeed / gameMode.initialVelocity)
        let alertLabel = UILabel()
        alertLabel.text = gameMode == .speedRush ? "🚀 SPEED x\(speedMultiplier)!" : "⚡ SPEED UP!"
        alertLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        alertLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        alertLabel.textAlignment = .center
        alertLabel.layer.shadowColor = UIColor.black.cgColor
        alertLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        alertLabel.layer.shadowRadius = 5
        alertLabel.layer.shadowOpacity = 0.8
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertLabel)
        
        NSLayoutConstraint.activate([
            alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        alertLabel.alpha = 0
        alertLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.3, animations: {
            alertLabel.alpha = 1
            alertLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
                alertLabel.alpha = 0
                alertLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                alertLabel.removeFromSuperview()
            }
        }
    }
    
    func refreshAccomplishment() {
        accomplishmentLabel.text = "SCORE: \(currentAccomplishment)"
        
        // Bounce animation
        UIView.animate(withDuration: 0.2, animations: {
            self.accomplishmentLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.accomplishmentLabel.transform = .identity
            }
        }
    }
    
    func refreshChronometer() {
        let minutes = Int(elapsedDuration) / 60
        let seconds = Int(elapsedDuration) % 60
        chronometer.text = String(format: "TIME: %02d:%02d", minutes, seconds)
    }
    
    func incrementAccomplishment() {
        currentAccomplishment += 10
        refreshAccomplishment()
    }
    
    func terminateTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        slotTimer?.invalidate()
        slotTimer = nil
    }
    
    func terminateGameplay() {
        terminateTimers()
        
        // Save record with mode name
        let modeName = gameMode == .classic ? "Classic" : "Speed Rush"
        let archive = GameArchive(accomplishment: currentAccomplishment, duration: elapsedDuration, modeName: modeName)
        ArchiveKeeper.shared.preserveArchive(archive)
        
        // Show game over dialog
        presentGameOverDialog()
    }
    
    func presentGameOverDialog() {
        let minutes = Int(elapsedDuration) / 60
        let seconds = Int(elapsedDuration) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        let alert = UIAlertController(
            title: "🎮 Game Over!",
            message: "Your Score: \(currentAccomplishment) points\nTime Played: \(timeString)\n\nGreat effort! Try again to beat your score!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { _ in
            self.resetGameplay()
        })
        
        alert.addAction(UIAlertAction(title: "Exit", style: .cancel) { _ in
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    func resetGameplay() {
        // Clear slots
        slotQueue.forEach { $0.removeFromSuperview() }
        slotQueue.removeAll()
        
        // Reset variables - 根据游戏模式重置
        slotVelocity = gameMode.initialVelocity
        hasRecordSaved = false  // 重置记录保存标志
        
        // Restart game
        initiateGameplay()
    }
    
    func vibrateDevice() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func generateBalancedTiles(quantity: Int) -> [TileEntity] {
        var tiles: [TileEntity] = []
        
        // First, ensure we have at least one tile of each magnitude (1-9)
        for magnitude in 1...9 {
            if let tile = TileRepository.shared.fetchTilesByMagnitude(magnitude).randomElement() {
                tiles.append(tile)
            }
        }
        
        // Fill the rest with random tiles
        let remaining = quantity - tiles.count
        if remaining > 0 {
            let randomTiles = TileRepository.shared.fetchRandomTiles(quantity: remaining)
            tiles.append(contentsOf: randomTiles)
        }
        
        // Shuffle to randomize positions
        tiles.shuffle()
        
        var counts: [Int: Int] = [:]
        for tile in tiles {
            counts[tile.magnitude, default: 0] += 1
        }
        for i in 1...9 {
        }
        
        return tiles
    }
}

