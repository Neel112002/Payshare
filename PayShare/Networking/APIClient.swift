import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    var onUnauthorized: (() -> Void)?
    
    private init() {
        self.authToken = KeychainService.loadToken()
    }
    
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    
    private(set) var authToken: String?
    
    // MARK: - Authorized Request
    
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
        checkForUnauthorized(response)
        
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
    
    func logout() {
        authToken = nil
        KeychainService.deleteToken()
    }
    
    // MARK: - Fetch Current User

    func fetchMe() async throws -> User {
        
        let request = try authorizedRequest(path: "/me")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    // MARK: - Fetch Groups
    
    func fetchGroups() async throws -> [Group] {
        let request = try authorizedRequest(path: "/groups/")
        let (data, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Group].self, from: data)
    }
    
    func createGroup(name: String) async throws {
        let request = try authorizedRequest(
            path: "/groups/",
            method: "POST",
            body: ["name": name]
        )
        
        let (_, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Fetch Expenses
    
    func fetchGroupExpenses(groupId: UUID) async throws -> [Expense] {
        
        let request = try authorizedRequest(
            path: "/expenses/group/\(groupId.uuidString)"
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Expense].self, from: data)
    }
    
    // MARK: - Create Expense (UPDATED UUID VERSION)
    
    func createExpense(
        groupId: UUID,
        title: String,
        totalAmount: Double,
        paidBy: UUID,
        splits: [(userId: UUID, amount: Double)]
    ) async throws {
        
        let splitsBody = splits.map {
            [
                "user_id": $0.userId.uuidString,
                "amount": $0.amount
            ]
        }
        
        let request = try authorizedRequest(
            path: "/expenses",
            method: "POST",
            body: [
                "group_id": groupId.uuidString,
                "title": title,
                "total_amount": totalAmount,
                "paid_by": paidBy.uuidString,
                "splits": splitsBody
            ]
        )
        
        let (_, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Fairness
    
    func fetchGroupFairness(groupId: UUID) async throws -> FairnessResponse {
        
        let request = try authorizedRequest(
            path: "/groups/\(groupId.uuidString)/fairness"
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(FairnessResponse.self, from: data)
    }
    
    // MARK: - Settlements
    
    func fetchGroupSettlements(groupId: UUID) async throws -> [SplitResult] {
        
        let request = try authorizedRequest(
            path: "/groups/\(groupId.uuidString)/settlements"
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([SplitResult].self, from: data)
    }
    
    private func checkForUnauthorized(_ response: URLResponse) {
        if let http = response as? HTTPURLResponse,
           http.statusCode == 401 {
            self.logout()
            onUnauthorized?()
        }
    }
    // MARK: - Update Profile

    func updateProfile(name: String, email: String) async throws -> User {

        let request = try authorizedRequest(
            path: "/auth/update-profile",
            method: "PUT",
            body: [
                "name": name,
                "email": email
            ]
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(User.self, from: data)
    }
    // MARK: - Change Password

    func changePassword(currentPassword: String, newPassword: String) async throws {

        let request = try authorizedRequest(
            path: "/auth/change-password",
            method: "POST",
            body: [
                "current_password": currentPassword,
                "new_password": newPassword
            ]
        )

        let (_, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    // MARK: - Forgot Password

    func forgotPassword(email: String) async throws {

        let url = baseURL.appending(path: "/auth/forgot-password")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "email": email
        ])

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    // MARK: - Delete Account

    func deleteAccount() async throws {

        let request = try authorizedRequest(
            path: "/auth/delete-account",
            method: "DELETE"
        )

        let (_, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Reset Password

    func resetPassword(token: String, newPassword: String) async throws {

        let url = baseURL.appending(path: "/auth/reset-password")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "token": token,
            "new_password": newPassword
        ])

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Register

    func register(name: String, email: String, password: String) async throws {

        let url = baseURL.appending(path: "/auth/register")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "name": name,
            "email": email,
            "password": password
        ])

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
