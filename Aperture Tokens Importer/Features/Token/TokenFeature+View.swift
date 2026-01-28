import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers

@ViewAction(for: TokenFeature.self)
struct ApertureTokensView: View {
  // On utilise 'let store' directement, sans @ObservedObject wrapper ici
  // car le store est maintenant Observable par nature.
  @Bindable var store: StoreOf<TokenFeature>

  @State private var isHovering = false

  var body: some View {
    GeometryReader { geometry in
      HSplitView {
        VStack(spacing: 0) {
          header
          if store.isFileLoaded {
            nodesView
          } else {
            dropZone
          }
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
    .frame(minWidth: 600, minHeight: 400)
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

  private var header: some View {
    VStack(spacing: 8) {
      HStack {
        Text("Aperture Viewer")
          .font(.headline)
          .foregroundStyle(.purple)
        Spacer()

        if store.isFileLoaded {
          Button("Exporter Design System") {
            send(.exportButtonTapped)
          }
          .controlSize(.small)
        }
      }
      
      if store.isFileLoaded {
        HStack {
          Text("Filtres d'export:")
            .font(.caption)
            .foregroundStyle(.secondary)
          
          Toggle("Exclure tokens commençant par #", isOn: $store.excludeTokensStartingWithHash)
            .font(.caption)
            .controlSize(.mini)
          
          Toggle("Exclure tokens finissant par _hover", isOn: $store.excludeTokensEndingWithHover)
            .font(.caption)
            .controlSize(.mini)
          
          Spacer()
        }
        .padding(.top, 4)
      }
    }
    .padding()
    .background(Color(nsColor: .controlBackgroundColor))
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
  }

  var dropZone: some View {
    VStack(spacing: 16.0) {
      if store.loadingError {
        Image(systemName: "exclamationmark.circle")
          .resizable()
          .scaledToFit()
          .frame(width: 48, height: 48)
          .foregroundStyle(.red)
        Text("Erreur de chargement du fichier JSON")
          .font(.body)
          .foregroundStyle(.secondary)
      } else {
        Image(systemName: "arrow.down.doc.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 48, height: 48)
          .foregroundStyle(.purple)
        Text("Glissez votre fichier JSON ici")
          .font(.body)
          .foregroundStyle(.secondary)
      }
    }
    .padding(40)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
        .foregroundStyle(isHovering ? .purple : .gray)
        .background(isHovering ? Color.purple.opacity(0.05) : Color.clear)
    )
    .onHover { hovering in
      withAnimation(.easeInOut(duration: 0.2)) {
        isHovering = hovering
      }
      if hovering {
        NSCursor.pointingHand.push()
      } else {
        NSCursor.pop()
      }
    }
    .onTapGesture { send(.selectFileTapped) }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onDrop(of: [.json], isTargeted: nil) { providers in
      handleDrop(providers: providers)
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

  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first else { return false }
    send(.fileDroppedWithProvider(provider))
    return true
  }
}
