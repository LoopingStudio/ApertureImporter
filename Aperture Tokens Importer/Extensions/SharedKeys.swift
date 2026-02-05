import Foundation
import Sharing

extension URL {
  static let importHistory = Self.documentsDirectory.appending(component: "import-history.json")
  static let comparisonHistory = Self.documentsDirectory.appending(component: "comparison-history.json")
  
  func securityScopedBookmark() -> Data? {
    try? bookmarkData(
      options: .withSecurityScope,
      includingResourceValuesForKeys: nil,
      relativeTo: nil
    )
  }
}

extension SharedKey where Self == FileStorageKey<[ImportHistoryEntry]>.Default {
  static var importHistory: Self {
    Self[.fileStorage(.importHistory), default: []]
  }
}

extension SharedKey where Self == FileStorageKey<[ComparisonHistoryEntry]>.Default {
  static var comparisonHistory: Self {
    Self[.fileStorage(.comparisonHistory), default: []]
  }
}

// MARK: - Filter Settings

extension SharedKey where Self == AppStorageKey<Bool>.Default {
  static var excludeTokensStartingWithHash: Self {
    Self[.appStorage("filter_excludeHash"), default: false]
  }

  static var excludeTokensEndingWithHover: Self {
    Self[.appStorage("filter_excludeHover"), default: false]
  }
}
