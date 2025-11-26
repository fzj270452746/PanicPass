//
//  ScreenBase.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

/// Base class for all screen controllers
class ScreenBase: UIViewController {
    
    // MARK: - Shared UI Elements
    var backdropCanvas: UIImageView!
    var maskLayer: UIView!
    var exitControl: UIButton!
    var headingDisplay: UILabel!
    
    // MARK: - Display Configuration
    var needsExitControl: Bool = true
    var needsHeadingDisplay: Bool = true
    var headingContent: String = ""
    var headingSize: CGFloat = 34
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        assembleSharedUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Assemble Shared UI
    private func assembleSharedUI() {
        buildBackdrop()
        buildMask()
        
        if needsExitControl {
            buildExitControl()
        }
        
        if needsHeadingDisplay {
            buildHeading()
        }
        
        arrangeLayout()
        
        // Apply gradient effect with delay
        DispatchQueue.main.async {
            self.enhanceMask()
        }
    }
    
    // MARK: - Build Backdrop
    private func buildBackdrop() {
        backdropCanvas = ComponentBuilder.buildBackdropImage()
        view.addSubview(backdropCanvas)
    }
    
    // MARK: - Build Mask
    private func buildMask() {
        maskLayer = ComponentBuilder.buildDimLayer()
        view.addSubview(maskLayer)
    }
    
    // MARK: - Build Exit Control
    private func buildExitControl() {
        exitControl = ComponentBuilder.buildExitButton()
        exitControl.addTarget(self, action: #selector(handleExit), for: .touchUpInside)
        view.addSubview(exitControl)
    }
    
    // MARK: - Build Heading
    private func buildHeading() {
        headingDisplay = ComponentBuilder.buildHeadingText(content: headingContent, size: headingSize)
        view.addSubview(headingDisplay)
    }
    
    // MARK: - Enhance Mask
    private func enhanceMask() {
        StyleConfig.shared.createGradient(on: maskLayer)
    }
    
    // MARK: - Arrange Layout
    private func arrangeLayout() {
        NSLayoutConstraint.activate([
            // Backdrop canvas
            backdropCanvas.topAnchor.constraint(equalTo: view.topAnchor),
            backdropCanvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropCanvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropCanvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Mask layer
            maskLayer.topAnchor.constraint(equalTo: view.topAnchor),
            maskLayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            maskLayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            maskLayer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if needsExitControl {
            NSLayoutConstraint.activate([
                exitControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                exitControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                exitControl.widthAnchor.constraint(equalToConstant: 100),
                exitControl.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        if needsHeadingDisplay {
            NSLayoutConstraint.activate([
                headingDisplay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                headingDisplay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                headingDisplay.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
                headingDisplay.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
            ])
        }
    }
    
    // MARK: - Exit Handler
    @objc func handleExit() {
        dismiss(animated: true)
    }
    
    // MARK: - Extension Points for Subclasses
    func extendUI() {
        // Subclasses override this method to add custom UI
    }
    
    func extendLayout() {
        // Subclasses override this method to add custom layout
    }
}

