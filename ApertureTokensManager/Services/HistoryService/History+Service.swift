import Foundation
import Sharing

actor HistoryService {
  private static let maxEntries = 10
  
  @Shared(.importHistory) private var importHistory
  @Shared(.comparisonHistory) private var comparisonHistory
  
  // MARK: - Import History
  
  func getImportHistory() -> [ImportHistoryEntry] {
    importHistory
  }
  
  func addImportEntry(_ entry: ImportHistoryEntry) {
    $importHistory.withLock { history in
      history.removeAll { $0.fileName == entry.fileName }
      history.insert(entry, at: 0)
      if history.count > Self.maxEntries {
        history = Array(history.prefix(Self.maxEntries))
      }
    }
  }
  
  func removeImportEntry(_ id: UUID) {
    $importHistory.withLock { $0.removeAll { $0.id == id } }
  }
  
  func clearImportHistory() {
    $importHistory.withLock { $0.removeAll() }
  }
  
  // MARK: - Comparison History
  
  func getComparisonHistory() -> [ComparisonHistoryEntry] {
    comparisonHistory
  }
  
  func addComparisonEntry(_ entry: ComparisonHistoryEntry) {
    $comparisonHistory.withLock { history in
      history.removeAll {
        $0.oldFile.fileName == entry.oldFile.fileName &&
        $0.newFile.fileName == entry.newFile.fileName
      }
      history.insert(entry, at: 0)
      if history.count > Self.maxEntries {
        history = Array(history.prefix(Self.maxEntries))
      }
    }
  }
  
  func removeComparisonEntry(_ id: UUID) {
    $comparisonHistory.withLock { $0.removeAll { $0.id == id } }
  }
  
  func clearComparisonHistory() {
    $comparisonHistory.withLock { $0.removeAll() }
  }
}
