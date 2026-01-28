import AppKit
import ComposableArchitecture
import Foundation

struct TokenClient {
  var exportDesignSystem: @Sendable ([TokenNode]) async throws -> Void
}

extension DependencyValues {
  var tokenClient: TokenClient {
    get { self[TokenClient.self] }
    set { self[TokenClient.self] = newValue }
  }
}

extension TokenClient: DependencyKey {
  static let liveValue: Self = {
    let service = TokenService()
    return .init(
      exportDesignSystem: { try await service.exportDesignSystem(nodes: $0) }
    )
  }()
}
