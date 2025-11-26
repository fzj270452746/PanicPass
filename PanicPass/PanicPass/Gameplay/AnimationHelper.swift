//
//  MotionEngine.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

/// Motion Control Engine
class MotionEngine {
    
    // MARK: - Reveal Effect
    static func reveal(element: UIView, span: TimeInterval = 0.6, pause: TimeInterval = 0) {
        element.alpha = 0
        UIView.animate(withDuration: span, delay: pause, options: .curveEaseOut) {
            element.alpha = 1
        }
    }
    
    // MARK: - Pop In Effect
    static func popIn(element: UIView, span: TimeInterval = 0.6, pause: TimeInterval = 0, bounce: CGFloat = 0.6) {
        element.alpha = 0
        element.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: span, delay: pause, usingSpringWithDamping: bounce, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            element.alpha = 1
            element.transform = .identity
        }
    }
    
    // MARK: - Glide Down Effect
    static func glideDown(element: UIView, range: CGFloat = 30, span: TimeInterval = 0.6, pause: TimeInterval = 0) {
        element.alpha = 0
        element.transform = CGAffineTransform(translationX: 0, y: -range)
        
        UIView.animate(withDuration: span, delay: pause, options: .curveEaseOut) {
            element.alpha = 1
            element.transform = .identity
        }
    }
    
    // MARK: - Press Down Effect
    static func pressDown(_ control: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            control.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            control.alpha = 0.8
        }
    }
    
    // MARK: - Release Up Effect
    static func releaseUp(_ control: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .allowUserInteraction) {
            control.transform = .identity
            control.alpha = 1.0
        }
    }
    
    // MARK: - Bounce Emphasis
    static func bounce(element: UIView, magnitude: CGFloat = 1.2, span: TimeInterval = 0.2) {
        UIView.animate(withDuration: span, animations: {
            element.transform = CGAffineTransform(scaleX: magnitude, y: magnitude)
        }) { _ in
            UIView.animate(withDuration: span) {
                element.transform = .identity
            }
        }
    }
    
    // MARK: - Wobble Effect
    static func wobble(element: UIView) {
        let motion = CAKeyframeAnimation(keyPath: "transform.translation.x")
        motion.timingFunction = CAMediaTimingFunction(name: .linear)
        motion.duration = 0.3
        motion.values = [-10, 10, -8, 8, -5, 5, 0]
        element.layer.add(motion, forKey: "wobble")
    }
    
    // MARK: - Breathe Effect
    static func breathe(element: UIView, magnitude: CGFloat = 1.05) {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction]) {
            element.transform = CGAffineTransform(scaleX: magnitude, y: magnitude)
        }
    }
    
    // MARK: - Error Flash
    static func flashError(on element: UIView, completion: (() -> Void)? = nil) {
        let originalTint = element.layer.borderColor
        
        UIView.animate(withDuration: 0.15, animations: {
            element.layer.borderColor = StyleConfig.Palette.negative.cgColor
            element.backgroundColor = StyleConfig.Palette.negative.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                element.layer.borderColor = originalTint
                element.backgroundColor = .clear
            }) { _ in
                completion?()
            }
        }
    }
}

