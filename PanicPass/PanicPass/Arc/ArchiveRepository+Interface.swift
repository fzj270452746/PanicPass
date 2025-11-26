//
//  ArchiveRepository+Interface.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

extension ArchiveRepository {
    
    func configureInterface() {
        // Background
        backgroundIllustration = UIImageView()
        backgroundIllustration.image = UIImage(named: "passPhoto")
        backgroundIllustration.contentMode = .scaleAspectFill
        backgroundIllustration.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundIllustration)
        
        // Dimmer with gradient
        dimmerOverlay = UIView()
        dimmerOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmerOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmerOverlay)
        
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.view.bounds
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.35).cgColor,
                UIColor.black.withAlphaComponent(0.6).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
            self.dimmerOverlay.layer.addSublayer(gradientLayer)
        }
        
        // Retreat button
        retreatButton = fabricateRetreatButton()
        retreatButton.addTarget(self, action: #selector(executeRetreat), for: .touchUpInside)
        view.addSubview(retreatButton)
        
        // Title
        titleEmblem = UILabel()
        titleEmblem.text = ""
        titleEmblem.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        titleEmblem.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleEmblem.textAlignment = .center
        titleEmblem.layer.shadowColor = UIColor.black.cgColor
        titleEmblem.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleEmblem.layer.shadowRadius = 4
        titleEmblem.layer.shadowOpacity = 0.6
        titleEmblem.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleEmblem)
        
        // Table view
        catalogTable = UITableView(frame: .zero, style: .plain)
        catalogTable.backgroundColor = .clear
        catalogTable.separatorStyle = .none
        catalogTable.delegate = self
        catalogTable.dataSource = self
        catalogTable.register(ArchiveCell.self, forCellReuseIdentifier: "ArchiveCell")
        catalogTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(catalogTable)
        
        // Empty placeholder
        emptyPlaceholder = UILabel()
        emptyPlaceholder.text = "No game records yet\n\nStart playing to create your first record and track your progress!"
        emptyPlaceholder.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        emptyPlaceholder.textColor = UIColor.white.withAlphaComponent(0.85)
        emptyPlaceholder.textAlignment = .center
        emptyPlaceholder.numberOfLines = 0
        emptyPlaceholder.isHidden = true
        emptyPlaceholder.layer.shadowColor = UIColor.black.cgColor
        emptyPlaceholder.layer.shadowOffset = CGSize(width: 0, height: 2)
        emptyPlaceholder.layer.shadowRadius = 3
        emptyPlaceholder.layer.shadowOpacity = 0.5
        emptyPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyPlaceholder)
        
        // Obliterate all button
        obliterateAllButton = UIButton(type: .system)
        obliterateAllButton.setTitle("Delete All Records", for: .normal)
        obliterateAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        obliterateAllButton.setTitleColor(.white, for: .normal)
        obliterateAllButton.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.95)
        obliterateAllButton.layer.cornerRadius = 25
        obliterateAllButton.layer.borderWidth = 2
        obliterateAllButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        obliterateAllButton.layer.shadowColor = UIColor.black.cgColor
        obliterateAllButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        obliterateAllButton.layer.shadowRadius = 8
        obliterateAllButton.layer.shadowOpacity = 0.4
        obliterateAllButton.addTarget(self, action: #selector(obliterateAllArchives), for: .touchUpInside)
        obliterateAllButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(obliterateAllButton)
    }
    
    func fabricateRetreatButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("◀ BACK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func orchestrateLayout() {
        NSLayoutConstraint.activate([
            // Background
            backgroundIllustration.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundIllustration.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundIllustration.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundIllustration.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Dimmer
            dimmerOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            dimmerOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmerOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmerOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Retreat button
            retreatButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            retreatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            retreatButton.widthAnchor.constraint(equalToConstant: 100),
            retreatButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Title
            titleEmblem.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleEmblem.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Table
            catalogTable.topAnchor.constraint(equalTo: titleEmblem.bottomAnchor, constant: 50),
            catalogTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            catalogTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            catalogTable.bottomAnchor.constraint(equalTo: obliterateAllButton.topAnchor, constant: -20),
            
            // Empty placeholder
            emptyPlaceholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPlaceholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Obliterate button
            obliterateAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            obliterateAllButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            obliterateAllButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            obliterateAllButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func executeRetreat() {
        dismiss(animated: true)
    }
    
    @objc func obliterateAllArchives() {
        let alert = UIAlertController(
            title: "🗑️ Delete All Records?",
            message: "Are you sure you want to delete all \(archiveCollection.count) game records?\n\nThis action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive) { _ in
            ArchiveKeeper.shared.obliterateAllArchives()
            self.retrieveArchives()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegates
extension ArchiveRepository: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archiveCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveCell", for: indexPath) as! ArchiveCell
        let archive = archiveCollection[indexPath.row]
        cell.configureWithArchive(archive, index: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let archive = archiveCollection[indexPath.row]
            ArchiveKeeper.shared.removeArchive(identifier: archive.identifier)
            retrieveArchives()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - Archive Cell
class ArchiveCell: UITableViewCell {
    
    var containerVessel: UIView!
    var rankLabel: UILabel!
    var scoreLabel: UILabel!
    var dateLabel: UILabel!
    var durationLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCellInterface() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerVessel = UIView()
        containerVessel.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        containerVessel.layer.cornerRadius = 16
        containerVessel.layer.borderWidth = 1.5
        containerVessel.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        containerVessel.layer.shadowColor = UIColor.black.cgColor
        containerVessel.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerVessel.layer.shadowRadius = 5
        containerVessel.layer.shadowOpacity = 0.3
        containerVessel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerVessel)
        
        rankLabel = UILabel()
        rankLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        rankLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        containerVessel.addSubview(rankLabel)
        
        scoreLabel = UILabel()
        scoreLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        scoreLabel.textColor = .white
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        containerVessel.addSubview(scoreLabel)
        
        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerVessel.addSubview(dateLabel)
        
        durationLabel = UILabel()
        durationLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        durationLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        containerVessel.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            containerVessel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerVessel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerVessel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerVessel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rankLabel.leadingAnchor.constraint(equalTo: containerVessel.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: containerVessel.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            scoreLabel.topAnchor.constraint(equalTo: containerVessel.topAnchor, constant: 15),
            
            dateLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            durationLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            durationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3)
        ])
    }
    
    func configureWithArchive(_ archive: GameArchive, index: Int) {
        rankLabel.text = "\(index)"
        
        // 显示模式标签
        let modeEmoji = archive.modeName == "Speed Rush" ? "" : ""
        scoreLabel.text = "\(modeEmoji) \(archive.modeName) - Score: \(archive.accomplishment)"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: archive.timestamp)
        
        let minutes = Int(archive.duration) / 60
        let seconds = Int(archive.duration) % 60
        durationLabel.text = String(format: "Duration: %02d:%02d", minutes, seconds)
    }
}

