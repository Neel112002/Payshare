from app.fairness.settlements import calculate_settlements

def run_test():
    balances = {
        "You": 50,
        "Alex": -30,
        "Sam": -20
    }

    settlements = calculate_settlements(balances)
    print("Settlements result:")
    for s in settlements:
        print(s)

if __name__ == "__main__":
    run_test()
