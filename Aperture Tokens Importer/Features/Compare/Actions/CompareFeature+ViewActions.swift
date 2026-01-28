import ComposableArchitecture
import Foundation

extension CompareFeature {
  func handleViewAction(_ action: Action.View, state: inout State) -> EffectOf<Self> {
    switch action {
    case .selectFileTapped(let fileType):
      return .run { send in
        guard let url = try? await tokenClient.pickFile() else { return }
        await send(.internal(.loadFile(fileType, url)))
      }
    case .fileDroppedWithProvider(let fileType, let provider):
      return .run { send in
        guard let url = await tokenClient.handleFileDrop(provider) else { return }
        await send(.internal(.loadFile(fileType, url)))
      }
    case .selectChange(let change):
      state.selectedChange = change
      return .none
    case .compareButtonTapped:
      if state.isOldFileLoaded && state.isNewFileLoaded {
        return .send(.internal(.performComparison))
      }
      return .none
    case .resetComparison:
      state.oldVersionTokens = nil
      state.newVersionTokens = nil
      state.comparison = nil
      state.isOldFileLoaded = false
      state.isNewFileLoaded = false
      state.selectedChange = nil
      state.selectedTab = .overview
      return .none
    case .tabTapped(let tab):
      state.selectedTab = tab
      return .none
    }
  }
}
