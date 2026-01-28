import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers

@ViewAction(for: CompareFeature.self)
struct CompareView: View {
  @Bindable var store: StoreOf<CompareFeature>
  
  var body: some View {
    VStack(spacing: 0) {
      header
      if store.comparison != nil {
        comparisonContent
      } else {
        fileSelectionArea
      }
    }
    .frame(minWidth: 800, minHeight: 600)
  }
  
  private var header: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Comparaison de Tokens")
          .font(.title)
          .fontWeight(.bold)
        
        Spacer()
        
        if store.comparison != nil {
          Button("Nouvelle Comparaison") {
            send(.resetComparison)
          }
          .controlSize(.small)
        }
      }
      
      if let error = store.loadingError {
        Text(error)
          .foregroundStyle(.red)
          .font(.caption)
      }
      
      Divider()
    }
    .padding()
  }
  
  private var fileSelectionArea: some View {
    HStack(spacing: 24) {
      fileDropZone(
        title: "Ancienne Version",
        subtitle: "Glissez le fichier JSON de l'ancienne version ici",
        isLoaded: store.isOldFileLoaded,
        onDrop: { providers in
          guard let provider = providers.first else { return false }
          send(.fileDroppedWithProvider(.old, provider))
          return true
        },
        onSelectFile: { send(.selectFileTapped(.old)) }
      )
      
      Image(systemName: "arrow.right")
        .font(.title2)
        .foregroundStyle(.secondary)
      
      fileDropZone(
        title: "Nouvelle Version", 
        subtitle: "Glissez le fichier JSON de la nouvelle version ici",
        isLoaded: store.isNewFileLoaded,
        onDrop: { providers in
          guard let provider = providers.first else { return false }
          send(.fileDroppedWithProvider(.new, provider))
          return true
        },
        onSelectFile: { send(.selectFileTapped(.new)) }
      )
    }
    .padding()
    .frame(maxHeight: .infinity)
  }
  
  private func fileDropZone(
    title: String,
    subtitle: String, 
    isLoaded: Bool,
    onDrop: @escaping ([NSItemProvider]) -> Bool,
    onSelectFile: @escaping () -> Void
  ) -> some View {
    VStack(spacing: 16) {
      VStack(spacing: 8) {
        Image(systemName: isLoaded ? "checkmark.circle.fill" : "doc.text")
          .font(.largeTitle)
          .foregroundStyle(isLoaded ? .green : .blue)
        
        Text(title)
          .font(.headline)
          .fontWeight(.semibold)
        
        if isLoaded {
          Text("Fichier chargé")
            .font(.caption)
            .foregroundStyle(.green)
        } else {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
      }
      
      if !isLoaded {
        Button("Sélectionner fichier") {
          onSelectFile()
        }
        .controlSize(.small)
      }
    }
    .frame(maxWidth: .infinity, minHeight: 200)
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(isLoaded ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(isLoaded ? Color.green : Color.blue, style: StrokeStyle(lineWidth: 2, dash: [8]))
        )
    )
    .onDrop(of: [UTType.json], isTargeted: nil) { providers in
      onDrop(providers)
    }
  }
  
  private var comparisonContent: some View {
    VStack(spacing: 0) {
      // Tabs
      tabs
      Divider()
      // Content area
      if let comparison = store.comparison {
        tabContent(for: store.selectedTab, comparison: comparison)
      }
    }
  }

  private var tabs: some View {
    HStack {
      ForEach(CompareFeature.ComparisonTab.allCases, id: \.self) { tab in
        Button(action: { send(.tabTapped(tab)) }) {
          VStack(spacing: 4) {
            Text(tab.rawValue)
              .font(.headline)
              .foregroundStyle(store.selectedTab == tab ? .primary : .secondary)

            if let comparison = store.comparison {
              Text(countForTab(tab, comparison: comparison))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .contentShape(.rect)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(store.selectedTab == tab ? Color.accentColor.opacity(0.1) : Color.clear)
          )
          .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
      }

      Spacer()
    }
    .padding(.horizontal)
  }

  private func countForTab(_ tab: CompareFeature.ComparisonTab, comparison: TokenComparison) -> String {
    switch tab {
    case .overview:
      return "Résumé"
    case .added:
      return "\(comparison.changes.added.count)"
    case .removed:
      return "\(comparison.changes.removed.count)"
    case .modified:
      return "\(comparison.changes.modified.count)"
    }
  }
  
  private func tabContent(for tab: CompareFeature.ComparisonTab, comparison: TokenComparison) -> some View {
    Group {
      switch tab {
      case .overview:
        overviewContent(comparison: comparison)
      case .added:
        addedTokensList(tokens: comparison.changes.added)
      case .removed:
        removedTokensList(tokens: comparison.changes.removed)
      case .modified:
        modifiedTokensList(modifications: comparison.changes.modified)
      }
    }
    .padding()
  }
  
  private func overviewContent(comparison: TokenComparison) -> some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("Résumé des changements")
        .font(.title2)
        .fontWeight(.semibold)
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
        summaryCard(
          title: "Tokens Ajoutés",
          count: comparison.changes.added.count,
          color: .green,
          icon: "plus.circle.fill"
        )
        
        summaryCard(
          title: "Tokens Supprimés", 
          count: comparison.changes.removed.count,
          color: .red,
          icon: "minus.circle.fill"
        )
        
        summaryCard(
          title: "Tokens Modifiés",
          count: comparison.changes.modified.count,
          color: .orange,
          icon: "pencil.circle.fill"
        )
      }
      
      Spacer()
    }
  }
  
  private func summaryCard(title: String, count: Int, color: Color, icon: String) -> some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.largeTitle)
        .foregroundStyle(color)
      
      Text("\(count)")
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(color)
      
      Text(title)
        .font(.headline)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, minHeight: 120)
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(color.opacity(0.1))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(color.opacity(0.3), lineWidth: 1)
        )
    )
  }
  
  private func addedTokensList(tokens: [TokenSummary]) -> some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(tokens) { token in
          tokenSummaryListItem(
            token: token,
            badgeColor: .green,
            badgeText: "AJOUTÉ"
          )
        }
      }
    }
  }
  
  private func removedTokensList(tokens: [TokenSummary]) -> some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(tokens) { token in
          tokenSummaryListItem(
            token: token,
            badgeColor: .red,
            badgeText: "SUPPRIMÉ"
          )
        }
      }
    }
  }
  
  private func modifiedTokensList(modifications: [TokenModification]) -> some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(modifications) { modification in
          modificationListItem(modification: modification)
        }
      }
    }
  }
  
  private func tokenSummaryListItem(token: TokenSummary, badgeColor: Color, badgeText: String) -> some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text(token.name)
          .font(.subheadline)
          .fontWeight(.medium)
        
        Text(token.path)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
      
      // Prévisualisation des couleurs si disponibles
      if let modes = token.modes {
        HStack(spacing: 6) {
          if let legacy = modes.legacy {
            colorPreview(color: Color(hex: legacy.light), size: 20)
          }
          if let newBrand = modes.newBrand {
            colorPreview(color: Color(hex: newBrand.light), size: 20)
          }
        }
      }
      
      Text(badgeText)
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(nsColor: .controlBackgroundColor))
    )
  }
  
  private func colorPreview(color: Color, size: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(color)
      .frame(width: size, height: size)
      .overlay(
        RoundedRectangle(cornerRadius: 4)
          .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
      )
  }
  
  private func modificationListItem(modification: TokenModification) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(modification.tokenName)
            .font(.subheadline)
            .fontWeight(.medium)
          
          Text(modification.tokenPath)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        
        Spacer()
        
        Text("MODIFIÉ")
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundStyle(.white)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.orange)
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }
      
      VStack(alignment: .leading, spacing: 6) {
        ForEach(modification.colorChanges) { change in
          colorChangeRow(change: change)
        }
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(nsColor: .controlBackgroundColor))
    )
  }
  
  private func colorChangeRow(change: ColorChange) -> some View {
    HStack(spacing: 8) {
      Text("\(change.brandName) • \(change.theme):")
        .font(.caption)
        .fontWeight(.medium)
        .frame(width: 100, alignment: .leading)
      
      // Ancienne couleur
      HStack(spacing: 4) {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color(hex: change.oldColor))
          .frame(width: 20, height: 20)
        Text(change.oldColor)
          .font(.caption)
      }
      
      Image(systemName: "arrow.right")
        .font(.caption)
        .foregroundStyle(.secondary)
      
      // Nouvelle couleur  
      HStack(spacing: 4) {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color(hex: change.newColor))
          .frame(width: 20, height: 20)
        Text(change.newColor)
          .font(.caption)
      }
    }
  }
}
