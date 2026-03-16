import Foundation
import SwiftData

@Model
final class TaskRingoSPinner {
    var id: UUID
    var title: String
    var taskDescription: String
    var steps: [String]
    var isCompleted: Bool
    var completionDate: Date?

    init(
        id: UUID = UUID(),
        title: String = "",
        taskDescription: String = "",
        steps: [String] = [],
        isCompleted: Bool = false,
        completionDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.steps = steps
        self.isCompleted = isCompleted
        self.completionDate = completionDate
    }
}
