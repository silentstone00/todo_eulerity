import Foundation

struct Task: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let title: String
    let createdAt: Date
    var isCompleted: Bool
    var expirationTime: Date?
    
    init(id: UUID = UUID(), title: String, createdAt: Date, isCompleted: Bool = false, expirationTime: Date? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.expirationTime = expirationTime
    }
    
    var isExpired: Bool {
        guard let expirationTime = expirationTime else {
            return false
        }
        return Date() > expirationTime
    }
}
