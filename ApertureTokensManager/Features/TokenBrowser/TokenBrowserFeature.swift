import ComposableArchitecture
import Foundation

@Reducer
struct TokenBrowserFeature {
  
  @ObservableState
  struct State: Equatable {
    let tokens: [TokenNode]
    let metadata: TokenMetadata
    var selectedNode: TokenNode?
    var expandedNodes: Set<TokenNode.ID> = []
    
    var tokenCount: Int {
      TokenHelpers.countLeafTokens(tokens)
    }
  }
  
  @CasePathable
  enum Action {
    case view(ViewAction)
    
    @CasePathable
    enum ViewAction {
      case selectNode(TokenNode)
      case expandNode(TokenNode.ID)
      case collapseNode(TokenNode.ID)
      case toggleNode(TokenNode.ID)
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let viewAction):
        return handleViewAction(viewAction, state: &state)
      }
    }
  }
  
  private func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
    switch action {
    case .selectNode(let node):
      state.selectedNode = node
      return .none
      
    case .expandNode(let id):
      state.expandedNodes.insert(id)
      return .none
      
    case .collapseNode(let id):
      state.expandedNodes.remove(id)
      return .none
      
    case .toggleNode(let id):
      if state.expandedNodes.contains(id) {
        state.expandedNodes.remove(id)
      } else {
        state.expandedNodes.insert(id)
      }
      return .none
    }
  }
}
