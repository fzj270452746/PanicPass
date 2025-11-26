//
//  EnhancedScrollView.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class EnhancedScrollView: UIScrollView {
    
    override func touchesShouldCancel(in target: UIView) -> Bool {
        // Keep button touches from being cancelled
        if target is UIButton {
            return false
        }
        return super.touchesShouldCancel(in: target)
    }
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in target: UIView) -> Bool {
        // Allow buttons to receive touches
        if target is UIButton {
            return true
        }
        return super.touchesShouldBegin(touches, with: event, in: target)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func configure() {
        delaysContentTouches = false
        canCancelContentTouches = true
    }
}

