import SwiftUI

struct FairnessInsightsView: View {
    let insight: String
    let overpayer: String
    let underpayer: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 42))
                    .foregroundStyle(.blue)

                Text("Group Fairness Insights")
                    .font(.title2.bold())

                Text(insight)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                insightCard(
                    title: "Overpayer",
                    name: overpayer,
                    description: "\(overpayer) has paid more than average recently."
                )

                insightCard(
                    title: "Underpayer",
                    name: underpayer,
                    description: "\(underpayer) should cover the next expense."
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func insightCard(title: String, name: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(name)
                .font(.headline.bold())

            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
