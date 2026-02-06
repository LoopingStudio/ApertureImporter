# Todo

## Completed

### [2026-02-06] Feature: Suggestions intelligentes avec fuzzy matching

- [x] Créer `FuzzyMatchingHelpers.swift` avec algorithmes de similarité
- [x] Ajouter `AutoSuggestion` model dans `TokenComparison.swift`
- [x] Créer `SuggestionService` (actor) et `SuggestionClient`
- [x] Intégrer dans `CompareFeature` avec `@Dependency`
- [x] Ajouter actions `suggestionsComputed`, `acceptAutoSuggestion`, `rejectAutoSuggestion`
- [x] Mettre à jour `RemovedTokensView` avec UI de confiance
- [x] Refactorer hiérarchie: Couleur (50%) > Contexte d'usage (30%) > Structure (20%)
- [x] Ajouter marqueurs sémantiques: `bg`, `fg`, `hover`, `solid`, `surface`, etc.
- [x] Build et vérification preview

**Résultat**: Feature fonctionnelle avec suggestions automatiques affichées dans l'onglet "Supprimés" de la comparaison. Score de confiance visible avec code couleur (vert >70%, orange 50-70%, gris <50%).

---

## En cours

_Aucune tâche en cours_

---

## Backlog

_À définir avec l'utilisateur_

---
