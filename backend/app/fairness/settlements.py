from typing import Dict, List


def calculate_settlements(balances: Dict[str, float]) -> List[dict]:
    """
    Given balances like:
    {
        "You": 30,
        "Alex": -30
    }

    Returns:
    [
        { "from": "Alex", "to": "You", "amount": 30 }
    ]
    """

    creditors = []
    debtors = []

    # Split into creditors and debtors
    for person, balance in balances.items():
        if balance > 0:
            creditors.append([person, balance])
        elif balance < 0:
            debtors.append([person, -balance])  # store positive debt

    settlements = []

    i = 0  # creditor index
    j = 0  # debtor index

    while i < len(creditors) and j < len(debtors):
        creditor, credit_amount = creditors[i]
        debtor, debt_amount = debtors[j]

        settled_amount = min(credit_amount, debt_amount)

        settlements.append({
            "from": debtor,
            "to": creditor,
            "amount": round(settled_amount, 2)
        })

        creditors[i][1] -= settled_amount
        debtors[j][1] -= settled_amount

        if creditors[i][1] == 0:
            i += 1
        if debtors[j][1] == 0:
            j += 1

    return settlements
