import ComposableArchitecture
import Features
import SwiftUI

package struct HomeView: View {
  let store: StoreOf<HomeFeature>

  package init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  package var body: some View {
    TabView {
      Tab("旅行", systemImage: "list.bullet.rectangle.portrait") {
        TripsListView(
          store: store.scope(state: \.trips, action: \.trips)
        )
      }
    }
  }
}

#Preview {
  HomeView(
    store: .init(
      initialState: HomeFeature.State(),
      reducer: { HomeFeature() }
    )
  )
}
