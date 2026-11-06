import Foundation
import Observation

/// Holds the ticket queue and persists every status change locally.
///
/// Persistence is a plain JSON file in the app's documents directory -
/// no backend, no account, works fully offline. The same store would sync
/// against a REST API by swapping `save()` for network calls.
@Observable
final class TicketStore {
    private(set) var tickets: [Ticket]
    private let fileURL: URL

    /// Active filters; empty set means "show everything".
    var visiblePriorities: Set<Ticket.Priority> = []
    var visibleCategories: Set<Ticket.Category> = []

    init(loadFromDisk: Bool = true) {
        let docs = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("tickets.json")
        if loadFromDisk, let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode([Ticket].self, from: data) {
            tickets = saved
        } else {
            tickets = Ticket.sample
            save()
        }
    }

    var filtered: [Ticket] {
        tickets
            .filter { visiblePriorities.isEmpty ||
                      visiblePriorities.contains($0.priority) }
            .filter { visibleCategories.isEmpty ||
                      visibleCategories.contains($0.category) }
            .sorted {
                ($0.priority, $0.receivedAt) < ($1.priority, $1.receivedAt)
            }
    }

    var highestPriorityTicket: Ticket {
        filtered.sorted { $0.priority < $1.priority }.first ?? tickets[0]
    }

    var unresolved: [Ticket] {
        tickets.filter { $0.status != .resolved }
    }

    func setStatus(_ status: Ticket.Status, for ticket: Ticket) {
        guard let i = tickets.firstIndex(where: { $0.id == ticket.id }) else {
            return
        }
        tickets[i].status = status
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(tickets) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
