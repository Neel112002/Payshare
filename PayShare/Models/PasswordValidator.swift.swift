import Foundation

struct PasswordRule: Identifiable {
    let id = UUID()
    let description: String
    let isValid: Bool
}

struct PasswordValidator {
    
    static func validate(_ password: String) -> [PasswordRule] {
        
        return [
            PasswordRule(
                description: "At least 8 characters",
                isValid: password.count >= 8
            ),
            PasswordRule(
                description: "One uppercase letter",
                isValid: password.range(of: "[A-Z]", options: .regularExpression) != nil
            ),
            PasswordRule(
                description: "One lowercase letter",
                isValid: password.range(of: "[a-z]", options: .regularExpression) != nil
            ),
            PasswordRule(
                description: "One number",
                isValid: password.range(of: "[0-9]", options: .regularExpression) != nil
            ),
            PasswordRule(
                description: "One special character",
                isValid: password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
            )
        ]
    }
}
