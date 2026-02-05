import SwiftUI

struct NodeTreeView: View {
  let node: TokenNode
  let selectedNodeId: TokenNode.ID?
  let expandedNodes: Set<TokenNode.ID>
  let onToggle: (TokenNode.ID) -> Void
  let onSelect: (TokenNode) -> Void
  let onExpand: (TokenNode.ID) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      NodeRow(
        node: node,
        isSelected: selectedNodeId == node.id,
        isExpanded: expandedNodes.contains(node.id),
        action: { onToggle(node.id) },
        selectAction: { onSelect(node) },
        expandAction: { onExpand(node.id) }
      )
      
      if expandedNodes.contains(node.id), let children = node.children {
        ForEach(children, id: \.id) { child in
          NodeTreeView(
            node: child,
            selectedNodeId: selectedNodeId,
            expandedNodes: expandedNodes,
            onToggle: onToggle,
            onSelect: onSelect,
            onExpand: onExpand
          )
          .padding(.leading, 16)
        }
      }
    }
  }
}

// MARK: - Previews

#if DEBUG
#Preview("Node Tree - Collapsed") {
  List {
    NodeTreeView(
      node: PreviewData.colorsGroup,
      selectedNodeId: nil,
      expandedNodes: [],
      onToggle: { _ in },
      onSelect: { _ in },
      onExpand: { _ in }
    )
  }
  .listStyle(.sidebar)
  .frame(width: 300, height: 400)
}

#Preview("Node Tree - Expanded") {
  List {
    NodeTreeView(
      node: PreviewData.colorsGroup,
      selectedNodeId: PreviewData.singleToken.id,
      expandedNodes: [
        PreviewData.colorsGroup.id,
        PreviewData.brandGroup.id
      ],
      onToggle: { _ in },
      onSelect: { _ in },
      onExpand: { _ in }
    )
  }
  .listStyle(.sidebar)
  .frame(width: 300, height: 400)
}

#Preview("Single Token") {
  List {
    NodeTreeView(
      node: PreviewData.singleToken,
      selectedNodeId: PreviewData.singleToken.id,
      expandedNodes: [],
      onToggle: { _ in },
      onSelect: { _ in },
      onExpand: { _ in }
    )
  }
  .listStyle(.sidebar)
  .frame(width: 300, height: 100)
}
#endif
