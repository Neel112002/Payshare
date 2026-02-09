import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: "http://localhost:8000")!

    // MARK: - Auth Token (TEMP – later move to Keychain)
    var authToken: String?

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
        let token = json?["access_token"] as? String ?? ""

        self.authToken = token
        return token
    }

    // MARK: - Fetch Current User (/me)

    func fetchMe() async throws -> User {
        let url = baseURL.appending(path: "/me")

        guard let token = authToken else {
            throw URLError(.userAuthenticationRequired)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(User.self, from: data)
    }

    // MARK: - Groups

    func fetchGroups() async throws -> [Group] {
        let url = baseURL.appending(path: "/groups")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Group] .self, from: data)
    }

    func createGroup(name: String) async throws {
        let url = baseURL.appending(path: "/groups")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "name": name
        ])

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Expenses

    func fetchGroupExpenses(groupId: UUID) async throws -> [Expense] {
        let url = baseURL.appending(path: "/groups/\(groupId.uuidString)/expenses")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso.date(from: dateString) {
                return date
            }

            let fallback = DateFormatter()
            fallback.locale = Locale(identifier: "en_US_POSIX")
            fallback.timeZone = TimeZone(secondsFromGMT: 0)
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = fallback.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateString)"
            )
        }

        return try decoder.decode([Expense].self, from: data)
    }

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

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "group_id": groupId.uuidString,
            "title": title,
            "total_amount": totalAmount,
            "paid_by": paidBy,
            "splits": [
                ["name": paidBy, "amount": totalAmount]
            ]
        ])

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Fairness

    func fetchGroupFairness(groupId: UUID) async throws -> FairnessResponse {
        let url = baseURL.appending(path: "/groups/\(groupId.uuidString)/fairness")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(FairnessResponse.self, from: data)
    }

    // MARK: - Settlements

    func fetchGroupSettlements(groupId: UUID) async throws -> [SplitResult] {
        let url = baseURL.appending(path: "/groups/\(groupId.uuidString)/settlements")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([SplitResult].self, from: data)
    }
}
