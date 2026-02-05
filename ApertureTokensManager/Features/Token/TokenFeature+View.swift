import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers

@ViewAction(for: TokenFeature.self)
struct ApertureTokensView: View {
  @Bindable var store: StoreOf<TokenFeature>

  var body: some View {
    VStack(spacing: 0) {
      header
      if store.isFileLoaded {
        contentView
      } else {
        fileSelectionArea
      }
    }
  }

  private var header: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Aperture Tokens Viewer")
          .font(.title)
          .fontWeight(.bold)
        
        Spacer()

        if store.isFileLoaded {
          Button("Nouvelle Import") { send(.resetFile) }
            .controlSize(.small)
          
          Button("Exporter Design System") {
            send(.exportButtonTapped)
          }
          .controlSize(.small)
          .buttonStyle(.borderedProminent)
        }
      }
      
      if store.isFileLoaded {
        HStack {
          Text("Filtres d'export:")
            .font(.caption)
            .foregroundStyle(.secondary)
          
          Toggle("Exclure tokens commençant par #", isOn: $store.filters.excludeTokensStartingWithHash)
            .font(.caption)
            .controlSize(.mini)
          
          Toggle("Exclure tokens finissant par _hover", isOn: $store.filters.excludeTokensEndingWithHover)
            .font(.caption)
            .controlSize(.mini)
          
          Toggle("Exclure groupe Utility", isOn: $store.filters.excludeUtilityGroup)
            .font(.caption)
            .controlSize(.mini)
          
          Spacer()
        }
        .padding(.top, 4)
      }
      
      if let errorMessage = store.errorMessage {
        Text(errorMessage)
          .foregroundStyle(.red)
          .font(.caption)
      }
      
      Divider()
    }
    .padding()
  }
  
  private var fileSelectionArea: some View {
    VStack(spacing: 24) {
      DropZone(
        title: "Fichier de Tokens",
        subtitle: "Glissez votre fichier JSON ici ou cliquez pour le sélectionner",
        isLoaded: store.isFileLoaded,
        isLoading: store.isLoading,
        hasError: store.loadingError,
        errorMessage: store.errorMessage,
        primaryColor: .purple,
        onDrop: { providers in
          guard let provider = providers.first else { return false }
          send(.fileDroppedWithProvider(provider))
          return true
        },
        onSelectFile: { send(.selectFileTapped) },
        metadata: store.metadata
      )
      
      if !store.importHistory.isEmpty {
        ImportHistoryView(
          history: store.importHistory,
          onEntryTapped: { send(.historyEntryTapped($0)) },
          onRemove: { send(.removeHistoryEntry($0)) },
          onClear: { send(.clearHistory) }
        )
        .frame(maxWidth: 500)
      }
    }
    .padding()
    .frame(maxHeight: .infinity)
    .onAppear { send(.onAppear) }
  }

  private var contentView: some View {
    GeometryReader { geometry in
      HSplitView {
        VStack(spacing: 0) {
          nodesView
        }
        .frame(
          minWidth: 200,
          idealWidth: geometry.size.width * store.splitViewRatio,
          maxWidth: max(200, geometry.size.width * 0.8)
        )

        rightView
          .frame(
            minWidth: 150,
            idealWidth: geometry.size.width * (1 - store.splitViewRatio)
          )
      }
    }
  }

  private var nodesView: some View {
    List {
      ForEach(store.rootNodes, id: \.id) { node in
        NodeTreeView(
          node: node,
          selectedNodeId: store.selectedNode?.id,
          expandedNodes: store.expandedNodes,
          onToggle: { send(.toggleNode($0)) },
          onSelect: { send(.selectNode($0)) },
          onExpand: {
            if store.expandedNodes.contains($0) {
              send(.collapseNode($0))
            } else {
              send(.expandNode($0))
            }
          }
        )
      }
    }
    .listStyle(.sidebar)
    .frame(minHeight: 300, maxHeight: .infinity)
    .onKeyPress { keyPress in
      switch keyPress.key {
      case .upArrow, .downArrow, .rightArrow, .leftArrow:
        send(.keyPressed(keyPress.key))
        return .handled
      default:
        return .ignored
      }
    }
  }

  @ViewBuilder
  private var rightView: some View {
    if let selectedNode = store.selectedNode {
      TokenDetailView(node: selectedNode)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      ContentUnavailableView("Sélectionnez un token", systemImage: "paintbrush")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
// MARK: - Previews

#if DEBUG
#Preview("Empty State") {
  ApertureTokensView(
    store: Store(initialState: .initial) {
      TokenFeature()
    }
  )
  .frame(width: 800, height: 600)
}

#Preview("With File Loaded") {
  ApertureTokensView(
    store: Store(initialState: TokenFeature.State(
      rootNodes: PreviewData.rootNodes,
      isFileLoaded: true,
      isLoading: false,
      loadingError: false,
      errorMessage: nil,
      metadata: PreviewData.metadata,
      selectedNode: PreviewData.singleToken,
      expandedNodes: [PreviewData.colorsGroup.id, PreviewData.brandGroup.id],
      allNodes: [],
      currentFileURL: nil,
      splitViewRatio: 0.5
    )) {
      TokenFeature()
    }
  )
  .frame(width: 900, height: 600)
}

#Preview("Loading State") {
  ApertureTokensView(
    store: Store(initialState: TokenFeature.State(
      rootNodes: [],
      isFileLoaded: false,
      isLoading: true,
      loadingError: false,
      errorMessage: nil,
      metadata: nil,
      selectedNode: nil,
      expandedNodes: [],
      allNodes: [],
      currentFileURL: nil,
      splitViewRatio: 0.6
    )) {
      TokenFeature()
    }
  )
  .frame(width: 800, height: 600)
}
#endif

