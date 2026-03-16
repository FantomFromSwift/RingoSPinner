import SwiftUI

struct AssetMapperRingoSPinner {
    static func getIcon(for id: String, category: String? = nil) -> String {
        
        if let cat = category {
            switch cat {
            case "Reaction Training": return "art_reaction"
            case "Motor Control": return "art_motor"
            case "Throw Physics": return "art_physics"
            case "Focus Training": return "art_focus"
            case "Dexterity": return "art_dexterity"
            default: break
            }
        }
        
        
        let digits = id.filter { "0123456789".contains($0) }
        let names = ["elOne", "elTwo", "elThree", "elFour", "elFive", "elSix", "elSeven", "elEight", "elNine"]
        
        if let num = Int(digits), num > 0 {
            let index = (num - 1) % names.count
            return names[index]
        }
        
        return names[0]
    }
}
