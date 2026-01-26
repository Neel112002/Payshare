import Foundation

struct Expense: Identifiable, Decodable {
    let id: UUID
    let groupId: UUID
    let title: String
    let totalAmount: Double
    let paidBy: String
    let createdAt: Date
    let splits: [ParticipantSplit]
}
