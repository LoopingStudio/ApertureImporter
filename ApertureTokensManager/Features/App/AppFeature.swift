import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
  
  enum Tab: Equatable, Hashable {
    case dashboard
    case importer
    case compare
  }
  
  @ObservableState
  struct State: Equatable {
    var selectedTab: Tab = .dashboard
    var dashboard: DashboardFeature.State = .initial
    var token: TokenFeature.State = .initial
    var compare: CompareFeature.State = .initial
  }
  
  enum Action {
    case tabSelected(Tab)
    case dashboard(DashboardFeature.Action)
    case token(TokenFeature.Action)
    case compare(CompareFeature.Action)
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: \.dashboard, action: \.dashboard) {
      DashboardFeature()
    }
    Scope(state: \.token, action: \.token) {
      TokenFeature()
    }
    Scope(state: \.compare, action: \.compare) {
      CompareFeature()
    }
    
    Reduce { state, action in
      switch action {
      case .tabSelected(let tab):
        state.selectedTab = tab
        return .none
        
      // MARK: - Dashboard Delegate Actions
      case .dashboard(.delegate(.compareWithBase(let tokens, let metadata))):
        state.selectedTab = .compare
        return .send(.compare(.internal(.setBaseAsOldFile(tokens: tokens, metadata: metadata))))
        
      case .dashboard:
        return .none
        
      // MARK: - Token Delegate Actions
      case .token(.delegate(.baseUpdated)):
        // Could trigger dashboard refresh if needed
        return .none
        
      case .token:
        return .none
        
      // MARK: - Compare Actions
      case .compare:
        return .none
      }
    }
  }
}
