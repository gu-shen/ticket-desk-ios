import SwiftUI

/// One-glance health of the queue: resolution progress + where tickets land.
struct StatsView: View {
    let store: TicketStore

    private var resolvedFraction: Double {
        Double(store.tickets.filter { $0.status == .resolved }.count)
            / Double(max(1, store.tickets.count))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    resolutionCard
                    categoryCard
                    priorityCard
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }

    private var resolutionCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 16)
                Circle()
                    .trim(from: 0, to: resolvedFraction)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 16,
                                                            lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack {
                    Text("\(Int(resolvedFraction * 100))%")
                        .font(.title.bold())
                    Text("resolved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            Text("\(store.unresolved.count) of \(store.tickets.count) tickets still open")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Open tickets by category")
                .font(.headline)
            let counts = Dictionary(grouping: store.unresolved,
                                    by: \.category)
                .mapValues(\.count)
                .sorted { $0.value > $1.value }
            let max = counts.map(\.value).max() ?? 1
            ForEach(counts, id: \.key) { category, count in
                HStack {
                    Label(category.rawValue,
                          systemImage: category.systemImage)
                        .font(.subheadline)
                        .frame(width: 180, alignment: .leading)
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor)
                            .frame(width: geo.size.width * CGFloat(count)
                                   / CGFloat(max))
                    }
                    .frame(height: 16)
                    Text("\(count)")
                        .font(.subheadline.bold())
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var priorityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Where the queue pressure is")
                .font(.headline)
            HStack(spacing: 0) {
                ForEach(Ticket.Priority.allCases, id: \.self) { p in
                    let count = store.unresolved
                        .filter { $0.priority == p }.count
                    VStack(spacing: 6) {
                        Text("\(count)")
                            .font(.title2.bold())
                            .foregroundStyle(p.color)
                        Text(p.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    if p != .low {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
