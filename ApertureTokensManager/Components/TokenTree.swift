import SwiftUI

// MARK: - Token Tree View

/// Arbre de tokens unifié avec support clavier et hover effects
struct TokenTree: View {
  let nodes: [TokenNode]
  let selectedNodeId: TokenNode.ID?
  let expandedNodes: Set<TokenNode.ID>
  let isEditable: Bool
  let onSelect: (TokenNode) -> Void
  let onExpand: (TokenNode.ID) -> Void
  let onToggleEnabled: ((TokenNode.ID) -> Void)?
  
  init(
    nodes: [TokenNode],
    selectedNodeId: TokenNode.ID?,
    expandedNodes: Set<TokenNode.ID>,
    isEditable: Bool = false,
    onSelect: @escaping (TokenNode) -> Void,
    onExpand: @escaping (TokenNode.ID) -> Void,
    onToggleEnabled: ((TokenNode.ID) -> Void)? = nil
  ) {
    self.nodes = nodes
    self.selectedNodeId = selectedNodeId
    self.expandedNodes = expandedNodes
    self.isEditable = isEditable
    self.onSelect = onSelect
    self.onExpand = onExpand
    self.onToggleEnabled = onToggleEnabled
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        ForEach(nodes, id: \.id) { node in
          TokenTreeBranch(
            node: node,
            depth: 0,
            selectedNodeId: selectedNodeId,
            expandedNodes: expandedNodes,
            isEditable: isEditable,
            onSelect: onSelect,
            onExpand: onExpand,
            onToggleEnabled: onToggleEnabled
          )
        }
      }
      .padding(.vertical, 4)
    }
  }
}

// MARK: - Token Tree Branch (Recursive)

private struct TokenTreeBranch: View {
  let node: TokenNode
  let depth: Int
  let selectedNodeId: TokenNode.ID?
  let expandedNodes: Set<TokenNode.ID>
  let isEditable: Bool
  let onSelect: (TokenNode) -> Void
  let onExpand: (TokenNode.ID) -> Void
  let onToggleEnabled: ((TokenNode.ID) -> Void)?
  
  private var isExpanded: Bool { expandedNodes.contains(node.id) }
  private var isSelected: Bool { selectedNodeId == node.id }
  private var hasChildren: Bool { node.children?.isEmpty == false }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      TokenTreeRow(
        node: node,
        depth: depth,
        isSelected: isSelected,
        isExpanded: isExpanded,
        isEditable: isEditable,
        onSelect: { onSelect(node) },
        onExpand: { onExpand(node.id) },
        onToggleEnabled: { onToggleEnabled?(node.id) }
      )
      
      if isExpanded, let children = node.children {
        ForEach(children, id: \.id) { child in
          TokenTreeBranch(
            node: child,
            depth: depth + 1,
            selectedNodeId: selectedNodeId,
            expandedNodes: expandedNodes,
            isEditable: isEditable,
            onSelect: onSelect,
            onExpand: onExpand,
            onToggleEnabled: onToggleEnabled
          )
        }
      }
    }
  }
}

// MARK: - Token Tree Row

struct TokenTreeRow: View {
  let node: TokenNode
  let depth: Int
  let isSelected: Bool
  let isExpanded: Bool
  let isEditable: Bool
  let onSelect: () -> Void
  let onExpand: () -> Void
  let onToggleEnabled: () -> Void
  
  @State private var isHovering = false
  
  private var hasChildren: Bool { node.children?.isEmpty == false }
  private var indentation: CGFloat { CGFloat(depth) * 16 }
  
  var body: some View {
    HStack(spacing: 0) {
      // Indentation
      Spacer()
        .frame(width: indentation)
      
      // Expand/collapse chevron
      expandChevron
      
      // Checkbox (editable mode only)
      if isEditable {
        checkboxButton
      }
      
      // Icon (folder or color)
      nodeIcon
      
      // Name
      Text(node.name)
        .font(.system(.body, design: .default))
        .foregroundStyle(nodeTextColor)
        .lineLimit(1)
      
      Spacer()
      
      // Color previews for tokens
      if node.type == .token, let modes = node.modes {
        colorPreviews(modes)
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(rowBackground)
    .contentShape(Rectangle())
    .onTapGesture { onSelect() }
    .onHover { isHovering = $0 }
  }
  
  // MARK: - Subviews
  
  @ViewBuilder
  private var expandChevron: some View {
    if node.type == .group && hasChildren {
      Button(action: onExpand) {
        Image(systemName: "chevron.right")
          .font(.system(size: 10, weight: .semibold))
          .foregroundStyle(.secondary)
          .rotationEffect(.degrees(isExpanded ? 90 : 0))
          .animation(.easeOut(duration: 0.15), value: isExpanded)
          .frame(width: 24, height: 24)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    } else {
      Spacer()
        .frame(width: 24)
    }
  }
  
  @ViewBuilder
  private var checkboxButton: some View {
    Button(action: onToggleEnabled) {
      Image(systemName: node.isEnabled ? "checkmark.square.fill" : "square")
        .font(.system(size: 14))
        .foregroundStyle(node.isEnabled ? .purple : .gray.opacity(0.5))
    }
    .buttonStyle(.plain)
    .padding(.trailing, 6)
    .animation(.easeOut(duration: 0.15), value: node.isEnabled)
  }
  
  @ViewBuilder
  private var nodeIcon: some View {
    Group {
      if node.type == .group {
        Image(systemName: isExpanded ? "folder.fill" : "folder")
          .font(.system(size: 12))
          .foregroundStyle(.blue)
      } else if let color = firstLightColor {
        Circle()
          .fill(Color(hex: color))
          .frame(width: 12, height: 12)
          .overlay(
            Circle()
              .stroke(Color.primary.opacity(0.15), lineWidth: 0.5)
          )
      } else {
        Circle()
          .fill(Color.gray.opacity(0.3))
          .frame(width: 12, height: 12)
      }
    }
    .frame(width: 16)
    .padding(.trailing, 6)
  }
  
  @ViewBuilder
  private func colorPreviews(_ modes: TokenThemes) -> some View {
    HStack(spacing: 3) {
      if let legacy = modes.legacy {
        themePreview(legacy, label: "L")
      }
      if let newBrand = modes.newBrand {
        themePreview(newBrand, label: "N")
      }
    }
    .padding(.trailing, 4)
  }
  
  @ViewBuilder
  private func themePreview(_ appearance: TokenThemes.Appearance, label: String) -> some View {
    HStack(spacing: 2) {
      if let light = appearance.light {
        miniColorSquare(hex: light.hex, isDark: false)
      }
      if let dark = appearance.dark {
        miniColorSquare(hex: dark.hex, isDark: true)
      }
    }
  }
  
  @ViewBuilder
  private func miniColorSquare(hex: String, isDark: Bool) -> some View {
    RoundedRectangle(cornerRadius: 2)
      .fill(Color(hex: hex))
      .frame(width: 14, height: 14)
      .overlay(
        RoundedRectangle(cornerRadius: 2)
          .stroke(Color.primary.opacity(isDark ? 0.3 : 0.15), lineWidth: 0.5)
      )
  }
  
  // MARK: - Computed Properties
  
  private var nodeTextColor: Color {
    if isEditable && !node.isEnabled {
      return .secondary
    }
    return .primary
  }
  
  private var rowBackground: some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(backgroundColor)
      .overlay(
        RoundedRectangle(cornerRadius: 4)
          .stroke(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
      )
  }
  
  private var backgroundColor: Color {
    if isSelected {
      return Color.accentColor.opacity(0.15)
    } else if isHovering {
      return Color.primary.opacity(0.04)
    }
    return .clear
  }
  
  private var firstLightColor: String? {
    guard let modes = node.modes else { return nil }
    if let light = modes.legacy?.light { return light.hex }
    if let light = modes.newBrand?.light { return light.hex }
    return nil
  }
}

// MARK: - Keyboard Navigation Helper

extension View {
  /// Ajoute la navigation au clavier pour un arbre de tokens
  func tokenTreeKeyboardNavigation(
    nodes: [TokenNode],
    expandedNodes: Set<TokenNode.ID>,
    selectedNodeId: TokenNode.ID?,
    onSelect: @escaping (TokenNode) -> Void,
    onExpand: @escaping (TokenNode.ID) -> Void,
    onCollapse: @escaping (TokenNode.ID) -> Void
  ) -> some View {
    self.onKeyPress { keyPress in
      guard let selectedId = selectedNodeId else {
        // Si rien n'est sélectionné, sélectionner le premier node
        if let first = nodes.first, keyPress.key == .downArrow {
          onSelect(first)
          return .handled
        }
        return .ignored
      }
      
      let flatNodes = TokenTreeKeyboardHelper.flattenVisibleNodes(
        nodes,
        expandedNodes: expandedNodes
      )
      
      guard let currentIndex = flatNodes.firstIndex(where: { $0.id == selectedId }) else {
        return .ignored
      }
      
      switch keyPress.key {
      case .upArrow:
        if currentIndex > 0 {
          onSelect(flatNodes[currentIndex - 1])
        }
        return .handled
        
      case .downArrow:
        if currentIndex < flatNodes.count - 1 {
          onSelect(flatNodes[currentIndex + 1])
        }
        return .handled
        
      case .rightArrow:
        let node = flatNodes[currentIndex]
        if node.type == .group && node.children?.isEmpty == false {
          if !expandedNodes.contains(node.id) {
            onExpand(node.id)
          } else if let firstChild = node.children?.first {
            onSelect(firstChild)
          }
        }
        return .handled
        
      case .leftArrow:
        let node = flatNodes[currentIndex]
        if expandedNodes.contains(node.id) {
          onCollapse(node.id)
        } else {
          // Remonter au parent
          if let parent = TokenTreeKeyboardHelper.findParent(of: node.id, in: nodes) {
            onSelect(parent)
          }
        }
        return .handled
        
      default:
        return .ignored
      }
    }
  }
}

// MARK: - Keyboard Helper

enum TokenTreeKeyboardHelper {
  static func flattenVisibleNodes(
    _ nodes: [TokenNode],
    expandedNodes: Set<TokenNode.ID>
  ) -> [TokenNode] {
    var result: [TokenNode] = []
    
    for node in nodes {
      result.append(node)
      if expandedNodes.contains(node.id), let children = node.children {
        result.append(contentsOf: flattenVisibleNodes(children, expandedNodes: expandedNodes))
      }
    }
    
    return result
  }
  
  static func findParent(of nodeId: TokenNode.ID, in nodes: [TokenNode]) -> TokenNode? {
    for node in nodes {
      if let children = node.children {
        if children.contains(where: { $0.id == nodeId }) {
          return node
        }
        if let found = findParent(of: nodeId, in: children) {
          return found
        }
      }
    }
    return nil
  }
}

// MARK: - Previews

#if DEBUG
#Preview("Token Tree - Read Only") {
  TokenTree(
    nodes: PreviewData.rootNodes,
    selectedNodeId: PreviewData.singleToken.id,
    expandedNodes: [PreviewData.colorsGroup.id, PreviewData.brandGroup.id],
    isEditable: false,
    onSelect: { _ in },
    onExpand: { _ in }
  )
  .frame(width: 350, height: 400)
  .background(Color(nsColor: .windowBackgroundColor))
}

#Preview("Token Tree - Editable") {
  TokenTree(
    nodes: PreviewData.rootNodes,
    selectedNodeId: PreviewData.singleToken.id,
    expandedNodes: [PreviewData.colorsGroup.id, PreviewData.brandGroup.id],
    isEditable: true,
    onSelect: { _ in },
    onExpand: { _ in },
    onToggleEnabled: { _ in }
  )
  .frame(width: 350, height: 400)
  .background(Color(nsColor: .windowBackgroundColor))
}

#Preview("Token Tree - Collapsed") {
  TokenTree(
    nodes: PreviewData.rootNodes,
    selectedNodeId: nil,
    expandedNodes: [],
    isEditable: false,
    onSelect: { _ in },
    onExpand: { _ in }
  )
  .frame(width: 350, height: 200)
  .background(Color(nsColor: .windowBackgroundColor))
}
#endif
