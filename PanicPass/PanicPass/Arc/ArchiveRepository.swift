//
//  ArchiveRepository.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class ArchiveRepository: UIViewController {
    
    var backgroundIllustration: UIImageView!
    var dimmerOverlay: UIView!
    var retreatButton: UIButton!
    var titleEmblem: UILabel!
    var catalogTable: UITableView!
    var emptyPlaceholder: UILabel!
    var obliterateAllButton: UIButton!
    
    var archiveCollection: [GameArchive] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        orchestrateLayout()
        retrieveArchives()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveArchives()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func retrieveArchives() {
        archiveCollection = ArchiveKeeper.shared.retrieveAllArchives()
        catalogTable.reloadData()
        
        emptyPlaceholder.isHidden = !archiveCollection.isEmpty
        obliterateAllButton.isHidden = archiveCollection.isEmpty
    }
}

