import Foundation
import SwiftData

@Model
final class SimulatorSessionRingoSPinner {
    var id: UUID
    var angle: Double
    var power: Double
    var distance: Double
    var successRate: Double
    var date: Date

    init(
        id: UUID = UUID(),
        angle: Double = 45.0,
        power: Double = 50.0,
        distance: Double = 3.0,
        successRate: Double = 0.0,
        date: Date = .now
    ) {
        self.id = id
        self.angle = angle
        self.power = power
        self.distance = distance
        self.successRate = successRate
        self.date = date
    }
}
