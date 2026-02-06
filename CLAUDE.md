# CLAUDE.md - ApertureTokensManager

## Description du projet

Application macOS pour importer, visualiser, filtrer et exporter des design tokens depuis Figma vers Xcode. Fonctionne avec le plugin Figma **ApertureExporter**.

## Stack technique

- **SwiftUI** - Interface utilisateur
- **TCA (The Composable Architecture)** - Architecture avec `@Reducer`, `@ObservableState`, `@Shared`
- **Swift Concurrency** - async/await, actors
- **macOS 14+** - Plateforme cible

## Architecture du projet

```
ApertureTokensManager/
├── App/                          # Point d'entrée
├── Components/                   # Composants UI réutilisables
├── Extensions/                   # Extensions Swift (Color+Hex, String+Date)
├── Features/                     # Features TCA
│   ├── Token/                    # Import et visualisation des tokens
│   │   ├── Actions/              # ViewActions, InternalActions, BindingActions
│   │   ├── Views/                # NodeRowView, NodeTreeView, TokenDetailView
│   │   └── TokenFeature.swift    # Reducer principal
│   └── Compare/                  # Comparaison de versions
│       ├── Actions/
│       ├── Views/
│       └── CompareFeature.swift
├── Helpers/                      # Utilitaires partagés (TokenHelpers)
├── Models/                       # Modèles de données
│   ├── Constants.swift           # Constantes centralisées (UIConstants, GroupNames...)
│   ├── TokenNode.swift           # Modèle principal des tokens
│   └── TokenFilters (SharedKeys) # Filtres persistants
└── Services/                     # Services métier (Client + Service pattern)
    ├── ExportService/            # Export XCAssets + Swift
    ├── ComparisonService/        # Comparaison de tokens
    ├── FileService/              # Gestion fichiers
    └── HistoryService/           # Historique imports
```

## Conventions de code

### Nommage
- **Features TCA** : `NomFeature.swift` + `NomFeature+View.swift`
- **Actions séparées** : `NomFeature+ViewActions.swift`, `NomFeature+InternalActions.swift`
- **Services** : `Nom+Client.swift` (interface) + `Nom+Service.swift` (implémentation)
- **Vues** : `NomView.swift` (pas de préfixe Feature)

### Pattern TCA
```swift
@Reducer
struct MyFeature {
  @Dependency(\.myClient) var myClient

  @ObservableState
  struct State: Equatable { ... }

  @CasePathable
  enum Action: BindableAction, ViewAction {
    case binding(BindingAction<State>)
    case `internal`(Internal)
    case view(View)

    enum Internal { ... }  // Actions internes (effets, callbacks)
    enum View { ... }      // Actions UI (boutons, gestures)
  }
}
```

### Services (Dependency pattern)
```swift
// Client (interface)
struct MyClient {
  var doSomething: @Sendable () async throws -> Result
}

extension MyClient: DependencyKey {
  static let liveValue: Self = { ... }()
  static let testValue: Self = { ... }()  // TOUJOURS fournir testValue
}

// Service (implémentation)
actor MyService {
  func doSomething() async throws -> Result { ... }
}
```

### Constantes
Toutes les valeurs magiques doivent être dans `Models/Constants.swift` :
- `UIConstants.Spacing` - espacements
- `UIConstants.Size` - dimensions
- `UIConstants.CornerRadius` - rayons
- `AnimationDuration` - durées d'animation
- `GroupNames` - noms de groupes pour filtres
- `DateFormatPatterns` - formats de date

### State partagé (@Shared)
Pour la persistance, utiliser `@Shared` avec des clés définies dans `Extensions/SharedKeys.swift` :
```swift
@Shared(.tokenFilters) var filters
```

## Commandes

### Build et test
```bash
# Build via Xcode
xcodebuild -scheme ApertureTokensManager build

# Tests
xcodebuild -scheme ApertureTokensManager test
```

## Skills de référence

Des documentations sont disponibles dans `.claude/skills/` :

| Skill | Quand l'utiliser |
|-------|-----------------|
| `pwf-composable-architecture` | Questions sur TCA, Reducers, Effects, Store |
| `pwf-sharing` | Questions sur `@Shared`, persistance, publishers |
| `pwf-dependencies` | Questions sur `@Dependency`, Clients, testValue |
| `pwf-swift-navigation` | Questions sur navigation, alerts, sheets |
| `pwf-modern-swiftui` | Questions sur `@Observable`, bindings |
| `swift-concurrency` | Questions sur async/await, actors, Task |

**Consulte ces skills quand tu travailles sur ces sujets.**

## Points d'attention

### À faire
- Toujours fournir `testValue` et `previewValue` pour les clients
- Utiliser `TokenHelpers` pour les opérations sur les arbres de tokens
- Centraliser les constantes dans `Constants.swift`
- Éviter les force unwraps (`!`) - préférer `guard let` ou `if let`

### À éviter
- Code dupliqué pour l'aplatissement des tokens (utiliser `TokenHelpers`)
- Valeurs hardcodées (dimensions, durées, noms de groupes)
- `print()` pour le debug (préférer un système de logging)
- Actions TCA trop larges (séparer View/Internal/Binding)

## Filtres d'export

L'app supporte 3 filtres persistants (`TokenFilters` dans SharedKeys) :
1. `excludeTokensStartingWithHash` - Exclut tokens commençant par `#`
2. `excludeTokensEndingWithHover` - Exclut tokens finissant par `_hover`
3. `excludeUtilityGroup` - Exclut le groupe "Utility" et ses enfants

Les filtres sont observés via publisher TCA et appliqués récursivement sur l'arbre.
