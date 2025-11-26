//
//  RecordVault.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class RecordVault: ScreenBase {
    
    var listView: UITableView!
    var emptyNotice: UILabel!
    var clearAllControl: UIButton!
    
    var recordCollection: [SessionRecord] = []
    
    override func viewDidLoad() {
        headingContent = ""
        headingSize = 34
        
        super.viewDidLoad()
        
        buildListUI()
        arrangeListLayout()
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    private func buildListUI() {
        // List view
        listView = UITableView(frame: .zero, style: .plain)
        listView.backgroundColor = .clear
        listView.separatorStyle = .none
        listView.delegate = self
        listView.dataSource = self
        listView.register(RecordCell.self, forCellReuseIdentifier: "RecordCell")
        listView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listView)
        
        // Empty state notice
        emptyNotice = UILabel()
        emptyNotice.text = "No game records yet\n\nStart playing to create your first record and track your progress!"
        emptyNotice.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        emptyNotice.textColor = UIColor.white.withAlphaComponent(0.85)
        emptyNotice.textAlignment = .center
        emptyNotice.numberOfLines = 0
        emptyNotice.isHidden = true
        emptyNotice.layer.shadowColor = UIColor.black.cgColor
        emptyNotice.layer.shadowOffset = CGSize(width: 0, height: 2)
        emptyNotice.layer.shadowRadius = 3
        emptyNotice.layer.shadowOpacity = 0.5
        emptyNotice.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyNotice)
        
        // Clear all button
        clearAllControl = UIButton(type: .system)
        clearAllControl.setTitle("Delete All Records", for: .normal)
        clearAllControl.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        clearAllControl.setTitleColor(.white, for: .normal)
        clearAllControl.backgroundColor = StyleConfig.Palette.negative.withAlphaComponent(0.95)
        clearAllControl.layer.cornerRadius = 24
        clearAllControl.layer.borderWidth = 2
        clearAllControl.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        clearAllControl.layer.shadowColor = UIColor.black.cgColor
        clearAllControl.layer.shadowOffset = CGSize(width: 0, height: 4)
        clearAllControl.layer.shadowRadius = 8
        clearAllControl.layer.shadowOpacity = 0.4
        clearAllControl.addTarget(self, action: #selector(handleClearAll), for: .touchUpInside)
        clearAllControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearAllControl)
    }
    
    private func arrangeListLayout() {
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: headingDisplay.bottomAnchor, constant: 50),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            listView.bottomAnchor.constraint(equalTo: clearAllControl.topAnchor, constant: -20),
            
            emptyNotice.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyNotice.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyNotice.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyNotice.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            clearAllControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            clearAllControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearAllControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            clearAllControl.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func refreshData() {
        recordCollection = RecordKeeper.shared.loadAllRecords()
        listView.reloadData()
        
        emptyNotice.isHidden = !recordCollection.isEmpty
        clearAllControl.isHidden = recordCollection.isEmpty
    }
    
    @objc private func handleClearAll() {
        let prompt = UIAlertController(
            title: "🗑️ Delete All Records?",
            message: "Are you sure you want to delete all \(recordCollection.count) game records?\n\nThis action cannot be undone.",
            preferredStyle: .alert
        )
        
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        prompt.addAction(UIAlertAction(title: "Delete All", style: .destructive) { _ in
            RecordKeeper.shared.clearAllRecords()
            self.refreshData()
        })
        
        present(prompt, animated: true)
    }
}

// MARK: - TableView Implementation
extension RecordVault: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordCell
        let record = recordCollection[indexPath.row]
        cell.populate(with: record, rank: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = recordCollection[indexPath.row]
            RecordKeeper.shared.deleteRecord(id: record.id)
            refreshData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - Record Cell
class RecordCell: UITableViewCell {
    
    var container: UIView!
    var rankLabel: UILabel!
    var scoreLabel: UILabel!
    var dateLabel: UILabel!
    var timeLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        container = UIView()
        StyleConfig.shared.styleAsSurface(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        rankLabel = UILabel()
        rankLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        rankLabel.textColor = StyleConfig.Palette.accent
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(rankLabel)
        
        scoreLabel = UILabel()
        scoreLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        scoreLabel.textColor = .white
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(scoreLabel)
        
        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dateLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rankLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            scoreLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            
            dateLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            timeLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3)
        ])
    }
    
    func populate(with record: SessionRecord, rank: Int) {
        rankLabel.text = "\(rank)"
        
        let icon = record.styleName == "Intense" ? "⚡" : "🎯"
        scoreLabel.text = "\(icon) \(record.styleName) - Score: \(record.points)"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: record.timestamp)
        
        let mins = Int(record.span) / 60
        let secs = Int(record.span) % 60
        timeLabel.text = String(format: "Duration: %02d:%02d", mins, secs)
    }
}

