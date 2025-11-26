//
//  GameModeSelector.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

enum GameplayMode {
    case classic
    case speedRush
    
    var displayName: String {
        switch self {
        case .classic:
            return "CLASSIC MODE"
        case .speedRush:
            return "SPEED RUSH"
        }
    }
    
    var description: String {
        switch self {
        case .classic:
            return "Relaxed gameplay with gradually increasing speed"
        case .speedRush:
            return "Extreme speed! Speed doubles every 10 seconds"
        }
    }
    
    var initialVelocity: CGFloat {
        switch self {
        case .classic:
            return 1.5
        case .speedRush:
            return 2.5
        }
    }
    
    var slotGenerationInterval: TimeInterval {
        switch self {
        case .classic:
            return 5.0
        case .speedRush:
            return 2.5
        }
    }
    
    var speedIncreaseInterval: TimeInterval {
        switch self {
        case .classic:
            return 30.0
        case .speedRush:
            return 10.0
        }
    }
    
    var speedIncreaseAmount: CGFloat {
        switch self {
        case .classic:
            return 0.2
        case .speedRush:
            return 0.5  // 每次增加50%
        }
    }
    
    var maxVelocity: CGFloat {
        switch self {
        case .classic:
            return 3.0
        case .speedRush:
            return 10.0  // 更高的速度上限
        }
    }
    
    var color: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        case .speedRush:
            return UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    }
}

class GameModeSelector: UIViewController {
    
    var backgroundIllustration: UIImageView!
    var dimmerOverlay: UIView!
    var retreatButton: UIButton!
    var titleEmblem: UILabel!
    var classicModeButton: UIButton!
    var speedRushButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        orchestrateLayout()
        activateAnimations()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

