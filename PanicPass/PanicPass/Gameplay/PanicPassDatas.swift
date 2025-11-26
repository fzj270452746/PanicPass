//
//  DataModels.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

// MARK: - Game Piece Model
struct GamePiece {
    var visual: UIImage
    var value: Int
    var family: PieceFamily
    
    enum PieceFamily: String {
        case bamboo = "PassA"
        case character = "PassB"
        case dot = "PassC"
    }
}

// MARK: - Session Record Model
struct SessionRecord: Codable {
    var id: String
    var points: Int
    var timestamp: Date
    var span: TimeInterval
    var styleName: String
    
    init(points: Int, span: TimeInterval, styleName: String = "Relaxed") {
        self.id = UUID().uuidString
        self.points = points
        self.timestamp = Date()
        self.span = span
        self.styleName = styleName
    }
}

// MARK: - Piece Source
class PieceSource {
    static let shared = PieceSource()
    
    var allPieces: [GamePiece] = []
    
    init() {
        loadCollection()
    }
    
    func loadCollection() {
        let families: [(GamePiece.PieceFamily, String)] = [
            (.bamboo, "PassA"),
            (.character, "PassB"),
            (.dot, "PassC")
        ]
        
        for (family, prefix) in families {
            for val in 1...9 {
                if let visual = UIImage(named: "\(prefix) \(val)") {
                    let piece = GamePiece(visual: visual, value: val, family: family)
                    allPieces.append(piece)
                }
            }
        }
    }
    
    func randomPieces(count: Int) -> [GamePiece] {
        var selection: [GamePiece] = []
        for _ in 0..<count {
            if let piece = allPieces.randomElement() {
                selection.append(piece)
            }
        }
        return selection
    }
    
    func piecesByValue(_ val: Int) -> [GamePiece] {
        return allPieces.filter { $0.value == val }
    }
}

// MARK: - Record Keeper
class RecordKeeper {
    static let shared = RecordKeeper()
    let storageKey = "GameSessionRecords"
    
    func storeRecord(_ record: SessionRecord) {
        var records = loadAllRecords()
        records.insert(record, at: 0)
        
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func loadAllRecords() -> [SessionRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let records = try? JSONDecoder().decode([SessionRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    func deleteRecord(id: String) {
        var records = loadAllRecords()
        records.removeAll { $0.id == id }
        
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func clearAllRecords() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
