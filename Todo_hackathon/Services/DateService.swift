import Foundation

protocol DateService: Sendable {
    func now() -> Date
    
    func isToday(_ date: Date) -> Bool
    
    func startOfToday() -> Date
}

final class DateServiceImpl: DateService {
    private let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    func now() -> Date {
        Date()
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func startOfToday() -> Date {
        calendar.startOfDay(for: Date())
    }
}
