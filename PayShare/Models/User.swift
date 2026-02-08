import Foundation

struct User: Identifiable, Decodable {
    let id: UUID
    let name: String
    let email: String
    let currency: String
}
