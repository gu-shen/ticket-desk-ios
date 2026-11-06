import SwiftUI

/// Full view of one ticket: what the classifier decided, and the tools to
/// move it through the workflow.
struct TicketDetailView: View {
    let ticket: Ticket

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    PriorityBadge(priority: ticket.priority)
                    Label(ticket.category.rawValue,
                          systemImage: ticket.category.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(ticket.subject)
                    .font(.title2.bold())

                Text(ticket.body)
                    .font(.body)
                    .foregroundStyle(.secondary)

                Grid(alignment: .leading, horizontalSpacing: 24,
                     verticalSpacing: 12) {
                    GridRow {
                        Text("Ticket").foregroundStyle(.secondary)
                        Text(ticket.id).fontWeight(.medium)
                    }
                    GridRow {
                        Text("Received").foregroundStyle(.secondary)
                        Text(ticket.receivedAt, style: .date)
                            + Text("  ")
                            + Text(ticket.receivedAt, style: .time)
                    }
                    GridRow {
                        Text("Status").foregroundStyle(.secondary)
                        StatusPill(status: ticket.status)
                    }
                }
                .font(.subheadline)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Classifier confidence")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(ticket.classifierConfidence * 100))%")
                            .font(.subheadline.bold())
                    }
                    ProgressView(value: ticket.classifierConfidence)
                        .tint(ticket.classifierConfidence > 0.6 ? .green
                              : ticket.classifierConfidence > 0.45 ? .orange
                              : .red)
                    if ticket.classifierConfidence < 0.45 {
                        Label("Below the auto-answer threshold - a human owns this one.",
                              systemImage: "person.fill.checkmark")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                Picker("Status", selection: .constant(ticket.status)) {
                    ForEach(Ticket.Status.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(true) // demo build - wired up to the store in production
            }
            .padding()
        }
        .navigationTitle(ticket.id)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatusPill: View {
    let status: Ticket.Status

    private var color: Color {
        switch status {
        case .new: return .blue
        case .inProgress: return .orange
        case .resolved: return .green
        }
    }

    var body: some View {
        Text(status.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }
}
