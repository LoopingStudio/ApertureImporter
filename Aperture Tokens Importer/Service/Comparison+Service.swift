import Foundation

actor ComparisonService {
  
  func compareTokens(oldTokens: [TokenNode], newTokens: [TokenNode]) async -> TokenComparison {
    let oldFlat = flattenTokens(oldTokens)
    let newFlat = flattenTokens(newTokens)
    
    // Créer des dictionnaires pour la comparaison rapide par chemin
    let oldDict = Dictionary(uniqueKeysWithValues: oldFlat.map { ($0.path ?? $0.name, $0) })
    let newDict = Dictionary(uniqueKeysWithValues: newFlat.map { ($0.path ?? $0.name, $0) })
    
    // Trouver les tokens ajoutés, supprimés et modifiés
    let added = findAddedTokens(oldDict: oldDict, newDict: newDict)
    let removed = findRemovedTokens(oldDict: oldDict, newDict: newDict)
    let modified = findModifiedTokens(oldDict: oldDict, newDict: newDict)
    
    let changes = ComparisonChanges(
      added: added,
      removed: removed,
      modified: modified
    )
    
    return TokenComparison(changes: changes)
  }
  
  // MARK: - Private Methods
  
  private func flattenTokens(_ nodes: [TokenNode]) -> [TokenNode] {
    var result: [TokenNode] = []
    
    func addTokensRecursively(_ nodes: [TokenNode]) {
      for node in nodes {
        if node.type == .token {
          result.append(node)
        }
        if let children = node.children {
          addTokensRecursively(children)
        }
      }
    }
    
    addTokensRecursively(nodes)
    return result
  }
  
  private func findAddedTokens(oldDict: [String: TokenNode], newDict: [String: TokenNode]) -> [TokenSummary] {
    return newDict.values.compactMap { newToken in
      guard !oldDict.keys.contains(newToken.path ?? newToken.name) else { return nil }
      return TokenSummary(from: newToken)
    }
  }
  
  private func findRemovedTokens(oldDict: [String: TokenNode], newDict: [String: TokenNode]) -> [TokenSummary] {
    return oldDict.values.compactMap { oldToken in
      guard !newDict.keys.contains(oldToken.path ?? oldToken.name) else { return nil }
      return TokenSummary(from: oldToken)
    }
  }
  
  private func findModifiedTokens(oldDict: [String: TokenNode], newDict: [String: TokenNode]) -> [TokenModification] {
    var modifications: [TokenModification] = []
    
    for (path, oldToken) in oldDict {
      guard let newToken = newDict[path],
            let oldModes = oldToken.modes,
            let newModes = newToken.modes else { continue }
      
      let colorChanges = findColorChanges(oldModes: oldModes, newModes: newModes)
      
      if !colorChanges.isEmpty {
        let modification = TokenModification(
          tokenPath: path,
          tokenName: oldToken.name,
          colorChanges: colorChanges
        )
        modifications.append(modification)
      }
    }
    
    return modifications
  }
  
  private func findColorChanges(oldModes: TokenThemes, newModes: TokenThemes) -> [ColorChange] {
    var changes: [ColorChange] = []
    
    // Comparer Legacy
    if let oldLegacy = oldModes.legacy, let newLegacy = newModes.legacy {
      if oldLegacy.light != newLegacy.light {
        changes.append(ColorChange(
          brandName: Brand.legacy,
          theme: ThemeType.light,
          oldColor: oldLegacy.light,
          newColor: newLegacy.light
        ))
      }
      if oldLegacy.dark != newLegacy.dark {
        changes.append(ColorChange(
          brandName: Brand.legacy,
          theme: ThemeType.dark,
          oldColor: oldLegacy.dark,
          newColor: newLegacy.dark
        ))
      }
    }
    
    // Comparer New Brand
    if let oldNewBrand = oldModes.newBrand, let newNewBrand = newModes.newBrand {
      if oldNewBrand.light != newNewBrand.light {
        changes.append(ColorChange(
          brandName: Brand.newBrand,
          theme: ThemeType.light,
          oldColor: oldNewBrand.light,
          newColor: newNewBrand.light
        ))
      }
      if oldNewBrand.dark != newNewBrand.dark {
        changes.append(ColorChange(
          brandName: Brand.newBrand,
          theme: ThemeType.dark,
          oldColor: oldNewBrand.dark,
          newColor: newNewBrand.dark
        ))
      }
    }
    
    return changes
  }
}