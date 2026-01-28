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
