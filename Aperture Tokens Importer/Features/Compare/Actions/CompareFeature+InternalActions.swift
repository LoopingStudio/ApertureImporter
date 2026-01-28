import ComposableArchitecture
import Foundation

extension CompareFeature {
  func handleInternalAction(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
    switch action {
    case .loadFile(let fileType, let url):
      return .run { send in
        do {
          let tokens = try await tokenClient.loadJSON(url)
          await send(.internal(.fileLoaded(fileType, tokens)))
        } catch {
          await send(.internal(.loadingFailed("Erreur chargement ancien fichier: \(error.localizedDescription)")))
        }
      }
    case .fileLoaded(let fileType, let tokens):
      switch fileType {
      case .old:
        state.oldVersionTokens = tokens
        state.isOldFileLoaded = true
        state.loadingError = nil

        // Si les deux fichiers sont chargés, lancer la comparaison
        if state.isNewFileLoaded {
          return .send(.internal(.performComparison))
        }
      case .new:
        state.newVersionTokens = tokens
        state.isNewFileLoaded = true
        state.loadingError = nil

        // Si les deux fichiers sont chargés, lancer la comparaison
        if state.isOldFileLoaded {
          return .send(.internal(.performComparison))
        }
      }
      return .none
    case .performComparison:
      guard let oldTokens = state.oldVersionTokens, 
            let newTokens = state.newVersionTokens else { 
        return .none 
      }
      
      return .run { send in
        let comparison = await comparisonClient.compareTokens(oldTokens, newTokens)
        await send(.internal(.comparisonCompleted(comparison)))
      }
      
    case .comparisonCompleted(let comparison):
      state.comparison = comparison
      return .none
      
    case .loadingFailed(let error):
      state.loadingError = error
      return .none
    }
  }
}
