import Dependencies
import DependenciesMacros
import Foundation
import Models

@DependencyClient
public struct TripPersistenceClient: Sendable {
  public var fetchAll: @Sendable () async throws -> [Trip]
  public var add: @Sendable (Trip) async throws -> Void
  public var update: @Sendable (Trip) async throws -> Void
  public var delete: @Sendable (UUID) async throws -> Void
}

extension TripPersistenceClient: TestDependencyKey {
  public static let testValue = Self()
}

extension DependencyValues {
  public var tripPersistenceClient: TripPersistenceClient {
    get { self[TripPersistenceClient.self] }
    set { self[TripPersistenceClient.self] = newValue }
  }
}
