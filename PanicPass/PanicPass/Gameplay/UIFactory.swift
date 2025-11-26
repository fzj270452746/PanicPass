//
//  ComponentBuilder.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

/// UI Component Builder
class ComponentBuilder {
    
    // MARK: - Build Action Button
    static func buildActionButton(label: String, tint: UIColor) -> UIButton {
        let control = UIButton(type: .system)
        control.setTitle(label, for: .normal)
        control.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        control.setTitleColor(.white, for: .normal)
        control.backgroundColor = tint
        control.layer.cornerRadius = 26
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOffset = CGSize(width: 0, height: 5)
        control.layer.shadowRadius = 10
        control.layer.shadowOpacity = 0.35
        control.layer.borderWidth = 2
        control.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }
    
    // MARK: - Build Exit Button
    static func buildExitButton() -> UIButton {
        let control = UIButton(type: .system)
        control.setTitle("◀ BACK", for: .normal)
        control.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        control.setTitleColor(.white, for: .normal)
        control.backgroundColor = StyleConfig.Palette.negative.withAlphaComponent(0.9)
        control.layer.cornerRadius = StyleConfig.Metrics.controlRound
        control.layer.shadowColor = StyleConfig.Depth.tint
        control.layer.shadowOffset = CGSize(width: 0, height: 2)
        control.layer.shadowRadius = 4
        control.layer.shadowOpacity = 0.3
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }
    
    // MARK: - Build Heading Text
    static func buildHeadingText(content: String, size: CGFloat = 34) -> UILabel {
        let display = UILabel()
        display.text = content
        display.font = UIFont.systemFont(ofSize: size, weight: .heavy)
        display.textColor = StyleConfig.Palette.accent
        display.textAlignment = .center
        StyleConfig.shared.addTextDepth(to: display)
        display.translatesAutoresizingMaskIntoConstraints = false
        return display
    }
    
    // MARK: - Build Backdrop Image
    static func buildBackdropImage() -> UIImageView {
        let canvas = UIImageView()
        canvas.image = UIImage(named: "passPhoto")
        canvas.contentMode = .scaleAspectFill
        canvas.translatesAutoresizingMaskIntoConstraints = false
        return canvas
    }
    
    // MARK: - Build Dim Layer
    static func buildDimLayer() -> UIView {
        let mask = UIView()
        mask.backgroundColor = StyleConfig.Palette.dimLight
        mask.translatesAutoresizingMaskIntoConstraints = false
        return mask
    }
    
    // MARK: - Build Info Text
    static func buildInfoText(size: CGFloat = 16, thickness: UIFont.Weight = .medium) -> UILabel {
        let display = UILabel()
        display.font = UIFont.systemFont(ofSize: size, weight: thickness)
        display.textColor = UIColor.white.withAlphaComponent(0.9)
        display.translatesAutoresizingMaskIntoConstraints = false
        return display
    }
}

