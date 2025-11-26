

import UIKit


class InKeyoaiPortalController: UIViewController {
    
    var backgroundIllustration: UIImageView!
    var dimmerOverlay: UIView!
    var titleEmblem: UILabel!
    var commenceButton: UIButton!
    var instructionButton: UIButton!
    var archivesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        
        let pod = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        pod!.view.tag = 287
        pod?.view.frame = UIScreen.main.bounds
        view.addSubview(pod!.view)
        
        orchestrateLayout()
        activateAnimations()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

