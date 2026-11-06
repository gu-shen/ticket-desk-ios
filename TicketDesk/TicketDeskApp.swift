import SwiftUI

@main
struct TicketDeskApp: App {
    @State private var store = TicketStore()

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}

/// Entry point that picks the starting screen.
///
/// The demo screenshots are captured with launch arguments so each state is
/// deterministic:
///   --screen=list   (default) ticket queue
///   --screen=detail a high-priority ticket, opened
///   --screen=stats  the stats tab
enum DemoScreen: String {
    case list, detail, stats
}

struct RootView: View {
    let store: TicketStore

    private var demoScreen: DemoScreen {
        for arg in CommandLine.arguments where arg.hasPrefix("--screen=") {
            let name = arg.dropFirst("--screen=".count)
            return DemoScreen(rawValue: String(name)) ?? .list
        }
        return .list
    }

    var body: some View {
        switch demoScreen {
        case .detail:
            NavigationStack {
                TicketDetailView(ticket: store.highestPriorityTicket)
            }
        case .stats:
            StatsView(store: store)
        case .list:
            TicketListView(store: store)
        }
    }
}
