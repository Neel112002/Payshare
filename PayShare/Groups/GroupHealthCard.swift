import SwiftUI

struct GroupHealthCard: View {

    // MARK: - Member model
    struct Member: Identifiable {
        let id = UUID()
        let name: String
        let delta: Int   // + overpaid, - underpaid
    }

    // MARK: - Inputs
    let score: Int              // 0–100
    let members: [Member]

    // MARK: - Animation
    @State private var animatedScore: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // MARK: - Header
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

            Text(scoreDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // MARK: - Progress Bar (Animated)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)

                    Capsule()
                        .fill(scoreColor)
                        .frame(
                            width: geo.size.width * animatedScore,
                            height: 10
                        )
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8),
                            value: animatedScore
                        )
                }
            }
            .frame(height: 10)
            .onAppear {
                animatedScore = CGFloat(score) / 100
            }

            // MARK: - Members
            HStack(spacing: 12) {
                ForEach(members) { member in
                    HStack(spacing: 6) {
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

            // MARK: - Navigation
            NavigationLink {
                FairnessInsightsView(
                    insight: scoreDescription,
                    overpayer: members.first?.name ?? "—",
                    underpayer: members.last?.name ?? "—"
                )
            } label: {
                Text("View fairness insights")
                    .font(.footnote)
                    .foregroundStyle(.blue)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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

    private var scoreDescription: String {
        score >= 80
        ? "Expenses are fairly shared in the last 7 days."
        : "One or more members are overpaying."
    }

    private func deltaText(for value: Int) -> String {
        value >= 0 ? "+₹\(value)" : "-₹\(abs(value))"
    }
}
