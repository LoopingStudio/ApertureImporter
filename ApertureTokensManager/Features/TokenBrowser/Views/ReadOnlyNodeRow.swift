import SwiftUI

struct ReadOnlyNodeRow: View {
  let node: TokenNode
  let isSelected: Bool
  let isExpanded: Bool
  let selectAction: () -> Void
  let expandAction: () -> Void

  var body: some View {
    HStack {
      if node.type == .group && node.children?.isEmpty == false {
        Button(action: expandAction) {
          Image(systemName: "chevron.down")
            .fontWeight(.semibold)
            .rotationEffect(.degrees(isExpanded ? 0 : -90))
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(width: 24, height: 24)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
      } else {
        Spacer()
          .frame(width: 24)
      }

      if node.type == .group {
        Image(systemName: "folder.fill")
          .foregroundStyle(.blue)
      } else if let lightColor = getFirstAvailableLightColor() {
        Circle()
          .fill(Color(hex: lightColor))
          .frame(width: 10, height: 10)
          .overlay(Circle().stroke(.tertiary, lineWidth: 0.5))
      }

      Text(node.name)
        .foregroundStyle(.primary)
      
      Spacer()
    }
    .padding(.horizontal, 4)
    .padding(.vertical, 2)
    .background(
      RoundedRectangle(cornerRadius: 4)
        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
    )
    .contentShape(Rectangle())
    .onTapGesture { selectAction() }
  }
  
  private func getFirstAvailableLightColor() -> String? {
    guard let modes = node.modes else { return nil }

    if let lightValue = modes.legacy?.light {
      return lightValue.hex
    }
    if let lightValue = modes.newBrand?.light {
      return lightValue.hex
    }
    return nil
  }
}

// MARK: - Previews

#if DEBUG
#Preview("ReadOnly Node Row - Token") {
  List {
    ReadOnlyNodeRow(
      node: PreviewData.singleToken,
      isSelected: false,
      isExpanded: false,
      selectAction: {},
      expandAction: {}
    )
    ReadOnlyNodeRow(
      node: PreviewData.singleToken,
      isSelected: true,
      isExpanded: false,
      selectAction: {},
      expandAction: {}
    )
  }
  .listStyle(.sidebar)
  .frame(width: 300, height: 150)
}

#Preview("ReadOnly Node Row - Group") {
  List {
    ReadOnlyNodeRow(
      node: PreviewData.colorsGroup,
      isSelected: false,
      isExpanded: false,
      selectAction: {},
      expandAction: {}
    )
    ReadOnlyNodeRow(
      node: PreviewData.colorsGroup,
      isSelected: false,
      isExpanded: true,
      selectAction: {},
      expandAction: {}
    )
  }
  .listStyle(.sidebar)
  .frame(width: 300, height: 150)
}
#endif
