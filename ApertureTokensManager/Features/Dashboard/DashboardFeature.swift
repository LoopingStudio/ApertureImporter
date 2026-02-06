import AppKit
import ComposableArchitecture
import Foundation

@Reducer
struct DashboardFeature {
  
  @ObservableState
  struct State: Equatable {
    @Shared(.designSystemBase) var designSystemBase: DesignSystemBase?
    @Shared(.tokenFilters) var filters: TokenFilters
    var isExportPopoverPresented: Bool = false
    
    // Token Browser Presentation
    @Presents var tokenBrowser: TokenBrowserFeature.State?
    
    static var initial: State { State() }
  }
  
  @CasePathable
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case view(ViewAction)
    case `internal`(InternalAction)
    case delegate(DelegateAction)
    case tokenBrowser(PresentationAction<TokenBrowserFeature.Action>)
    
    @CasePathable
    enum ViewAction {
      case clearBaseButtonTapped
      case compareWithBaseButtonTapped
      case exportButtonTapped
      case confirmExportButtonTapped
      case dismissExportPopover
      case openFileButtonTapped
      case tokenCountTapped
    }
    
    enum InternalAction {
      case baseCleared
    }
    
    enum DelegateAction: Equatable {
      case compareWithBase(tokens: [TokenNode], metadata: TokenMetadata)
    }
  }
  
  @Dependency(\.exportClient) var exportClient
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .view(let viewAction):
        return handleViewAction(viewAction, state: &state)
        
      case .internal(let internalAction):
        return handleInternalAction(internalAction, state: &state)
        
      case .delegate:
        return .none
        
      case .tokenBrowser:
        return .none
      }
    }
    .ifLet(\.$tokenBrowser, action: \.tokenBrowser) {
      TokenBrowserFeature()
    }
  }
  
  private func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
    switch action {
    case .clearBaseButtonTapped:
      state.$designSystemBase.withLock { $0 = nil }
      return .send(.internal(.baseCleared))
      
    case .compareWithBaseButtonTapped:
      guard let base = state.designSystemBase else { return .none }
      return .send(.delegate(.compareWithBase(tokens: base.tokens, metadata: base.metadata)))
      
    case .exportButtonTapped:
      state.isExportPopoverPresented = true
      return .none
      
    case .confirmExportButtonTapped:
      guard let base = state.designSystemBase else { return .none }
      state.isExportPopoverPresented = false
      return .run { _ in
        try await exportClient.exportDesignSystem(base.tokens)
      }
      
    case .dismissExportPopover:
      state.isExportPopoverPresented = false
      return .none
      
    case .openFileButtonTapped:
      guard let base = state.designSystemBase,
            let url = base.resolveURL() else { return .none }
      return .run { _ in
        _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        NSWorkspace.shared.activateFileViewerSelecting([url])
      }
      
    case .tokenCountTapped:
      guard let base = state.designSystemBase else { return .none }
      state.tokenBrowser = TokenBrowserFeature.State(
        tokens: base.tokens,
        metadata: base.metadata
      )
      return .none
    }
  }
  
  private func handleInternalAction(_ action: Action.InternalAction, state: inout State) -> Effect<Action> {
    switch action {
    case .baseCleared:
      return .none
    }
  }
}
