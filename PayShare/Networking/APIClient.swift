import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    var onUnauthorized: (() -> Void)?
    
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
    
    // MARK: - Logout
    
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
    
    // MARK: - Groups
    
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
    
    // MARK: - Expenses
    
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
        
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

            if let date = formatter.date(from: dateStr) {
                return date
            }

            // fallback without microseconds
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            if let date = formatter.date(from: dateStr) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateStr)"
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
        
        let request = try authorizedRequest(
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
        checkForUnauthorized(response)
        
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
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
        checkForUnauthorized(response)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func checkForUnauthorized(_ response: URLResponse) {
        if let http = response as? HTTPURLResponse,
           http.statusCode == 401 {

            self.logout()            // clear token
            onUnauthorized?()        // tell AppState
        }
    }
    
    // MARK: - Forgot Password

    func forgotPassword(email: String) async throws -> String {

        let url = baseURL.appending(path: "/auth/forgot-password")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "email": email
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        checkForUnauthorized(response)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let token = json?["reset_token"] as? String ?? ""

        print("🔐 Reset token received:", token)

        return token
    }


    // MARK: - Reset Password

    func resetPassword(token: String, newPassword: String) async throws {
        
        print("📤 Sending reset token:", token)
        
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
}

