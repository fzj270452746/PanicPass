//
//  GameplayOrchestrator.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class GameplayOrchestrator: UIViewController {
    
    var backgroundIllustration: UIImageView!
    var dimmerOverlay: UIView!
    var retreatButton: UIButton!
    var accomplishmentLabel: UILabel!
    var chronometer: UILabel!
    var modeIndicator: UILabel!
    
    var upperSlotContainer: UIView!
    var lowerTileContainer: CustomScrollView!
    var tilePalette: UIView!
    
    var slotQueue: [SlotVessel] = []
    var availableTiles: [TileEntity] = []
    var currentAccomplishment: Int = 0
    var elapsedDuration: TimeInterval = 0
    var gameTimer: Timer?
    var slotTimer: Timer?
    var slotVelocity: CGFloat = 1.5
    var activeSlotIndex: Int = 0
    var gameMode: GameplayMode = .classic
    var hasRecordSaved: Bool = false
    
    var hasInitiatedGameplay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        orchestrateLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Only initiate gameplay once, after the view is fully visible
        if !hasInitiatedGameplay {
            hasInitiatedGameplay = true
            // Small delay to ensure all animations are ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.initiateGameplay()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        terminateTimers()
        
        // 自动保存游戏记录（如果还没保存的话）
        if currentAccomplishment > 0 && !hasRecordSaved {
            saveGameRecord()
        }
    }
}

// MARK: - Slot Vessel Model
class SlotVessel: UIView {
    var requiredMagnitude: Int
    var magnitudeLabel: UILabel!
    var tileIllustration: UIImageView?
    var isFulfilled: Bool = false
    
    init(magnitude: Int) {
        self.requiredMagnitude = magnitude
        super.init(frame: .zero)
        configureVessel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureVessel() {
        backgroundColor = UIColor.white.withAlphaComponent(0.25)
        layer.cornerRadius = 10
        layer.borderWidth = 2.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.4
        
        magnitudeLabel = UILabel()
        magnitudeLabel.text = "\(requiredMagnitude)"
        magnitudeLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        magnitudeLabel.textColor = .white
        magnitudeLabel.textAlignment = .center
        magnitudeLabel.layer.shadowColor = UIColor.black.cgColor
        magnitudeLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        magnitudeLabel.layer.shadowRadius = 3
        magnitudeLabel.layer.shadowOpacity = 0.5
        magnitudeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(magnitudeLabel)
        
        NSLayoutConstraint.activate([
            magnitudeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            magnitudeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func illuminateHighlight() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction]) {
            self.layer.borderColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0).cgColor
            self.layer.borderWidth = 4
            self.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.4)
            self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }
    }
    
    func extinguishHighlight() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
            self.layer.borderWidth = 2.5
            self.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            self.transform = .identity
        }
    }
    
    func manifestError() {
        let originalTransform = self.transform
        
        UIView.animate(withDuration: 0.15, animations: {
            self.layer.borderColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
            self.backgroundColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.6)
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    if !self.isFulfilled {
                        self.layer.borderColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0).cgColor
                        self.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.4)
                        self.transform = originalTransform
                    }
                }
            }
        }
    }
    
    func fulfillWithTile(_ tile: TileEntity, completion: @escaping () -> Void) {
        isFulfilled = true
        
        // Create image view for the tile
        let imageView = UIImageView(image: tile.illustration)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        // Force layout
        layoutIfNeeded()
        
        self.tileIllustration = imageView
        
        // Make number label semi-transparent but keep it visible
        magnitudeLabel.alpha = 0.5
        bringSubviewToFront(magnitudeLabel)
        
        // Success animation
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.borderColor = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0).cgColor
            self.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.35)
            self.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
        }) { _ in
            UIView.animate(withDuration: 0.25) {
                self.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }
}

