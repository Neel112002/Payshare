import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: "http://127.0.0.1:8000")! // change later for prod

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
}
