//
//  TutorialDisplay.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class TutorialDisplay: ScreenBase {
    
    var scrollPane: UIScrollView!
    var contentBox: UIView!
    
    override func viewDidLoad() {
        headingContent = ""
        headingSize = 20
        
        super.viewDidLoad()
        
        buildScrollArea()
        arrangeScrollArea()
        fillContent()
    }
    
    private func buildScrollArea() {
        scrollPane = UIScrollView()
        scrollPane.backgroundColor = .clear
        scrollPane.showsVerticalScrollIndicator = true
        scrollPane.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollPane)
        
        contentBox = UIView()
        contentBox.translatesAutoresizingMaskIntoConstraints = false
        scrollPane.addSubview(contentBox)
    }
    
    private func arrangeScrollArea() {
        NSLayoutConstraint.activate([
            scrollPane.topAnchor.constraint(equalTo: headingDisplay.bottomAnchor, constant: 50),
            scrollPane.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollPane.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollPane.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            contentBox.topAnchor.constraint(equalTo: scrollPane.topAnchor),
            contentBox.leadingAnchor.constraint(equalTo: scrollPane.leadingAnchor),
            contentBox.trailingAnchor.constraint(equalTo: scrollPane.trailingAnchor),
            contentBox.bottomAnchor.constraint(equalTo: scrollPane.bottomAnchor),
            contentBox.widthAnchor.constraint(equalTo: scrollPane.widthAnchor)
        ])
    }
    
    private func fillContent() {
        let sections = [
            ("Game Objective", "Match mahjong tiles with the numbers in moving slots!"),
            ("How to Play", "• Slots move from right to left\n• Each slot shows a number (1-9)\n• Tap matching mahjong tile from bottom\n• Highlighted slot is your current target"),
            ("Scoring Rules", "• Each correct match: 10 points\n• Wrong selections flash red\n• Speed increases every 30 seconds")
        ]
        
        var lastView: UIView? = nil
        
        for (idx, (title, desc)) in sections.enumerated() {
            let card = createInfoCard(title: title, description: desc)
            card.translatesAutoresizingMaskIntoConstraints = false
            contentBox.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: contentBox.leadingAnchor),
                card.trailingAnchor.constraint(equalTo: contentBox.trailingAnchor)
            ])
            
            if let previous = lastView {
                card.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: contentBox.topAnchor, constant: 10).isActive = true
            }
            
            lastView = card
            
            if idx == sections.count - 1 {
                card.bottomAnchor.constraint(equalTo: contentBox.bottomAnchor, constant: -20).isActive = true
            }
        }
    }
    
    private func createInfoCard(title: String, description: String) -> UIView {
        let card = UIView()
        StyleConfig.shared.styleAsSurface(card)
        
        let heading = UILabel()
        heading.text = title
        heading.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        heading.textColor = StyleConfig.Palette.accent
        heading.numberOfLines = 0
        heading.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(heading)
        
        let body = UILabel()
        body.text = description
        body.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        body.textColor = .white
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(body)
        
        NSLayoutConstraint.activate([
            heading.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
            heading.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            heading.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            
            body.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 10),
            body.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            body.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            body.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15)
        ])
        
        return card
    }
}

