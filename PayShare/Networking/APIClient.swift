import Foundation

final class APIClient {

    static let shared = APIClient()

    private init() {
        self.authToken = KeychainService.loadToken()
    }

    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    // MARK: - Auth Token

    private(set) var authToken: String?

    // MARK: - Helper (AUTHORIZED REQUEST)

    private func authorizedRequest(
        path: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) throws -> URLRequest {

        guard let token = authToken else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = baseURL.appending(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    // MARK: - Login

    func login(email: String, password: String) async throws -> String {

        let url = baseURL.appending(path: "/auth/login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "email": email,
            "password": password
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let token = json?["access_token"] as? String ?? ""

        self.authToken = token
        KeychainService.saveToken(token)

        return token
    }

    // MARK: - Logout

    func logout() {
        authToken = nil
        KeychainService.deleteToken()
    }

    // MARK: - Fetch Current User

    func fetchMe() async throws -> User {

        var request = try authorizedRequest(path: "/me")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(User.self, from: data)
    }

    // MARK: - Groups

    func fetchGroups() async throws -> [Group] {

        var request = try authorizedRequest(path: "/groups")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Group].self, from: data)
    }

    func createGroup(name: String) async throws {

        var request = try authorizedRequest(
            path: "/groups",
            method: "POST",
            body: ["name": name]
        )

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Expenses

    func fetchGroupExpenses(groupId: UUID) async throws -> [Expense] {

        var request = try authorizedRequest(
            path: "/groups/\(groupId.uuidString)/expenses"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([Expense].self, from: data)
    }

    func createExpense(
        groupId: UUID,
        title: String,
        totalAmount: Double,
        paidBy: String
    ) async throws {

        var request = try authorizedRequest(
            path: "/expenses",
            method: "POST",
            body: [
                "group_id": groupId.uuidString,
                "title": title,
                "total_amount": totalAmount,
                "paid_by": paidBy,
                "splits": [
                    ["name": paidBy, "amount": totalAmount]
                ]
            ]
        )

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Fairness

    func fetchGroupFairness(groupId: UUID) async throws -> FairnessResponse {

        var request = try authorizedRequest(
            path: "/groups/\(groupId.uuidString)/fairness"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(FairnessResponse.self, from: data)
    }

    // MARK: - Settlements

    func fetchGroupSettlements(groupId: UUID) async throws -> [SplitResult] {

        var request = try authorizedRequest(
            path: "/groups/\(groupId.uuidString)/settlements"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([SplitResult].self, from: data)
    }
}
