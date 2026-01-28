import ComposableArchitecture
import Foundation

extension TokenFeature {
  func handleBindingAction(_ action: BindingAction<State>, state: inout State) -> EffectOf<Self> {
    switch action {
    case \.excludeTokensStartingWithHash:
      return .send(.internal(.applyFilters))
    case \.excludeTokensEndingWithHover:
      return .send(.internal(.applyFilters))
    default: return .none
    }
  }
}
