import Foundation
import SwiftData

@Model
final class MiniGameScoreRingoSPinner {
    var id: UUID
    var gameName: String
    var score: Int
    var bestScore: Int
    var date: Date

    init(
        id: UUID = UUID(),
        gameName: String = "",
        score: Int = 0,
        bestScore: Int = 0,
        date: Date = .now
    ) {
        self.id = id
        self.gameName = gameName
        self.score = score
        self.bestScore = bestScore
        self.date = date
    }
}
