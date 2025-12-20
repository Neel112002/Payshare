import SwiftUI

struct FairnessInsightsView: View {

    let insight: String
    let overpayer: String
    let underpayer: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Fairness Insights")
                    .font(.largeTitle.bold())

                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Summary", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)

                        Text(insight)
                            .font(.body)
                    }
                }

                card {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Balance Breakdown", systemImage: "person.2.fill")
                            .font(.headline)

                        HStack {
                            Text(overpayer)
                            Spacer()
                            Text("Overpaid")
                                .foregroundStyle(.green)
                        }

                        Divider()

                        HStack {
                            Text(underpayer)
                            Spacer()
                            Text("Underpaid")
                                .foregroundStyle(.red)
                        }
                    }
                }

                Spacer()
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Card Helper
    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
