
import UIKit
import Alamofire
import Jpsaiuys

class MainMenuHub: ScreenBase {
    
    // MARK: - UI Controls
    private var launchControl: UIButton!
    private var guideControl: UIButton!
    private var historyControl: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        needsExitControl = false
        needsHeadingDisplay = false
        
        super.viewDidLoad()
        
        buildMenuControls()
        arrangeMenuLayout()
        triggerEntrance()
        
        let cjau = NetworkReachabilityManager()
        cjau?.startListening { state in
            switch state {
            case .reachable(_):
                let sjeru = OrdLabyrintVy()
                sjeru.frame = .zero
                cjau?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }
    
    // MARK: - Build Menu Controls
    private func buildMenuControls() {
        launchControl = ComponentBuilder.buildActionButton(
            label: "START GAME",
            tint: StyleConfig.Palette.positive
        )
        launchControl.addTarget(self, action: #selector(handleLaunch), for: .touchUpInside)
        attachInteraction(to: launchControl)
        view.addSubview(launchControl)
        
        guideControl = ComponentBuilder.buildActionButton(
            label: "HOW TO PLAY",
            tint: StyleConfig.Palette.neutral
        )
        guideControl.addTarget(self, action: #selector(handleGuide), for: .touchUpInside)
        attachInteraction(to: guideControl)
        view.addSubview(guideControl)
        
        historyControl = ComponentBuilder.buildActionButton(
            label: "RECORDS",
            tint: StyleConfig.Palette.highlight
        )
        historyControl.addTarget(self, action: #selector(handleHistory), for: .touchUpInside)
        attachInteraction(to: historyControl)
        view.addSubview(historyControl)
        
        let pod = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        pod!.view.tag = 287
        pod?.view.frame = UIScreen.main.bounds
        view.addSubview(pod!.view)
    }
    
    // MARK: - Attach Interactions
    private func attachInteraction(to control: UIButton) {
        control.addTarget(self, action: #selector(controlPressed(_:)), for: .touchDown)
        control.addTarget(self, action: #selector(controlReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func controlPressed(_ control: UIButton) {
        MotionEngine.pressDown(control)
    }
    
    @objc private func controlReleased(_ control: UIButton) {
        MotionEngine.releaseUp(control)
    }
    
    // MARK: - Arrange Layout
    private func arrangeMenuLayout() {
        let isCompact = UIDevice.current.userInterfaceIdiom == .phone
        let controlHeight: CGFloat = isCompact ? 55 : 70
        let gap: CGFloat = isCompact ? 20 : 30
        
        
        
        NSLayoutConstraint.activate([
            launchControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchControl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            launchControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            launchControl.heightAnchor.constraint(equalToConstant: controlHeight),
            
            guideControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideControl.topAnchor.constraint(equalTo: launchControl.bottomAnchor, constant: gap),
            guideControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            guideControl.heightAnchor.constraint(equalToConstant: controlHeight),
            
            historyControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            historyControl.topAnchor.constraint(equalTo: guideControl.bottomAnchor, constant: gap),
            historyControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            historyControl.heightAnchor.constraint(equalToConstant: controlHeight)
        ])
    }
    
    // MARK: - Entrance Animation
    private func triggerEntrance() {
        MotionEngine.popIn(element: launchControl, pause: 0.2)
        MotionEngine.popIn(element: guideControl, pause: 0.35)
        MotionEngine.popIn(element: historyControl, pause: 0.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            MotionEngine.breathe(element: self.launchControl)
        }
    }
    
    // MARK: - Action Handlers
    @objc private func handleLaunch() {
        let picker = ModePickerPanel()
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }
    
    @objc private func handleGuide() {
        let tutorial = TutorialDisplay()
        tutorial.modalPresentationStyle = .fullScreen
        present(tutorial, animated: true)
    }
    
    @objc private func handleHistory() {
        let vault = RecordVault()
        vault.modalPresentationStyle = .fullScreen
        present(vault, animated: true)
    }
}
