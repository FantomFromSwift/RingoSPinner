import Foundation
import SwiftData

@Model
final class ArticleRingoSPinner {
    var id: UUID
    var title: String
    var content: String
    var category: String

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        category: String = ""
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
    }
}
