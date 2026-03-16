import Foundation
import SwiftData

@Model
final class FavoritesRingoSPinner {
    var id: UUID
    var type: String
    var itemId: String

    init(
        id: UUID = UUID(),
        type: String = "",
        itemId: String = ""
    ) {
        self.id = id
        self.type = type
        self.itemId = itemId
    }
}
