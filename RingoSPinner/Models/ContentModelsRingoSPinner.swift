import Foundation

struct ArticleContentRingoSPinner: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let category: String
    let icon: String
}

struct TaskContentRingoSPinner: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let steps: [String]
    let difficulty: String
    let icon: String
}

struct MiniGameContentRingoSPinner: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let difficulty: String
}

struct TipContentRingoSPinner: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let category: String
}

struct JSONLoaderRingoSPinner {
    static func load<T: Decodable>(_ filename: String) -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Could not find \(filename).json in bundle")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(filename).json")
        }
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Could not decode \(filename).json")
        }
        return decoded
    }
}
