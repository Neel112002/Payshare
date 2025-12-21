import Foundation

struct SplitResult {
    let total: Double
    let splits: [ParticipantSplit]
}

struct ParticipantSplit: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}
