import Foundation

struct Group: Identifiable, Decodable {
    let id: UUID
    let name: String
    let balance: Double
    let fairnessScore: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case balance
        case fairnessScore = "fairness_score"
    }
}
