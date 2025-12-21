import Foundation

enum FairnessCalculator {

    static func calculate(expenses: [Expense]) -> [FairnessBalance] {
        var paid: [String: Double] = [:]
        var owed: [String: Double] = [:]

        for expense in expenses {
            // 1️⃣ Track who paid
            paid[expense.paidBy, default: 0] += expense.totalAmount

            // 2️⃣ Track who owes
            for split in expense.splits {
                owed[split.name, default: 0] += split.amount
            }
        }

        // 3️⃣ Combine into balances
        let allPeople = Set(paid.keys).union(owed.keys)

        return allPeople.map { name in
            let paidAmount = paid[name, default: 0]
            let owedAmount = owed[name, default: 0]
            return FairnessBalance(
                name: name,
                balance: paidAmount - owedAmount
            )
        }
        .sorted { $0.balance > $1.balance }
    }
}
