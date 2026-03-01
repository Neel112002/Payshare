from collections import defaultdict
from typing import Dict, List


def calculate_balances(expenses: List[dict]) -> Dict[str, float]:
    """
    Returns balance per user:
    positive = overpaid
    negative = underpaid
    """

    paid = defaultdict(float)
    owed = defaultdict(float)

    for expense in expenses:
        payer = expense["paid_by"]
        paid[payer] += expense["total_amount"]

        for split in expense["splits"]:
            user_id = split["user_id"]
            owed[user_id] += split["amount"]

    balances = {}
    for user in set(paid) | set(owed):
        balances[user] = round(paid[user] - owed[user], 2)

    return balances


def fairness_score(balances: Dict[str, float]) -> int:
    """
    100 = perfectly balanced
    Lower score = more imbalance
    """
    if not balances:
        return 100

    total_imbalance = sum(abs(v) for v in balances.values())
    max_possible = total_imbalance + 1  # avoid divide by zero

    score = max(0, int(100 * (1 - total_imbalance / max_possible)))
    return score