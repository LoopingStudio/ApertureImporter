import SwiftUI

struct ReadOnlyNodeTreeView: View {
  let node: TokenNode
  let selectedNodeId: TokenNode.ID?
  let expandedNodes: Set<TokenNode.ID>
  let onSelect: (TokenNode) -> Void
  let onExpand: (TokenNode.ID) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ReadOnlyNodeRow(
        node: node,
        isSelected: selectedNodeId == node.id,
        isExpanded: expandedNodes.contains(node.id),
        selectAction: { onSelect(node) },
        expandAction: { onExpand(node.id) }
      )
      
      if expandedNodes.contains(node.id), let children = node.children {
        ForEach(children, id: \.id) { child in
          ReadOnlyNodeTreeView(
            node: child,
            selectedNodeId: selectedNodeId,
            expandedNodes: expandedNodes,
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
#Preview("ReadOnly Node Tree - Collapsed") {
  List {
    ReadOnlyNodeTreeView(
      node: PreviewData.colorsGroup,
      selectedNodeId: nil,
      expandedNodes: [],
      onSelect: { _ in },
      onExpand: { _ in }
    )
  }
  .listStyle(.sidebar)
  .frame(width: 300, height: 400)
}

#Preview("ReadOnly Node Tree - Expanded") {
  List {
    ReadOnlyNodeTreeView(
      node: PreviewData.colorsGroup,
      selectedNodeId: PreviewData.singleToken.id,
      expandedNodes: [
        PreviewData.colorsGroup.id,
        PreviewData.brandGroup.id
      ],
      onSelect: { _ in },
      onExpand: { _ in }
    )
  }
  .listStyle(.sidebar)
  .frame(width: 300, height: 400)
}
#endif
