import ComposableArchitecture

@Reducer
package struct HomeFeature {
  @ObservableState
  package struct State: Equatable {
    package var trips = TripsFeature.State()

    package init() {}
  }

  @CasePathable
  package enum Action: Equatable {
    case trips(TripsFeature.Action)
  }

  package init() {}

  package var body: some ReducerOf<Self> {
    Scope(state: \.trips, action: \.trips) {
      TripsFeature()
    }
    Reduce(core)
  }

  package func core(
    into state: inout State, action: Action
  ) -> Effect<Action> {
    switch action {
    case .trips:
      return .none
    }
  }
}
