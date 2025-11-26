//
//  InstructionManifest.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class InstructionManifest: UIViewController {
    
    var backgroundIllustration: UIImageView!
    var dimmerOverlay: UIView!
    var retreatButton: UIButton!
    var titleEmblem: UILabel!
    var scrollContainer: UIScrollView!
    var contentVessel: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        orchestrateLayout()
        populateInstructions()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

