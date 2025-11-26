//
//  PuzzleGameEngine.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class PuzzleGameEngine: UIViewController {
    
    var backdropCanvas: UIImageView!
    var maskOverlay: UIView!
    var quitControl: UIButton!
    var scoreDisplay: UILabel!
    var clockDisplay: UILabel!
    var styleBadge: UILabel!
    
    var targetZone: UIView!
    var pieceContainer: EnhancedScrollView!
    var pieceGrid: UIView!
    
    var targetList: [TargetSlot] = []
    var activePieces: [GamePiece] = []
    var currentScore: Int = 0
    var sessionTime: TimeInterval = 0
    var clockTimer: Timer?
    var targetTimer: Timer?
    var movementRate: CGFloat = 1.5
    var focusedIndex: Int = 0
    var selectedStyle: PlayStyle = .relaxed
    var recordSaved: Bool = false
    
    var sessionStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assembleInterface()
        establishLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start game session only once
        if !sessionStarted {
            sessionStarted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.beginSession()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        haltTimers()
        
        // Auto-save record
        if currentScore > 0 && !recordSaved {
            captureRecord()
        }
    }
}

// MARK: - Target Slot Model
class TargetSlot: UIView {
    var neededValue: Int
    var valueDisplay: UILabel!
    var pieceImage: UIImageView?
    var isMatched: Bool = false
    
    init(value: Int) {
        self.neededValue = value
        super.init(frame: .zero)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAppearance() {
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        layer.cornerRadius = 10
        layer.borderWidth = 2.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.4
        
        valueDisplay = UILabel()
        valueDisplay.text = "\(neededValue)"
        valueDisplay.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        valueDisplay.textColor = UIColor(red: 1.0, green: 0.92, blue: 0.2, alpha: 1.0)  // Bright yellow
        valueDisplay.textAlignment = .center
        valueDisplay.layer.shadowColor = UIColor.black.cgColor
        valueDisplay.layer.shadowOffset = CGSize(width: 0, height: 2)
        valueDisplay.layer.shadowRadius = 3
        valueDisplay.layer.shadowOpacity = 0.5
        valueDisplay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueDisplay)
        
        NSLayoutConstraint.activate([
            valueDisplay.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueDisplay.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func activateFocus() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction]) {
            self.layer.borderColor = StyleConfig.Palette.accent.cgColor
            self.layer.borderWidth = 4
            self.backgroundColor = StyleConfig.Palette.accent.withAlphaComponent(0.35)
            self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }
    }
    
    func deactivateFocus() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor
            self.layer.borderWidth = 2.5
            self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            self.transform = .identity
        }
    }
    
    func showMismatch() {
        let savedTransform = self.transform
        
        UIView.animate(withDuration: 0.15, animations: {
            self.layer.borderColor = StyleConfig.Palette.negative.cgColor
            self.backgroundColor = StyleConfig.Palette.negative.withAlphaComponent(0.5)
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    if !self.isMatched {
                        self.layer.borderColor = StyleConfig.Palette.accent.cgColor
                        self.backgroundColor = StyleConfig.Palette.accent.withAlphaComponent(0.35)
                        self.transform = savedTransform
                    }
                }
            }
        }
    }
    
    func completeWith(_ piece: GamePiece, finished: @escaping () -> Void) {
        isMatched = true
        
        let display = UIImageView(image: piece.visual)
        display.contentMode = .scaleAspectFill
        display.layer.cornerRadius = 6
        display.clipsToBounds = true
        display.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        display.translatesAutoresizingMaskIntoConstraints = false
        addSubview(display)
        
        NSLayoutConstraint.activate([
            display.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            display.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            display.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            display.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        layoutIfNeeded()
        self.pieceImage = display
        valueDisplay.alpha = 0.5
        bringSubviewToFront(valueDisplay)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.borderColor = StyleConfig.Palette.positive.cgColor
            self.backgroundColor = StyleConfig.Palette.positive.withAlphaComponent(0.3)
            self.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
        }) { _ in
            UIView.animate(withDuration: 0.25) {
                self.transform = .identity
            } completion: { _ in
                finished()
            }
        }
    }
}

