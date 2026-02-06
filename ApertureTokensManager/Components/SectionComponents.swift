import SwiftUI

// MARK: - Section Card

/// Container card pour regrouper du contenu dans une section
struct SectionCard<Content: View>: View {
  let title: String
  var subtitle: String? = nil
  var trailingContent: AnyView? = nil
  @ViewBuilder let content: () -> Content
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.headline)
          
          if let subtitle {
            Text(subtitle)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        
        Spacer()
        
        if let trailingContent {
          trailingContent
        }
      }
      
      content()
    }
    .padding()
    .background(Color(.controlBackgroundColor).opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

extension SectionCard {
  init(
    title: String,
    subtitle: String? = nil,
    @ViewBuilder trailing: () -> some View,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.subtitle = subtitle
    self.trailingContent = AnyView(trailing())
    self.content = content
  }
}

// MARK: - Warning Card

/// Card d'avertissement avec icône, titre et message
struct WarningCard: View {
  let icon: String
  let title: String
  let message: String
  let color: Color
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(color)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
        Text(message)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
    }
    .padding()
    .background(color.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

// MARK: - Filter Badge

/// Badge indiquant l'état d'un filtre
struct FilterBadge: View {
  let label: String
  let isActive: Bool
  let color: Color
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
        .font(.caption2)
      Text(label)
        .font(.caption)
    }
    .foregroundStyle(isActive ? color : .secondary)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(isActive ? color.opacity(0.15) : Color(.controlBackgroundColor))
    .clipShape(Capsule())
  }
}

// MARK: - Directory Row

/// Ligne affichant un dossier avec option de suppression
struct DirectoryRow: View {
  let name: String
  let path: String
  let onRemove: () -> Void
  
  @State private var isHovering = false
  
  var body: some View {
    HStack {
      Image(systemName: "folder.fill")
        .foregroundStyle(.blue)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(name)
          .font(.subheadline)
          .fontWeight(.medium)
        
        Text(path)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)
          .truncationMode(.middle)
      }
      
      Spacer()
      
      Button {
        onRemove()
      } label: {
        Image(systemName: "xmark.circle.fill")
          .foregroundStyle(.secondary)
      }
      .buttonStyle(.plain)
      .opacity(isHovering ? 1 : 0.5)
    }
    .padding(8)
    .background(Color(.controlBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 6))
    .onHover { isHovering = $0 }
  }
}

// MARK: - Empty State Card

/// Card d'état vide avec icône et message
struct EmptyStateCard: View {
  let icon: String
  let title: String
  let message: String
  
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.largeTitle)
        .foregroundStyle(.secondary)
      
      Text(title)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      Text(message)
        .font(.caption)
        .foregroundStyle(.tertiary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(Color(.controlBackgroundColor).opacity(0.3))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

// MARK: - Previews

#if DEBUG
#Preview("SectionCard") {
  VStack(spacing: 16) {
    SectionCard(title: "Options de scan", subtitle: "Configurez le comportement") {
      Toggle("Ignorer les tests", isOn: .constant(true))
      Toggle("Ignorer les previews", isOn: .constant(false))
    }
    
    SectionCard(
      title: "Dossiers",
      trailing: {
        Button("Ajouter") {}
          .controlSize(.small)
      }
    ) {
      Text("Contenu ici")
    }
  }
  .padding()
  .frame(width: 400)
}

#Preview("WarningCard") {
  WarningCard(
    icon: "exclamationmark.triangle.fill",
    title: "Attention requise",
    message: "Chargez d'abord un design system pour continuer.",
    color: .orange
  )
  .padding()
  .frame(width: 400)
}

#Preview("FilterBadge") {
  HStack {
    FilterBadge(label: "Actif", isActive: true, color: .green)
    FilterBadge(label: "Inactif", isActive: false, color: .orange)
    FilterBadge(label: "Erreur", isActive: true, color: .red)
  }
  .padding()
}

#Preview("DirectoryRow") {
  VStack {
    DirectoryRow(
      name: "ApertureFoundations",
      path: "/Users/dev/Projects/Aperture/ApertureFoundations",
      onRemove: {}
    )
    DirectoryRow(
      name: "MonApp",
      path: "/Users/dev/Projects/MonApp/Sources",
      onRemove: {}
    )
  }
  .padding()
  .frame(width: 400)
}

#Preview("EmptyStateCard") {
  EmptyStateCard(
    icon: "folder",
    title: "Aucun dossier sélectionné",
    message: "Ajoutez les dossiers de vos projets Swift"
  )
  .padding()
  .frame(width: 400)
}
#endif
