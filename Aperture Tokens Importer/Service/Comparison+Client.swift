import Foundation
import ComposableArchitecture

struct ComparisonClient {
  var compareTokens: @Sendable ([TokenNode], [TokenNode]) async -> TokenComparison
}

extension DependencyValues {
  var comparisonClient: ComparisonClient {
    get { self[ComparisonClient.self] }
    set { self[ComparisonClient.self] = newValue }
  }
}

extension ComparisonClient: DependencyKey {
  static let liveValue: Self = {
    let service = ComparisonService()
    return .init(
      compareTokens: { oldTokens, newTokens in
        await service.compareTokens(oldTokens: oldTokens, newTokens: newTokens)
      }
    )
  }()
}