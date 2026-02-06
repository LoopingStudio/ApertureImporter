import ComposableArchitecture
import Foundation

extension CompareFeature {
  func handleViewAction(_ action: Action.View, state: inout State) -> EffectOf<Self> {
    switch action {
    case .acceptAutoSuggestion(let removedTokenPath):
      state.changes?.acceptAutoSuggestion(for: removedTokenPath)
      return .none
      
    case .clearHistory:
      return .run { send in
        await historyClient.clearComparisonHistory()
        await send(.internal(.historyLoaded([])))
      }
      
    case .compareButtonTapped:
      if state.oldFile.isLoaded && state.newFile.isLoaded {
        return .send(.internal(.performComparison))
      }
      return .none
      
    case .exportToNotionTapped:
      guard let changes = state.changes else { return .none }
      return .run { [changes, oldMetadata = state.oldFile.metadata, newMetadata = state.newFile.metadata] _ in
        guard let oldMetadata, let newMetadata else { return }
        try await comparisonClient.exportToNotion(changes, oldMetadata, newMetadata)
      } catch: { error, _ in
        print("Erreur export Notion: \(error)")
      }
      
    case .fileDroppedWithProvider(let fileType, let provider):
      if fileType == .old {
        state.oldFile.isLoading = true
      } else {
        state.newFile.isLoading = true
      }
      return .run { send in
        guard let url = await fileClient.handleFileDrop(provider) else { 
          await send(.internal(.loadingFailed("Impossible de lire le fichier")))
          return 
        }
        await send(.internal(.loadFile(fileType, url)))
      }
      
    case .historyEntryTapped(let entry):
      return .send(.internal(.loadFromHistoryEntry(entry)))
      
    case .onAppear:
      return .run { send in
        let history = await historyClient.getComparisonHistory()
        await send(.internal(.historyLoaded(history)))
      }
      
    case .rejectAutoSuggestion(let removedTokenPath):
      state.changes?.rejectAutoSuggestion(for: removedTokenPath)
      return .none
      
    case .removeFile(let fileType):
      if fileType == .old {
        state.oldFile.reset()
      } else {
        state.newFile.reset()
      }
      state.changes = nil
      state.selectedTab = .overview
      return .none
      
    case .removeHistoryEntry(let id):
      return .run { send in
        await historyClient.removeComparisonEntry(id)
        let history = await historyClient.getComparisonHistory()
        await send(.internal(.historyLoaded(history)))
      }
      
    case .resetComparison:
      let history = state.comparisonHistory
      state = .initial
      state.comparisonHistory = history
      return .none
      
    case .selectChange(let change):
      state.selectedChange = change
      return .none
      
    case .selectFileTapped(let fileType):
      if fileType == .old {
        state.oldFile.isLoading = true
      } else {
        state.newFile.isLoading = true
      }
      return .run { send in
        guard let url = try? await fileClient.pickFile() else { 
          await send(.internal(.loadingFailed("Aucun fichier sélectionné")))
          return 
        }
        await send(.internal(.loadFile(fileType, url)))
      }
      
    case .suggestReplacement(let removedTokenPath, let replacementTokenPath):
      guard state.changes != nil else { return .none }
      
      if let replacementPath = replacementTokenPath {
        state.changes?.addReplacementSuggestion(removedTokenPath: removedTokenPath, suggestedTokenPath: replacementPath)
      } else {
        state.changes?.removeReplacementSuggestion(for: removedTokenPath)
      }
      return .none
      
    case .switchFiles:
      let temp = state.oldFile
      state.oldFile = state.newFile
      state.newFile = temp
      state.changes = nil
      state.selectedTab = .overview
      return .none
      
    case .tabTapped(let tab):
      state.selectedTab = tab
      return .none
    }
  }
}
