import Foundation

struct ParticipantSplit: Identifiable, Decodable {
    let id = UUID() // local-only for SwiftUI lists
    let name: String
    let amount: Double
}
