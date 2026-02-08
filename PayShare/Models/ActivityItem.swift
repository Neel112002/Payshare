import Foundation

struct ActivityItem: Identifiable {
    let id: UUID
    let groupId: UUID
    let groupName: String
    let title: String
    let amount: Double
    let paidBy: String
    let createdAt: Date
}

