import Foundation

struct SplitResult: Identifiable, Decodable {
    let id = UUID()
    let from: String
    let to: String
    let amount: Double
}
