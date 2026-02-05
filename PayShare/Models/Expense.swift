import Foundation

struct Expense: Identifiable, Decodable {
    let id: UUID
    let title: String
    let totalAmount: Double
    let paidBy: String
    let createdAt: Date
    let splits: [ParticipantSplit]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case totalAmount = "total_amount"
        case paidBy = "paid_by"
        case createdAt = "created_at"
        case splits
    }
}
