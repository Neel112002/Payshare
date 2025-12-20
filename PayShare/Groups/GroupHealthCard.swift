import SwiftUI

struct GroupHealthCard: View {

    struct Member: Identifiable {
        let id = UUID()
        let name: String
        let delta: Int   // + = overpaid, - = underpaid
    }

    let score: Int
    let members: [Member]

    // MARK: - Derived insight
    private var insight: String {
        if score >= 80 {
            return "Expenses are fairly shared recently."
        } else {
            return "One or more members are paying more than their share."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header
            HStack {
                Label("Fairness Score", systemImage: "scale.3d")
                    .font(.headline)

                Spacer()

                Text(scoreLabel)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(scoreColor.opacity(0.15))
                    .foregroundStyle(scoreColor)
                    .clipShape(Capsule())
            }

            Text(insight)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)

                    Capsule()
                        .fill(scoreColor)
                        .frame(
                            width: geo.size.width * CGFloat(score) / 100,
                            height: 10
                        )
                }
            }
            .frame(height: 10)

            // Members
            HStack(spacing: 12) {
                ForEach(members) { member in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(member.name.prefix(1))
                                    .font(.caption.bold())
                                    .foregroundStyle(.blue)
                            )

                        Text(deltaText(for: member.delta))
                            .font(.footnote.bold())
                            .foregroundStyle(member.delta >= 0 ? .green : .red)
                    }
                }

                Spacer()
            }

            // Navigation
            NavigationLink {
                FairnessInsightsView(
                    insight: insight,
                    overpayer: members.first?.name ?? "-",
                    underpayer: members.last?.name ?? "-"
                )
            } label: {
                Text("View fairness insights")
                    .font(.footnote)
                    .foregroundStyle(.blue)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 6)
    }

    // MARK: - Helpers

    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }

    private var scoreLabel: String {
        score >= 80 ? "Balanced \(score)" : "Unbalanced \(score)"
    }

    private func deltaText(for value: Int) -> String {
        value >= 0 ? "+₹\(value)" : "-₹\(abs(value))"
    }
}
