import Dependencies
import DependencyClients
import Foundation
import Models
import SwiftData

@ModelActor
actor TripModelActor {
  func fetchAll() throws -> [Trip] {
    let descriptor = FetchDescriptor<TravelPlan>(
      sortBy: [SortDescriptor(\.startDate, order: .forward)]
    )
    return try modelContext.fetch(descriptor).map { $0.toTrip() }
  }

  func add(_ trip: Trip) throws {
    let plan = TravelPlan(from: trip)
    modelContext.insert(plan)
    try modelContext.save()
  }

  func update(_ trip: Trip) throws {
    let tripID = trip.id
    let descriptor = FetchDescriptor<TravelPlan>(
      predicate: #Predicate { $0.id == tripID }
    )
    if let existing = try modelContext.fetch(descriptor).first {
      existing.title = trip.title
      existing.destination = trip.destination
      existing.startDate = trip.startDate
      existing.endDate = trip.endDate
      existing.note = trip.note
      existing.updatedAt = Date()
      try modelContext.save()
    }
  }

  func delete(_ id: UUID) throws {
    let descriptor = FetchDescriptor<TravelPlan>(
      predicate: #Predicate { $0.id == id }
    )
    if let existing = try modelContext.fetch(descriptor).first {
      modelContext.delete(existing)
      try modelContext.save()
    }
  }
}

extension TravelPlan {
  func toTrip() -> Trip {
    Trip(
      id: id,
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }

  convenience init(from trip: Trip) {
    self.init(
      id: trip.id,
      title: trip.title,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      note: trip.note,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt
    )
  }
}

extension TripPersistenceClient: DependencyKey {
  public static let liveValue: TripPersistenceClient = {
    let container = try! ModelContainer(for: TravelPlan.self)
    let actor = TripModelActor(modelContainer: container)

    return TripPersistenceClient(
      fetchAll: {
        try await actor.fetchAll()
      },
      add: { trip in
        try await actor.add(trip)
      },
      update: { trip in
        try await actor.update(trip)
      },
      delete: { id in
        try await actor.delete(id)
      }
    )
  }()
}
