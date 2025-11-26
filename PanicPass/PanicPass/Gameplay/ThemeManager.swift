//
//  StyleConfig.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

/// Unified visual style configuration manager
class StyleConfig {
    static let shared = StyleConfig()
    
    // MARK: - Color System
    struct Palette {
        static let accent = UIColor(red: 0.4, green: 0.75, blue: 0.95, alpha: 1.0)  // Sky blue
        static let positive = UIColor(red: 0.3, green: 0.85, blue: 0.6, alpha: 1.0)  // Green
        static let negative = UIColor(red: 0.95, green: 0.45, blue: 0.5, alpha: 1.0)  // Coral red
        static let neutral = UIColor(red: 0.5, green: 0.6, blue: 0.75, alpha: 1.0)  // Gray blue
        static let highlight = UIColor(red: 0.85, green: 0.6, blue: 0.95, alpha: 1.0)  // Violet
        
        static let dimLight = UIColor.black.withAlphaComponent(0.25)
        static let dimHeavy = UIColor.black.withAlphaComponent(0.45)
        
        static let surfaceBase = UIColor.white.withAlphaComponent(0.12)
        static let surfaceEdge = UIColor.white.withAlphaComponent(0.28)
    }
    
    // MARK: - Geometry Metrics
    struct Metrics {
        static let shapeRound: CGFloat = 14
        static let controlRound: CGFloat = 18
        static let edgeThick: CGFloat = 1.8
        
        static let gapNormal: CGFloat = 18
        static let gapTight: CGFloat = 8
        static let gapWide: CGFloat = 28
    }
    
    // MARK: - Depth Effect
    struct Depth {
        static let tint = UIColor.black.cgColor
        static let shift = CGSize(width: 0, height: 4)
        static let blur: CGFloat = 6
        static let strength: Float = 0.35
    }
    
    // MARK: - Apply Gradient Effect
    func createGradient(on surface: UIView, tones: [UIColor]? = nil) {
        let gradient = CAGradientLayer()
        gradient.frame = surface.bounds
        
        let colorArray = tones ?? [Palette.dimLight, Palette.dimHeavy]
        gradient.colors = colorArray.map { $0.cgColor }
        gradient.locations = [0.0, 1.0]
        surface.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: - Apply Surface Style
    func styleAsSurface(_ target: UIView) {
        target.backgroundColor = Palette.surfaceBase
        target.layer.cornerRadius = Metrics.shapeRound
        target.layer.borderWidth = 1.5
        target.layer.borderColor = Palette.surfaceEdge.cgColor
        target.layer.shadowColor = Depth.tint
        target.layer.shadowOffset = Depth.shift
        target.layer.shadowRadius = Depth.blur
        target.layer.shadowOpacity = Depth.strength
    }
    
    // MARK: - Apply Text Depth
    func addTextDepth(to text: UILabel) {
        text.layer.shadowColor = UIColor.black.cgColor
        text.layer.shadowOffset = CGSize(width: 0, height: 2)
        text.layer.shadowRadius = 4
        text.layer.shadowOpacity = 0.6
    }
}

