import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct CompareFeature: Sendable {
  @Dependency(\.tokenClient) var tokenClient
  @Dependency(\.comparisonClient) var comparisonClient

  @ObservableState
  public struct State: Equatable {
    var oldVersionTokens: [TokenNode]?
    var newVersionTokens: [TokenNode]?
    var comparison: TokenComparison?
    var isOldFileLoaded: Bool = false
    var isNewFileLoaded: Bool = false
    var loadingError: String?
    var selectedChange: TokenModification?
    
    // UI State
    var selectedTab: ComparisonTab = .overview
    
    public static var initial: Self {
      .init(
        oldVersionTokens: nil,
        newVersionTokens: nil,
        comparison: nil,
        isOldFileLoaded: false,
        isNewFileLoaded: false,
        loadingError: nil,
        selectedChange: nil,
        selectedTab: .overview
      )
    }
  }

  public enum FileType: Sendable {
    case old
    case new
  }

  public enum ComparisonTab: String, CaseIterable, Equatable {
    case overview = "Vue d'ensemble"
    case added = "Ajoutés"
    case removed = "Supprimés"  
    case modified = "Modifiés"
  }

  @CasePathable
  public enum Action: BindableAction, ViewAction, Equatable, Sendable {
    case binding(BindingAction<State>)
    case `internal`(Internal)
    case view(View)

    @CasePathable
    public enum Internal: Sendable, Equatable {
      case loadFile(FileType, URL)
      case fileLoaded(FileType, [TokenNode])
      case performComparison
      case comparisonCompleted(TokenComparison)
      case loadingFailed(String)
    }

    @CasePathable
    public enum View: Sendable, Equatable {
      case selectFileTapped(FileType)
      case fileDroppedWithProvider(FileType, NSItemProvider)
      case selectChange(TokenModification?)
      case compareButtonTapped
      case resetComparison
      case tabTapped(ComparisonTab)
    }
  }

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding: .none
      case .internal(let action): handleInternalAction(action, state: &state)
      case .view(let action): handleViewAction(action, state: &state)
      }
    }
  }
}
