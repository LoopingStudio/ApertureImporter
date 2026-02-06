import SwiftUI
import ComposableArchitecture

@main
struct ApertureTokensManagerApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(initialState: AppFeature.State()) {
          AppFeature()
        }
      )
      .frame(minWidth: 900, minHeight: 650)
    }
    .defaultSize(width: 1100, height: 750)
  }
}
