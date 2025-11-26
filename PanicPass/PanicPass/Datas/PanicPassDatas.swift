//
//  PanicPassDatas.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

// MARK: - Mahjong Tile Model
struct TileEntity {
    var illustration: UIImage
    var magnitude: Int
    var category: TileCategory
    
    enum TileCategory: String {
        case bamboo = "PassA"
        case character = "PassB"
        case dot = "PassC"
    }
}

// MARK: - Game Record Model
struct GameArchive: Codable {
    var identifier: String
    var accomplishment: Int
    var timestamp: Date
    var duration: TimeInterval
    var modeName: String
    
    init(accomplishment: Int, duration: TimeInterval, modeName: String = "Classic") {
        self.identifier = UUID().uuidString
        self.accomplishment = accomplishment
        self.timestamp = Date()
        self.duration = duration
        self.modeName = modeName
    }
}

// MARK: - Data Repository
class TileRepository {
    static let shared = TileRepository()
    
    var allTileEntities: [TileEntity] = []
    
    init() {
        configureTileCollection()
    }
    
    func configureTileCollection() {
        let categories: [(TileEntity.TileCategory, String)] = [
            (.bamboo, "PassA"),
            (.character, "PassB"),
            (.dot, "PassC")
        ]
        
        for (category, prefix) in categories {
            for magnitude in 1...9 {
                if let illustration = UIImage(named: "\(prefix) \(magnitude)") {
                    let tile = TileEntity(illustration: illustration, magnitude: magnitude, category: category)
                    allTileEntities.append(tile)
                }
            }
        }
    }
    
    func fetchRandomTiles(quantity: Int) -> [TileEntity] {
        var selectedTiles: [TileEntity] = []
        for _ in 0..<quantity {
            if let randomTile = allTileEntities.randomElement() {
                selectedTiles.append(randomTile)
            }
        }
        return selectedTiles
    }
    
    func fetchTilesByMagnitude(_ magnitude: Int) -> [TileEntity] {
        return allTileEntities.filter { $0.magnitude == magnitude }
    }
}

// MARK: - Archive Manager
class ArchiveKeeper {
    static let shared = ArchiveKeeper()
    let archiveKey = "MahjongGameArchives"
    
    func preserveArchive(_ archive: GameArchive) {
        var archives = retrieveAllArchives()
        archives.insert(archive, at: 0)
        
        if let encoded = try? JSONEncoder().encode(archives) {
            UserDefaults.standard.set(encoded, forKey: archiveKey)
        }
    }
    
    func retrieveAllArchives() -> [GameArchive] {
        guard let data = UserDefaults.standard.data(forKey: archiveKey),
              let archives = try? JSONDecoder().decode([GameArchive].self, from: data) else {
            return []
        }
        return archives
    }
    
    func removeArchive(identifier: String) {
        var archives = retrieveAllArchives()
        archives.removeAll { $0.identifier == identifier }
        
        if let encoded = try? JSONEncoder().encode(archives) {
            UserDefaults.standard.set(encoded, forKey: archiveKey)
        }
    }
    
    func obliterateAllArchives() {
        UserDefaults.standard.removeObject(forKey: archiveKey)
    }
}
