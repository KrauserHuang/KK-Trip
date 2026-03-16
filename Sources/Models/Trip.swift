import Foundation

public struct Trip: Equatable, Sendable, Identifiable {
  public var id: UUID
  public var title: String
  public var destination: String
  public var startDate: Date
  public var endDate: Date
  public var note: String
  public var createdAt: Date
  public var updatedAt: Date

  public init(
    id: UUID = UUID(),
    title: String,
    destination: String,
    startDate: Date,
    endDate: Date,
    note: String = "",
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.title = title
    self.destination = destination
    self.startDate = startDate
    self.endDate = endDate
    self.note = note
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
