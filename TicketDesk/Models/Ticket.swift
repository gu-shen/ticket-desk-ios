import Foundation

/// A support ticket as it arrives from the triage pipeline.
struct Ticket: Identifiable, Hashable, Codable {
    enum Category: String, Codable, CaseIterable {
        case refunds = "Refunds & returns"
        case shipping = "Shipping"
        case billing = "Payments & billing"
        case account = "Account & login"
        case product = "Product questions"
        case other = "Other"

        var systemImage: String {
            switch self {
            case .refunds: return "arrow.uturn.backward.circle"
            case .shipping: return "shippingbox"
            case .billing: return "creditcard"
            case .account: return "person.crop.circle"
            case .product: return "questionmark.circle"
            case .other: return "tray"
            }
        }
    }

    enum Priority: String, Codable, CaseIterable, Comparable {
        case high = "HIGH"
        case medium = "MED"
        case low = "LOW"

        var rank: Int {
            switch self {
            case .high: return 0
            case .medium: return 1
            case .low: return 2
            }
        }

        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rank < rhs.rank
        }
    }

    enum Status: String, Codable, CaseIterable {
        case new = "New"
        case inProgress = "In progress"
        case resolved = "Resolved"
    }

    let id: String            // e.g. "T-1001"
    let subject: String
    let body: String
    let category: Category
    let priority: Priority
    let receivedAt: Date
    let classifierConfidence: Double   // 0...1, from the triage pipeline

    var status: Status
}

extension Ticket {
    /// Fixed demo timestamps so screenshots are deterministic.
    private static func d(_ day: Int, _ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(
            year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    static let sample: [Ticket] = [
        Ticket(id: "T-1005", subject: "Charged twice for one order",
               body: "I was charged twice on my credit card for order 55213 - two identical charges of $84.99 on Nov 2. This needs to be fixed today.",
               category: .billing, priority: .high,
               receivedAt: d(6, 14, 20),
               classifierConfidence: 0.62, status: .new),
        Ticket(id: "T-1018", subject: "Change shipping address URGENT",
               body: "I moved last week and order 77402 is still going to my old address!! Please update it immediately before it ships.",
               category: .shipping, priority: .high,
               receivedAt: d(6, 10, 5),
               classifierConfidence: 0.51, status: .new),
        Ticket(id: "T-1023", subject: "Package stuck, tracking not updating",
               body: "Order 88341 was placed 9 days ago and tracking hasn't updated since. Expected delivery was last Tuesday. What's going on?",
               category: .shipping, priority: .medium,
               receivedAt: d(6, 8, 40),
               classifierConfidence: 0.74, status: .inProgress),
        Ticket(id: "T-1002", subject: "Refund request - order 76510",
               body: "Hi, I need a refund for order 76510. The item arrived damaged and I already uploaded photos. Please process this as soon as possible.",
               category: .refunds, priority: .medium,
               receivedAt: d(5, 17, 12),
               classifierConfidence: 0.78, status: .new),
        Ticket(id: "T-1006", subject: "Invoice needed for accounting",
               body: "Can I get a formal invoice with our company VAT number for order 61120? Our accounting department is asking for it before Friday.",
               category: .billing, priority: .medium,
               receivedAt: d(5, 15, 44),
               classifierConfidence: 0.81, status: .new),
        Ticket(id: "T-1001", subject: "Can't log in - reset email never arrives",
               body: "I tried 'forgot password' four times over two days and no reset email arrives. Not in spam either.",
               category: .account, priority: .low,
               receivedAt: d(4, 11, 30),
               classifierConfidence: 0.88, status: .resolved),
        Ticket(id: "T-1013", subject: "Return label question",
               body: "How do I get a return shipping label? Your return page says 'start a return' but I don't see the button on my account.",
               category: .refunds, priority: .medium,
               receivedAt: d(4, 9, 20),
               classifierConfidence: 0.83, status: .inProgress),
        Ticket(id: "T-1009", subject: "Is the XL size back in stock?",
               body: "The navy hoodie in XL has been out of stock for weeks. Any restock date? Also is the material the same as last season?",
               category: .product, priority: .low,
               receivedAt: d(4, 16, 5),
               classifierConfidence: 0.86, status: .new),
        Ticket(id: "T-1020", subject: "Discount code not working",
               body: "Code SAVE20 says invalid at checkout but the promo banner is still on the homepage. Tried on Safari and the app.",
               category: .billing, priority: .low,
               receivedAt: d(3, 13, 48),
               classifierConfidence: 0.79, status: .new),
        Ticket(id: "T-1027", subject: "Discount code not working",
               body: "Same issue as my colleague - SAVE20 rejected. Cart is over $100 so it should apply. Screenshot attached in the web form.",
               category: .billing, priority: .low,
               receivedAt: d(3, 10, 22),
               classifierConfidence: 0.77, status: .new),
        Ticket(id: "T-1029", subject: "Password reset on mobile app",
               body: "Reset link from the app opens a blank page. Had to use the website instead. Using iPhone 16 Pro, iOS 26.",
               category: .account, priority: .medium,
               receivedAt: d(3, 9, 15),
               classifierConfidence: 0.72, status: .resolved),
        Ticket(id: "T-1031", subject: "Wholesale pricing inquiry",
               body: "We run a small retail chain in Portugal and would like wholesale pricing for your product line. Who should I talk to?",
               category: .other, priority: .low,
               receivedAt: d(2, 18, 2),
               classifierConfidence: 0.41, status: .new),
        Ticket(id: "T-1033", subject: "Compatibility question before buying",
               body: "Does the USB-C dock work with a 2021 iPad Pro? Want to confirm before ordering 3 units for our office.",
               category: .product, priority: .low,
               receivedAt: d(2, 11, 47),
               classifierConfidence: 0.84, status: .resolved),
        Ticket(id: "T-1036", subject: "Refund for returned item not received",
               body: "Returned order 90211 two weeks ago, tracking shows you received it, but no refund yet. Getting a bit worried now.",
               category: .refunds, priority: .high,
               receivedAt: d(2, 8, 35),
               classifierConfidence: 0.69, status: .inProgress),
    ]
}
