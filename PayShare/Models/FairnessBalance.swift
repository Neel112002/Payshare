import Foundation

struct FairnessBalance: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let balance: Double
}
