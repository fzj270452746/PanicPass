//
//  ModePickerPanel.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

enum PlayStyle {
    case relaxed
    case intense
    
    var displayLabel: String {
        switch self {
        case .relaxed: return "RELAXED"
        case .intense: return "INTENSE"
        }
    }
    
    var symbol: String {
        switch self {
        case .relaxed: return "🎯"
        case .intense: return "⚡"
        }
    }
    
    var info: String {
        switch self {
        case .relaxed: return "Easy game, gradual difficulty"
        case .intense: return "Speed challenge! Accelerates every 10s"
        }
    }
    
    var initialVelocity: CGFloat {
        switch self {
        case .relaxed: return 1.5
        case .intense: return 2.5
        }
    }
    
    var targetSpawnRate: TimeInterval {
        switch self {
        case .relaxed: return 5.0
        case .intense: return 2.5
        }
    }
    
    var accelerationPeriod: TimeInterval {
        switch self {
        case .relaxed: return 30.0
        case .intense: return 10.0
        }
    }
    
    var velocityIncrement: CGFloat {
        switch self {
        case .relaxed: return 0.2
        case .intense: return 0.5
        }
    }
    
    var velocityCap: CGFloat {
        switch self {
        case .relaxed: return 3.0
        case .intense: return 10.0
        }
    }
    
    var tint: UIColor {
        switch self {
        case .relaxed: return StyleConfig.Palette.positive
        case .intense: return StyleConfig.Palette.negative
        }
    }
}

class ModePickerPanel: ScreenBase {
    
    // MARK: - Option Controls
    private var relaxedOption: UIButton!
    private var intenseOption: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        headingContent = ""
        headingSize = 36
        
        super.viewDidLoad()
        
        buildOptions()
        arrangeOptions()
        triggerReveal()
    }
    
    // MARK: - Build Options
    private func buildOptions() {
        relaxedOption = buildOptionControl(style: .relaxed)
        relaxedOption.addTarget(self, action: #selector(handleRelaxed), for: .touchUpInside)
        view.addSubview(relaxedOption)
        
        intenseOption = buildOptionControl(style: .intense)
        intenseOption.addTarget(self, action: #selector(handleIntense), for: .touchUpInside)
        view.addSubview(intenseOption)
    }
    
    // MARK: - Build Option Control
    private func buildOptionControl(style: PlayStyle) -> UIButton {
        let control = UIButton(type: .system)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let caption = UILabel()
        caption.text = "\(style.symbol) \(style.displayLabel)"
        caption.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        caption.textColor = .white
        caption.textAlignment = .center
        
        stack.addArrangedSubview(caption)
        control.addSubview(stack)
        
        control.backgroundColor = style.tint
        control.layer.cornerRadius = 24
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOffset = CGSize(width: 0, height: 5)
        control.layer.shadowRadius = 10
        control.layer.shadowOpacity = 0.35
        control.layer.borderWidth = 2
        control.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        control.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: control.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: control.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -15)
        ])
        
        return control
    }
    
    // MARK: - Arrange Options
    private func arrangeOptions() {
        let isCompact = UIDevice.current.userInterfaceIdiom == .phone
        let optionHeight: CGFloat = isCompact ? 65 : 80
        
        NSLayoutConstraint.activate([
            relaxedOption.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            relaxedOption.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            relaxedOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            relaxedOption.heightAnchor.constraint(equalToConstant: optionHeight),
            
            intenseOption.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            intenseOption.topAnchor.constraint(equalTo: relaxedOption.bottomAnchor, constant: 20),
            intenseOption.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            intenseOption.heightAnchor.constraint(equalToConstant: optionHeight)
        ])
    }
    
    // MARK: - Trigger Reveal
    private func triggerReveal() {
        MotionEngine.glideDown(element: headingDisplay, pause: 0.2)
        MotionEngine.popIn(element: relaxedOption, pause: 0.4)
        MotionEngine.popIn(element: intenseOption, pause: 0.5)
    }
    
    // MARK: - Handle Selection
    @objc private func handleRelaxed() {
        startSession(with: .relaxed)
    }
    
    @objc private func handleIntense() {
        startSession(with: .intense)
    }
    
    private func startSession(with style: PlayStyle) {
        let engine = PuzzleGameEngine()
        engine.selectedStyle = style
        engine.modalPresentationStyle = .fullScreen
        present(engine, animated: true)
    }
}
