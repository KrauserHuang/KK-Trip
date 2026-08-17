import Foundation
import Testing

@testable import Models

@Suite("Trip countdown")
struct TripCountdownTests {
  /// Fixed calendar so results never depend on the machine's locale or zone.
  static let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Taipei")!
    return calendar
  }()

  /// Builds a date at a specific wall-clock time in the fixed calendar.
  static func date(
    _ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0
  ) -> Date {
    calendar.date(
      from: DateComponents(
        timeZone: calendar.timeZone,
        year: year, month: month, day: day, hour: hour, minute: minute
      )
    )!
  }

  static func trip(start: Date, end: Date) -> Trip {
    Trip(
      title: "東京之旅",
      destination: "日本東京",
      startDate: start,
      endDate: end
    )
  }

  @Test("Counts whole calendar days until departure")
  func upcomingTrip() {
    let trip = Self.trip(
      start: Self.date(2026, 8, 22),
      end: Self.date(2026, 8, 27)
    )

    let countdown = trip.countdown(
      asOf: Self.date(2026, 8, 17),
      calendar: Self.calendar
    )

    #expect(countdown == .upcoming(days: 5))
  }

  @Test("Departure day reads as departing regardless of the hour")
  func departingToday() {
    let trip = Self.trip(
      start: Self.date(2026, 8, 22, 8, 30),
      end: Self.date(2026, 8, 27)
    )

    let countdown = trip.countdown(
      asOf: Self.date(2026, 8, 22, 23, 45),
      calendar: Self.calendar
    )

    #expect(countdown == .departingToday)
  }

  @Test("Reports 1-based day number while the trip is underway")
  func ongoingTrip() {
    let trip = Self.trip(
      start: Self.date(2026, 8, 22),
      end: Self.date(2026, 8, 27)
    )

    let countdown = trip.countdown(
      asOf: Self.date(2026, 8, 24, 12),
      calendar: Self.calendar
    )

    #expect(countdown == .ongoing(dayNumber: 3, totalDays: 6))
  }

  @Test("The final day is still ongoing, not completed")
  func lastDayIsOngoing() {
    let trip = Self.trip(
      start: Self.date(2026, 8, 22),
      end: Self.date(2026, 8, 27, 21)
    )

    let countdown = trip.countdown(
      asOf: Self.date(2026, 8, 27, 6),
      calendar: Self.calendar
    )

    #expect(countdown == .ongoing(dayNumber: 6, totalDays: 6))
  }

  @Test("Becomes completed the day after the end date")
  func completedTrip() {
    let trip = Self.trip(
      start: Self.date(2026, 8, 22),
      end: Self.date(2026, 8, 27, 21)
    )

    let countdown = trip.countdown(
      asOf: Self.date(2026, 8, 28, 0, 1),
      calendar: Self.calendar
    )

    #expect(countdown == .completed)
  }

  @Test("Departing tomorrow counts as one day, not zero")
  func departingTomorrow() {
    let trip = Self.trip(
      start: Self.date(2026, 8, 18, 6),
      end: Self.date(2026, 8, 20)
    )

    let countdown = trip.countdown(
      asOf: Self.date(2026, 8, 17, 23, 59),
      calendar: Self.calendar
    )

    #expect(countdown == .upcoming(days: 1))
  }

  @Test("A single-day trip spans one total day")
  func singleDayTrip() {
    let trip = Self.trip(
      start: Self.date(2026, 8, 22, 9),
      end: Self.date(2026, 8, 22, 22)
    )

    let countdown = trip.countdown(
      asOf: Self.date(2026, 8, 22, 14),
      calendar: Self.calendar
    )

    #expect(countdown == .departingToday)
  }

  @Test("Counts calendar days across a spring-forward boundary")
  func springForwardBoundary() {
    // US DST begins 2026-03-08, so 03-07 to 03-09 is two calendar days
    // but only 47 elapsed hours. Dividing by 86400 would report 1 day.
    var pacific = Calendar(identifier: .gregorian)
    pacific.timeZone = TimeZone(identifier: "America/Los_Angeles")!

    func pacificDate(_ month: Int, _ day: Int, _ hour: Int) -> Date {
      pacific.date(
        from: DateComponents(
          timeZone: pacific.timeZone,
          year: 2026, month: month, day: day, hour: hour
        )
      )!
    }

    let trip = Self.trip(
      start: pacificDate(3, 9, 9),
      end: pacificDate(3, 12, 18)
    )

    let countdown = trip.countdown(
      asOf: pacificDate(3, 7, 10),
      calendar: pacific
    )

    #expect(countdown == .upcoming(days: 2))
  }
}
