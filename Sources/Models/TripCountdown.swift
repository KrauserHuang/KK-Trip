import Foundation

/// Where a trip sits relative to today, for the countdown display on the plan list.
public enum TripCountdown: Equatable, Sendable {
  /// Departure is still ahead. `days` is always at least 1.
  case upcoming(days: Int)
  /// Departure is today.
  case departingToday
  /// The trip is underway. `dayNumber` is 1-based and inclusive of both end dates.
  case ongoing(dayNumber: Int, totalDays: Int)
  /// The end date has passed.
  case completed
}

extension Trip {
  /// Countdown state for this trip.
  ///
  /// Compared by calendar day rather than elapsed time, so a trip departing
  /// tomorrow morning reads as "1 day" regardless of the current hour.
  public func countdown(
    asOf now: Date,
    calendar: Calendar = .current
  ) -> TripCountdown {
    let today = calendar.startOfDay(for: now)
    let start = calendar.startOfDay(for: startDate)
    let end = calendar.startOfDay(for: endDate)

    if today < start {
      let days = calendar.dateComponents([.day], from: today, to: start).day ?? 0
      return .upcoming(days: days)
    } else if today == start {
      return .departingToday
    } else if today <= end {
      let elapsed = calendar.dateComponents([.day], from: start, to: today).day ?? 0
      let span = calendar.dateComponents([.day], from: start, to: end).day ?? 0
      return .ongoing(dayNumber: elapsed + 1, totalDays: span + 1)
    } else {
      return .completed
    }
  }
}
