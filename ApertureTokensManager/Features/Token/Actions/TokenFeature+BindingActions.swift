import ComposableArchitecture
import Foundation

extension TokenFeature {
  func handleBindingAction(_ action: BindingAction<State>, state: inout State) -> EffectOf<Self> {
    // Les filtres @Shared sont gérés via publisher dans .observeFilters
    return .none
  }
}
