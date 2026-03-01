import Foundation

enum FairnessCalculator {

    static func calculate(expenses: [Expense]) -> [FairnessBalance] {

        var balances: [UUID: Double] = [:]

        for expense in expenses {
            balances[expense.paidBy, default: 0] += expense.totalAmount
        }

        return balances.map { userId, amount in
            FairnessBalance(
                name: userId.uuidString,
                balance: amount
            )
        }
        .sorted { $0.balance > $1.balance }
    }
}
