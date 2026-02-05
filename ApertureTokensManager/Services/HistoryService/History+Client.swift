import Dependencies
import Foundation

struct HistoryClient {
  // Import history
  var getImportHistory: @Sendable () async -> [ImportHistoryEntry]
  var addImportEntry: @Sendable (ImportHistoryEntry) async -> Void
  var removeImportEntry: @Sendable (UUID) async -> Void
  var clearImportHistory: @Sendable () async -> Void
  
  // Comparison history
  var getComparisonHistory: @Sendable () async -> [ComparisonHistoryEntry]
  var addComparisonEntry: @Sendable (ComparisonHistoryEntry) async -> Void
  var removeComparisonEntry: @Sendable (UUID) async -> Void
  var clearComparisonHistory: @Sendable () async -> Void
}

extension HistoryClient: DependencyKey {
  static let liveValue: Self = {
    let service = HistoryService()
    return .init(
      getImportHistory: { await service.getImportHistory() },
      addImportEntry: { await service.addImportEntry($0) },
      removeImportEntry: { await service.removeImportEntry($0) },
      clearImportHistory: { await service.clearImportHistory() },
      getComparisonHistory: { await service.getComparisonHistory() },
      addComparisonEntry: { await service.addComparisonEntry($0) },
      removeComparisonEntry: { await service.removeComparisonEntry($0) },
      clearComparisonHistory: { await service.clearComparisonHistory() }
    )
  }()
  
  static let testValue: Self = .init(
    getImportHistory: { [] },
    addImportEntry: { _ in },
    removeImportEntry: { _ in },
    clearImportHistory: { },
    getComparisonHistory: { [] },
    addComparisonEntry: { _ in },
    removeComparisonEntry: { _ in },
    clearComparisonHistory: { }
  )
}

extension DependencyValues {
  var historyClient: HistoryClient {
    get { self[HistoryClient.self] }
    set { self[HistoryClient.self] = newValue }
  }
}
