import Foundation
import SwiftData

@Model
final class UserRingoSPinner {
    var id: UUID
    var name: String
    var selectedTheme: String
    var totalScore: Int
    var completedTasks: Int
    var favoriteItems: [String]

    init(
        id: UUID = UUID(),
        name: String = "Athlete",
        selectedTheme: String = "default",
        totalScore: Int = 0,
        completedTasks: Int = 0,
        favoriteItems: [String] = []
    ) {
        self.id = id
        self.name = name
        self.selectedTheme = selectedTheme
        self.totalScore = totalScore
        self.completedTasks = completedTasks
        self.favoriteItems = favoriteItems
    }
}
