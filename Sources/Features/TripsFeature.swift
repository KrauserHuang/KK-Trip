import ComposableArchitecture
import DependencyClients
import Foundation
import Models

@Reducer
package struct TripsFeature {
  @ObservableState
  package struct State: Equatable {
    package var trips: [Trip] = []
    package var path = StackState<Path.State>()

    package init() {}
  }

  @CasePathable
  package enum Action: Equatable {
    case task
    case tripsLoaded([Trip])
    case addButtonTapped
    case deleteTrip(UUID)
    case tripDeleted
    case path(StackActionOf<Path>)
  }

  package init() {}

  package var body: some ReducerOf<Self> {
    Reduce(core)
      .forEach(\.path, action: \.path)
  }

  package func core(
    into state: inout State, action: Action
  ) -> Effect<Action> {
    switch action {
    case .task:
      return .run { send in
        @Dependency(\.tripPersistenceClient) var client
        let trips = try await client.fetchAll()
        await send(.tripsLoaded(trips))
      }

    case .tripsLoaded(let trips):
      state.trips = trips
      return .none

    case .addButtonTapped:
      @Dependency(\.date) var date
      let now = date.now
      state.path.append(
        .tripForm(TripFormFeature.State(startDate: now))
      )
      return .none

    case .deleteTrip(let id):
      return .run { send in
        @Dependency(\.tripPersistenceClient) var client
        try await client.delete(id)
        await send(.tripDeleted)
      }

    case .tripDeleted:
      return .run { send in
        @Dependency(\.tripPersistenceClient) var client
        let trips = try await client.fetchAll()
        await send(.tripsLoaded(trips))
      }

    case .path(.element(id: _, action: .tripForm(.delegate(let delegateAction)))):
      switch delegateAction {
      case .tripSaved:
        return .run { send in
          @Dependency(\.tripPersistenceClient) var client
          let trips = try await client.fetchAll()
          await send(.tripsLoaded(trips))
        }
      }

    case .path:
      return .none
    }
  }
}

extension TripsFeature {
  @Reducer
  package enum Path {
    case tripForm(TripFormFeature)
  }
}

extension TripsFeature.Path.State: Equatable {}
extension TripsFeature.Path.Action: Equatable {}
