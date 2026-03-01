import Foundation

struct Expense: Codable, Identifiable {
    let id: UUID
    let title: String
    let totalAmount: Double
    let paidBy: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case totalAmount = "total_amount"
        case paidBy = "paid_by"
        case createdAt = "created_at"
    }
}
