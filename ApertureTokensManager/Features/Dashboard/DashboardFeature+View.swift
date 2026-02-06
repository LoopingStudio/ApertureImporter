import SwiftUI
import ComposableArchitecture

@ViewAction(for: DashboardFeature.self)
struct DashboardView: View {
  @Bindable var store: StoreOf<DashboardFeature>
  
  var body: some View {
    VStack(spacing: 0) {
      header
      Divider()
      
      if let base = store.designSystemBase {
        DesignSystemBaseView(base: base, store: store)
      } else {
        EmptyBaseView { send(.goToImportTapped) }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .sheet(item: $store.scope(state: \.tokenBrowser, action: \.tokenBrowser)) { browserStore in
      TokenBrowserView(store: browserStore)
    }
  }
}

// MARK: - Header

private extension DashboardView {
  var header: some View {
    HStack {
      Text("Dashboard")
        .font(.title)
        .fontWeight(.bold)
      
      Spacer()
      
      if store.designSystemBase != nil {
        Menu {
          Button(action: { send(.openFileButtonTapped) }) {
            Label("Afficher dans le Finder", systemImage: "folder")
          }
          Divider()
          Button(role: .destructive, action: { send(.clearBaseButtonTapped) }) {
            Label("Supprimer la base", systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
            .font(.title2)
            .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
      }
    }
    .padding()
  }
}

// MARK: - Empty State View

private struct EmptyBaseView: View {
  @State private var showContent = false
  @State private var iconPulse = false
  let onImportTapped: () -> Void

  var body: some View {
    VStack(spacing: UIConstants.Spacing.large) {
      ZStack {
        Circle()
          .fill(Color.purple.opacity(0.1))
          .frame(width: 120, height: 120)
          .scaleEffect(iconPulse ? 1.1 : 1.0)
        
        Image(systemName: "square.stack.3d.up.slash")
          .font(.system(size: 48))
          .foregroundStyle(.purple.opacity(0.6))
      }
      .opacity(showContent ? 1 : 0)
      .scaleEffect(showContent ? 1 : 0.8)
      
      VStack(spacing: UIConstants.Spacing.small) {
        Text("Aucun Design System défini")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Importez un fichier de tokens et définissez-le comme base\npour accéder au dashboard.")
          .font(.body)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
      .opacity(showContent ? 1 : 0)
      .offset(y: showContent ? 0 : 10)

      Button {
        onImportTapped()
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "arrow.right.circle.fill")
            .foregroundStyle(.purple)
          Text("Utilisez l'onglet Importer pour charger un Design System")
        }
        .font(.callout)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
          Capsule()
            .fill(Color.purple.opacity(0.1))
        )
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 15)
      }
      .buttonStyle(.plain)
    }
    .padding(UIConstants.Spacing.extraLarge)
    .frame(maxHeight: .infinity)
    .onAppear {
      withAnimation(.easeOut(duration: 0.5)) {
        showContent = true
      }
      withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
        iconPulse = true
      }
    }
  }
}

// MARK: - Design System Base View

private struct DesignSystemBaseView: View {
  let base: DesignSystemBase
  let store: StoreOf<DashboardFeature>
  
  @State private var showHeader = false
  @State private var showStats = false
  @State private var showActions = false
  
  var body: some View {
    ScrollView {
      VStack(spacing: UIConstants.Spacing.large) {
        headerCard
          .opacity(showHeader ? 1 : 0)
          .offset(y: showHeader ? 0 : -15)
        
        statsSection
          .opacity(showStats ? 1 : 0)
          .offset(y: showStats ? 0 : 15)
        
        actionsSection
          .opacity(showActions ? 1 : 0)
          .offset(y: showActions ? 0 : 20)
        
        Spacer(minLength: 20)
      }
      .padding(UIConstants.Spacing.large)
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.35)) {
        showHeader = true
      }
      withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
        showStats = true
      }
      withAnimation(.easeOut(duration: 0.45).delay(0.2)) {
        showActions = true
      }
    }
  }
  
  // MARK: - Header Card
  
  private var headerCard: some View {
    HStack(spacing: UIConstants.Spacing.medium) {
      // Icon
      ZStack {
        Circle()
          .fill(Color.green.opacity(0.15))
          .frame(width: 56, height: 56)
        
        Image(systemName: "checkmark.seal.fill")
          .font(.title)
          .foregroundStyle(.green)
      }
      
      // Info
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 8) {
          Text("Design System Actif")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
              Capsule()
                .fill(Color.green.opacity(0.15))
            )
        }
        
        Text(base.fileName)
          .font(.title3)
          .fontWeight(.semibold)
          .lineLimit(1)
        
        if !base.metadata.version.isEmpty {
          Text("Version \(base.metadata.version)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      
      Spacer()
    }
    .padding(UIConstants.Spacing.medium)
    .background(
      RoundedRectangle(cornerRadius: UIConstants.CornerRadius.large)
        .fill(Color.green.opacity(0.08))
        .overlay(
          RoundedRectangle(cornerRadius: UIConstants.CornerRadius.large)
            .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    )
  }
  
  // MARK: - Stats Section
  
  private var statsSection: some View {
    HStack(spacing: UIConstants.Spacing.medium) {
      StatCard(
        title: "Tokens",
        value: "\(base.tokenCount)",
        subtitle: "dans le design system",
        color: .blue,
        icon: "paintpalette.fill",
        action: { store.send(.view(.tokenCountTapped)) }
      )
      .staggeredAppear(index: 0)
      
      StatCard(
        title: "Défini le",
        value: base.setAt.formatted(date: .abbreviated, time: .omitted),
        subtitle: "comme base de référence",
        color: .orange,
        icon: "calendar"
      )
      .staggeredAppear(index: 1)
      
      StatCard(
        title: "Exporté",
        value: base.metadata.exportedAt.toShortDate(),
        subtitle: "par \(base.metadata.generator)",
        color: .purple,
        icon: "arrow.up.doc.fill"
      )
      .staggeredAppear(index: 2)
    }
  }
  
  // MARK: - Actions Section
  
  private var actionsSection: some View {
    VStack(alignment: .leading, spacing: UIConstants.Spacing.medium) {
      Text("Actions rapides")
        .font(.headline)
        .foregroundStyle(.secondary)
      
      HStack(spacing: UIConstants.Spacing.medium) {
        ExportActionCard(store: store)
        
        DashboardActionCard(
          title: "Comparer avec import",
          subtitle: "Détecter les changements",
          icon: "doc.text.magnifyingglass",
          color: .green,
          index: 1
        ) {
          store.send(.view(.compareWithBaseButtonTapped))
        }
      }
    }
  }
}

// MARK: - Export Action Card with Popover

private struct ExportActionCard: View {
  @Bindable var store: StoreOf<DashboardFeature>
  
  @State private var isHovering = false
  @State private var isPressed = false
  @State private var iconBounce = false
  
  private let color: Color = .blue
  
  var body: some View {
    Button(action: { handleButtonTapped() }) {
      cardContent
    }
    .buttonStyle(.plain)
    .scaleEffect(isPressed ? 0.97 : (isHovering ? 1.01 : 1.0))
    .shadow(color: isHovering ? color.opacity(0.12) : .clear, radius: 6)
    .animation(.easeOut(duration: 0.2), value: isHovering)
    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
    .pointerOnHover { hovering in handleHover(hovering) }
    .staggeredAppear(index: 0, duration: 0.4)
    .popover(isPresented: $store.isExportPopoverPresented) {
      ExportPopoverContent(store: store)
    }
  }
  
  private var cardContent: some View {
    HStack(spacing: UIConstants.Spacing.medium) {
      ZStack {
        Circle()
          .fill(color.opacity(0.15))
          .frame(width: 44, height: 44)
        
        Image(systemName: "square.and.arrow.up.fill")
          .font(.title3)
          .foregroundStyle(color)
          .scaleEffect(iconBounce ? 1.15 : 1.0)
      }
      
      VStack(alignment: .leading, spacing: 2) {
        Text("Exporter vers Xcode")
          .font(.headline)
          .foregroundStyle(.primary)
        Text("Générer XCAssets + Swift")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(.tertiary)
        .offset(x: isHovering ? 3 : 0)
        .animation(.easeOut(duration: 0.2), value: isHovering)
    }
    .padding(UIConstants.Spacing.medium)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: UIConstants.CornerRadius.medium)
        .fill(color.opacity(isHovering ? 0.12 : 0.06))
        .overlay(
          RoundedRectangle(cornerRadius: UIConstants.CornerRadius.medium)
            .stroke(color.opacity(isHovering ? 0.3 : 0.15), lineWidth: 1)
        )
    )
  }
  
  private func handleButtonTapped() {
    withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
      isPressed = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
        isPressed = false
      }
      store.send(.view(.exportButtonTapped))
    }
  }
  
  private func handleHover(_ hovering: Bool) {
    isHovering = hovering
    guard hovering else { return }
    bounceIcon()
  }
  
  private func bounceIcon() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
      iconBounce = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        iconBounce = false
      }
    }
  }
}

// MARK: - Export Popover Content

private struct ExportPopoverContent: View {
  @Bindable var store: StoreOf<DashboardFeature>
  
  var body: some View {
    VStack(alignment: .leading, spacing: UIConstants.Spacing.medium) {
      // Header
      HStack {
        Image(systemName: "gearshape.fill")
          .foregroundStyle(.blue)
        Text("Filtres d'export")
          .font(.headline)
      }
      
      Divider()
      
      // Filters
      VStack(alignment: .leading, spacing: UIConstants.Spacing.small) {
        Toggle(isOn: $store.filters.excludeTokensStartingWithHash) {
          HStack {
            Image(systemName: "number")
              .foregroundStyle(.orange)
              .frame(width: 20)
            Text("Exclure tokens commençant par #")
          }
        }
        .toggleStyle(.checkbox)
        
        Toggle(isOn: $store.filters.excludeTokensEndingWithHover) {
          HStack {
            Image(systemName: "cursorarrow.click")
              .foregroundStyle(.purple)
              .frame(width: 20)
            Text("Exclure tokens finissant par _hover")
          }
        }
        .toggleStyle(.checkbox)
        
        Toggle(isOn: $store.filters.excludeUtilityGroup) {
          HStack {
            Image(systemName: "wrench.fill")
              .foregroundStyle(.gray)
              .frame(width: 20)
            Text("Exclure groupe Utility")
          }
        }
        .toggleStyle(.checkbox)
      }
      .font(.callout)
      
      Divider()
      
      // Actions
      HStack {
        Button("Annuler") {
          store.send(.view(.dismissExportPopover))
        }
        .buttonStyle(.bordered)
        
        Spacer()
        
        Button {
          store.send(.view(.confirmExportButtonTapped))
        } label: {
          Label("Exporter", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding()
    .frame(width: 320)
  }
}

// MARK: - Action Card

private struct DashboardActionCard: View {
  let title: String
  let subtitle: String
  let icon: String
  let color: Color
  let index: Int
  let action: () -> Void
  
  @State private var isHovering = false
  @State private var isPressed = false
  @State private var iconBounce = false
  
  var body: some View {
    Button(action: { handleButtonTapped() }) {
      cardContent
    }
    .buttonStyle(.plain)
    .scaleEffect(isPressed ? 0.97 : (isHovering ? 1.01 : 1.0))
    .shadow(color: isHovering ? color.opacity(0.12) : .clear, radius: 6)
    .animation(.easeOut(duration: 0.2), value: isHovering)
    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
    .pointerOnHover { hovering in handleHover(hovering) }
    .staggeredAppear(index: index, baseDelay: 0.1, duration: 0.4)
  }
  
  private var cardContent: some View {
    HStack(spacing: UIConstants.Spacing.medium) {
      ZStack {
        Circle()
          .fill(color.opacity(0.15))
          .frame(width: 44, height: 44)
        
        Image(systemName: icon)
          .font(.title3)
          .foregroundStyle(color)
          .scaleEffect(iconBounce ? 1.15 : 1.0)
      }
      
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.primary)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(.tertiary)
        .offset(x: isHovering ? 3 : 0)
        .animation(.easeOut(duration: 0.2), value: isHovering)
    }
    .padding(UIConstants.Spacing.medium)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: UIConstants.CornerRadius.medium)
        .fill(color.opacity(isHovering ? 0.12 : 0.06))
        .overlay(
          RoundedRectangle(cornerRadius: UIConstants.CornerRadius.medium)
            .stroke(color.opacity(isHovering ? 0.3 : 0.15), lineWidth: 1)
        )
    )
  }
  
  private func handleButtonTapped() {
    withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
      isPressed = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
        isPressed = false
      }
      action()
    }
  }
  
  private func handleHover(_ hovering: Bool) {
    isHovering = hovering
    guard hovering else { return }
    bounceIcon()
  }
  
  private func bounceIcon() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
      iconBounce = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        iconBounce = false
      }
    }
  }
}

// MARK: - Previews

#Preview("With Base") {
  DashboardView(
    store: Store(initialState: DashboardFeature.State(
      designSystemBase: Shared(wrappedValue: DesignSystemBase(
        fileName: "aperture-tokens-v2.1.0.json",
        bookmarkData: nil,
        metadata: TokenMetadata(
          exportedAt: "2026-01-28 14:30:45",
          timestamp: 1737982245000,
          version: "2.1.0",
          generator: "ApertureExporter Plugin"
        ),
        tokens: PreviewData.rootNodes
      ), .designSystemBase)
    )) {
      DashboardFeature()
    }
  )
  .frame(width: 900, height: 600)
}

#Preview("Empty") {
  DashboardView(
    store: Store(initialState: .initial) {
      DashboardFeature()
    }
  )
  .frame(width: 700, height: 500)
}
