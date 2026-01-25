from typing import Dict, List


def calculate_settlements(balances: Dict[str, float]) -> List[dict]:
    """
    Convert balances into minimal settlement transactions
    """
    creditors = []
    debtors = []

    for person, amount in balances.items():
        if amount > 0:
            creditors.append([person, amount])
        elif amount < 0:
            debtors.append([person, -amount])

    settlements = []
    i = j = 0

    while i < len(debtors) and j < len(creditors):
        debtor, debt = debtors[i]
        creditor, credit = creditors[j]

        paid = min(debt, credit)

        settlements.append({
            "from": debtor,
            "to": creditor,
            "amount": round(paid, 2)
        })

        debtors[i][1] -= paid
        creditors[j][1] -= paid

        if debtors[i][1] == 0:
            i += 1
        if creditors[j][1] == 0:
            j += 1

    return settlements
