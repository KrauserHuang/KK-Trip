import ComposableArchitecture
import Features
import Models
import SwiftUI

package struct TripFormView: View {
  @Bindable package var store: StoreOf<TripFormFeature>

  package init(store: StoreOf<TripFormFeature>) {
    self.store = store
  }

  package var body: some View {
    Form {
      Section("基本資訊") {
        TextField("旅行名稱", text: $store.title)
        TextField("目的地", text: $store.destination)
      }

      Section("日期") {
        DatePicker(
          "出發日期",
          selection: $store.startDate,
          displayedComponents: .date
        )
        DatePicker(
          "回程日期",
          selection: $store.endDate,
          in: store.startDate...,
          displayedComponents: .date
        )
      }

      Section("備註") {
        TextField("備註", text: $store.note, axis: .vertical)
          .lineLimit(3...6)
      }
    }
    .navigationTitle(store.isEditing ? "編輯旅行" : "新增旅行")
    #if !os(macOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("儲存") {
          store.send(.saveButtonTapped)
        }
        .disabled(!store.isFormValid || store.isSaving)
      }
    }
  }
}

#Preview("Add") {
  NavigationStack {
    TripFormView(
      store: .init(
        initialState: TripFormFeature.State(),
        reducer: { TripFormFeature() }
      )
    )
  }
}

#Preview("Edit") {
  NavigationStack {
    TripFormView(
      store: .init(
        initialState: TripFormFeature.State(
          trip: Trip(
            title: "東京之旅",
            destination: "日本東京",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 5),
            note: "記得帶護照"
          )
        ),
        reducer: { TripFormFeature() }
      )
    )
  }
}
