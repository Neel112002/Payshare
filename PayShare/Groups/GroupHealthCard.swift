import SwiftUI

struct GroupHealthCard: View {
    let groupName: String

    // Mock "health" data (frontend-only)
    let weeklySpend: [Double]        // 7 points
    let topSpenderName: String
    let topSpenderAmount: Double
    let mostOwedToName: String
    let mostOwedToAmount: Double
    let lateSettlers: [(name: String, days: Int)]

    private var totalWeek: Double { weeklySpend.reduce(0, +) }
    private var avgDay: Double { weeklySpend.isEmpty ? 0 : totalWeek / Double(weeklySpend.count) }

    private var health: (title: String, color: Color) {
        // simple heuristic
        if lateSettlers.count >= 2 { return ("Needs attention", .orange) }
        if lateSettlers.count == 1 { return ("Watchlist", .yellow) }
        return ("Healthy", .green)
    }

    var body: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Group Health", systemImage: "heart.text.square")
                        .font(.headline)

                    Spacer()

                    Text(health.title)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(health.color.opacity(0.14))
                        .clipShape(Capsule())
                }

                // Spend trend
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Weekly spend trend")
                            .font(.subheadline.bold())
                        Spacer()
                        Text("₹\(Int(totalWeek)) / wk")
                            .font(.subheadline.bold())
                    }

                    Sparkline(data: weeklySpend)
                        .frame(height: 44)

                    Text("Avg ₹\(Int(avgDay))/day")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                // Highlights chips
                HStack(spacing: 10) {
                    MetricChip(
                        icon: "flame.fill",
                        title: "Top spender",
                        name: topSpenderName,
                        valueText: "₹\(Int(topSpenderAmount))",
                        tint: .orange
                    )

                    MetricChip(
                        icon: "arrow.down.left.circle.fill",
                        title: "Most owed to",
                        name: mostOwedToName,
                        valueText: "₹\(Int(mostOwedToAmount))",
                        tint: .blue
                    )
                }

                // Late settlers
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Late settlers")
                            .font(.subheadline.bold())
                        Spacer()
                        Text(lateSettlers.isEmpty ? "None" : "\(lateSettlers.count)")
                            .font(.footnote.bold())
                            .foregroundStyle(lateSettlers.isEmpty ? Color.secondary : Color.red)

                    }

                    if lateSettlers.isEmpty {
                        Text("Everyone is up to date 🎉")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(lateSettlers.indices, id: \.self) { i in
                            let p = lateSettlers[i]
                            HStack {
                                Text(p.name).font(.footnote.bold())
                                Spacer()
                                Text("\(p.days)d since settle")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            if i != lateSettlers.count - 1 { Divider() }
                        }
                    }
                }

                Button {
                    // later: open a full insights screen
                } label: {
                    HStack {
                        Text("View health insights")
                        Spacer()
                        Image(systemName: "chevron.right").font(.footnote.bold())
                    }
                }
                .buttonStyle(.plain)
                .font(.footnote.bold())
                .foregroundStyle(.blue)
                .padding(.top, 2)
            }
        }
    }

    // same card style
    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Components

private struct MetricChip: View {
    let icon: String
    let title: String
    let name: String
    let valueText: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(name)
                .font(.subheadline.bold())

            Text(valueText)
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct Sparkline: View {
    let data: [Double]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxV = (data.max() ?? 1)
            let minV = (data.min() ?? 0)
            let range = max(maxV - minV, 1)

            let points: [CGPoint] = data.enumerated().map { idx, v in
                let x = data.count <= 1 ? 0 : (w * CGFloat(idx) / CGFloat(data.count - 1))
                let y = h - (h * CGFloat((v - minV) / range))
                return CGPoint(x: x, y: y)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.08))

                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: first)
                    for p in points.dropFirst() { path.addLine(to: p) }
                }
                .stroke(.blue, lineWidth: 3)
                .shadow(color: Color.blue.opacity(0.15), radius: 6, x: 0, y: 4)

                // last dot
                if let last = points.last {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                        .position(last)
                }
            }
        }
    }
}
