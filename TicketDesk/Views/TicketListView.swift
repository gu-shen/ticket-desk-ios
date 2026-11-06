import SwiftUI

/// The ticket queue: filter chips on top, priority-sorted list below.
struct TicketListView: View {
    @Bindable var store: TicketStore
    @State private var query = ""

    var body: some View {
        TabView {
            NavigationStack {
                List(store.filtered) { ticket in
                    NavigationLink(value: ticket) {
                        TicketRow(ticket: ticket)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Ticket Desk")
                .searchable(text: $query, prompt: "Search tickets")
                .safeAreaInset(edge: .top) {
                    FilterBar(store: store)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        .background(.bar)
                }
                .navigationDestination(for: Ticket.self) { ticket in
                    TicketDetailView(ticket: ticket)
                }
            }
            .tabItem { Label("Queue", systemImage: "tray.full") }

            StatsView(store: store)
                .tabItem { Label("Stats", systemImage: "chart.bar") }
        }
    }
}

private struct TicketRow: View {
    let ticket: Ticket

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticket.subject)
                    .font(.headline)
                    .lineLimit(1)
                Label(ticket.category.rawValue,
                      systemImage: ticket.category.systemImage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                PriorityBadge(priority: ticket.priority)
                if ticket.status == .resolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Text(ticket.receivedAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

/// Priority filter chips - tap to toggle, tap "All" to reset.
private struct FilterBar: View {
    @Bindable var store: TicketStore

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("All", isOn: store.visiblePriorities.isEmpty
                     && store.visibleCategories.isEmpty) {
                    store.visiblePriorities = []
                    store.visibleCategories = []
                }
                ForEach(Ticket.Priority.allCases, id: \.self) { p in
                    chip(p.rawValue,
                         isOn: store.visiblePriorities.contains(p),
                         color: p.color) {
                        toggle(p, in: &store.visiblePriorities)
                    }
                }
                Divider().frame(height: 20)
                ForEach([Ticket.Category.refunds, .shipping, .billing],
                        id: \.self) { c in
                    chip(c.rawValue, isOn: store.visibleCategories.contains(c)) {
                        toggle(c, in: &store.visibleCategories)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func chip(_ title: String, isOn: Bool, color: Color = .blue,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isOn ? color : Color.secondary.opacity(0.15),
                             in: Capsule())
                .foregroundStyle(isOn ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private func toggle<T: Hashable>(_ value: T, in set: inout Set<T>) {
        if set.contains(value) { set.remove(value) } else { set.insert(value) }
    }
}

extension Ticket.Priority {
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct PriorityBadge: View {
    let priority: Ticket.Priority

    var body: some View {
        Text(priority.rawValue)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(priority.color.opacity(0.18), in: Capsule())
            .foregroundStyle(priority.color)
            .overlay(Capsule().stroke(priority.color.opacity(0.5), lineWidth: 1))
    }
}
