import Foundation

struct FairnessResponse: Decodable {
    let score: Int
    let balances: [String: Double]
}
