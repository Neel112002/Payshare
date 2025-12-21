import Foundation

struct Expense: Identifiable {
    let id: UUID
    let groupName: String
    let title: String
    let totalAmount: Double
    let paidBy: String
    let splits: [ParticipantSplit]
    let createdAt: Date
}
