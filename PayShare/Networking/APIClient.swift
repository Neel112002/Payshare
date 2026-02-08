import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: "http://localhost:8000")!

    // MARK: - Login

    func login(email: String, password: String) async throws -> String {
        let url = baseURL.appending(path: "/auth/login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "email": email,
            "password": password
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["access_token"] as? String ?? ""
    }

    // MARK: - Fetch Groups ✅ NEW

    func fetchGroups() async throws -> [Group] {
        let url = baseURL.appending(path: "/groups")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([Group].self, from: data)
    }
    
    // MARK: - Create Group

    // MARK: - Create Group

    func createGroup(name: String) async throws {
        let url = baseURL.appending(path: "/groups")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "name": name
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func fetchGroupExpenses(groupId: UUID) async throws -> [Expense] {
        let url = baseURL.appending(path: "/groups/\(groupId.uuidString)/expenses")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()

        // 🔒 Robust date decoding (ISO8601 + FastAPI microseconds)
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // 1️⃣ Try ISO8601 with fractional seconds + timezone
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            // 2️⃣ Try FastAPI default (NO timezone, microseconds)
            let fastAPIDateFormatter = DateFormatter()
            fastAPIDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            fastAPIDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            fastAPIDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

            if let date = fastAPIDateFormatter.date(from: dateString) {
                return date
            }

            // ❌ If both fail, crash loudly (correct behavior)
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format: \(dateString)"
            )
        }

        return try decoder.decode([Expense].self, from: data)
    }


    // MARK: - Fetch Group Fairness

    func fetchGroupFairness(groupId: UUID) async throws -> FairnessResponse {
        let url = baseURL.appending(path: "/groups/\(groupId.uuidString)/fairness")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(FairnessResponse.self, from: data)
    }

    // MARK: - Fetch Group Settlements

    func fetchGroupSettlements(groupId: UUID) async throws -> [SplitResult] {
        let url = baseURL.appending(path: "/groups/\(groupId.uuidString)/settlements")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([SplitResult].self, from: data)
    }

    // MARK: - Create Expense

    func createExpense(
        groupId: UUID,
        title: String,
        totalAmount: Double,
        paidBy: String
    ) async throws {

        let url = baseURL.appending(path: "/expenses")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "group_id": groupId.uuidString,
            "title": title,
            "total_amount": totalAmount,
            "paid_by": paidBy,
            "splits": [
                [
                    "name": paidBy,
                    "amount": totalAmount
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
