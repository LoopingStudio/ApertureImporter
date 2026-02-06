import SwiftUI

struct TokenDetailView: View {
  let node: TokenNode
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(node.name)
            .font(.title2)
            .fontWeight(.semibold)
          
          if !node.isEnabled {
            Text("Exclu")
              .font(.caption2)
              .fontWeight(.medium)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.orange.opacity(0.2))
              .foregroundStyle(.orange)
              .clipShape(Capsule())
          }
        }
        
        HStack {
          Image(systemName: node.type == .group ? "folder.fill" : "paintbrush.fill")
            .foregroundStyle(node.type == .group ? .blue : .purple)
          Text(node.type == .group ? "Dossier" : "Token")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        
        if let path = node.path {
          Text("Chemin: \(path)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      
      if node.type == .group {
        // Affichage des tokens enfants pour un groupe
        let childTokens = getAllChildTokens(from: node)
        if !childTokens.isEmpty {
          ScrollView {
            VStack(alignment: .leading, spacing: 12) {
              Text("Tokens (\(childTokens.count))")
                .font(.headline)
                .fontWeight(.medium)
              
              LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(childTokens) { token in
                  tokenRow(token: token)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                      RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
              }
            }
          }
        } else {
          Text("Aucun token dans ce groupe")
            .foregroundStyle(.secondary)
            .italic()
        }
      } else if let modes = node.modes {
        // Affichage des thèmes pour un token individuel - layout vertical compact
        singleTokenThemes(modes: modes)
      }
      Spacer()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
  
  // MARK: - Single Token Themes (redesigned)
  
  @ViewBuilder
  private func singleTokenThemes(modes: TokenThemes) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      // Legacy Brand
      if let legacy = modes.legacy {
        brandSection(name: Brand.legacy, theme: legacy, accentColor: .blue)
      }
      
      // New Brand
      if let newBrand = modes.newBrand {
        brandSection(name: Brand.newBrand, theme: newBrand, accentColor: .purple)
      }
    }
  }
  
  @ViewBuilder
  private func brandSection(name: String, theme: TokenThemes.Appearance, accentColor: Color) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      // Brand header
      HStack(spacing: 6) {
        Circle()
          .fill(accentColor)
          .frame(width: 8, height: 8)
        Text(name)
          .font(.subheadline)
          .fontWeight(.semibold)
      }
      
      // Theme colors in horizontal layout
      HStack(spacing: 16) {
        if let lightValue = theme.light {
          themeColorCard(value: lightValue, label: "Light", icon: "sun.max.fill")
        }
        if let darkValue = theme.dark {
          themeColorCard(value: darkValue, label: "Dark", icon: "moon.fill")
        }
      }
    }
    .padding()
    .background(Color(.controlBackgroundColor).opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
  
  @ViewBuilder
  private func themeColorCard(value: TokenValue, label: String, icon: String) -> some View {
    ThemeColorCardView(value: value, label: label, icon: icon)
  }
  
  // MARK: - Group Content
  
  // Fonction pour collecter récursivement tous les tokens enfants
  private func getAllChildTokens(from node: TokenNode) -> [TokenNode] {
    var tokens: [TokenNode] = []
    
    if let children = node.children {
      for child in children {
        if child.type == .token {
          tokens.append(child)
        } else if child.type == .group {
          tokens.append(contentsOf: getAllChildTokens(from: child))
        }
      }
    }
    return tokens
  }
  
  // Vue pour afficher un token dans la liste
  private func tokenRow(token: TokenNode) -> some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 6) {
          Text(token.name)
            .font(.subheadline)
            .fontWeight(.medium)
          
          if !token.isEnabled {
            Text("Exclu")
              .font(.caption2)
              .fontWeight(.medium)
              .padding(.horizontal, 4)
              .padding(.vertical, 1)
              .background(Color.orange.opacity(0.2))
              .foregroundStyle(.orange)
              .clipShape(Capsule())
          }
        }
        
        if let path = token.path {
          Text(path)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
      }
      
      Spacer()
      
      if let modes = token.modes {
        CompactColorPreview(modes: modes)
      }
    }
    .opacity(token.isEnabled ? 1.0 : 0.5)
  }

}

// MARK: - Theme Color Card with Popover

private struct ThemeColorCardView: View {
  let value: TokenValue
  let label: String
  let icon: String
  
  @State private var showPopover = false
  @State private var isHovering = false
  
  var body: some View {
    HStack(spacing: 12) {
      // Color preview - clickable
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(hex: value.hex))
        .frame(width: 48, height: 48)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.primary.opacity(isHovering ? 0.3 : 0.15), lineWidth: isHovering ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .scaleEffect(isHovering ? 1.05 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isHovering)
        .onHover { isHovering = $0 }
        .onTapGesture { showPopover.toggle() }
        .popover(isPresented: $showPopover, arrowEdge: .top) {
          colorPopover
        }
      
      // Info
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 4) {
          Image(systemName: icon)
            .font(.caption2)
            .foregroundStyle(.secondary)
          Text(label)
            .font(.caption)
            .fontWeight(.medium)
        }
        
        Text(value.hex)
          .font(.system(.caption, design: .monospaced))
          .fontWeight(.medium)
          .foregroundStyle(.primary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private var colorPopover: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Détails de la couleur")
        .font(.headline)
        .fontWeight(.semibold)
      
      HStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color(hex: value.hex))
          .frame(width: 60, height: 60)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
          )
        
        VStack(alignment: .leading, spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Hex")
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
            
            Text(value.hex)
              .font(.system(.body, design: .monospaced))
              .fontWeight(.medium)
              .textSelection(.enabled)
          }
          
          VStack(alignment: .leading, spacing: 2) {
            Text("Primitive")
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
            
            Text(value.primitiveName)
              .font(.callout)
              .textSelection(.enabled)
          }
        }
        
        Spacer()
      }
    }
    .padding()
    .frame(width: 280)
  }
}

// MARK: - Previews

#if DEBUG
#Preview("Token Detail") {
  TokenDetailView(node: PreviewData.singleToken)
    .frame(width: 400, height: 300)
}

#Preview("Group Detail") {
  TokenDetailView(node: PreviewData.brandGroup)
    .frame(width: 400, height: 400)
}

#Preview("Disabled Token") {
  TokenDetailView(node: PreviewData.disabledToken)
    .frame(width: 400, height: 300)
}
#endif

