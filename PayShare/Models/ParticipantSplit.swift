import Foundation

struct ParticipantSplit: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let amount: Double
}
