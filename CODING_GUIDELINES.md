# Flutter Code Refactoring & Style Guidelines

You must strictly adhere to the following rules for all code generation, modifications, and new page creations:

1. State Management (BLoC / Cubit Only):
   - Convert all StatefulWidgets to StatelessWidget.
   - Do NOT use `setState` anywhere.
   - All state changes, user interactions, and UI updates MUST be handled using BLoC or Cubit (BlocBuilder, BlocListener, or BlocConsumer).

2. Clean Widget Extraction & Reusability:
   - Divide large screen files into smaller, maintainable widgets.
   - Extract widgets using standalone classes (`Extract as Widget`), NEVER use helper methods returning a Widget (e.g., `Widget _buildItem()`).
   - Place feature-specific widgets inside a local `widgets/` folder within that feature's directory.
   - Place app-wide shared widgets inside `core/widgets/` or `core/shared_widgets/`.
   - Ensure components are modular and reusable across screens.

3. Localization (No Hardcoded Strings):
   - Do NOT use hardcoded strings anywhere in the UI.
   - Always use the project's localization system (e.g., `S.of(context).key` or `AppLocalizations.of(context)!.key`).

4. Declarative Navigation (GoRouter):
   - Do NOT use legacy navigation (`Navigator.push`, `Navigator.pushNamed`).
   - Use `GoRouter` syntax exclusively (e.g., `context.go()`, `context.push()`, `context.pop()`).

5. Responsive Design:
   - Ensure all UIs are responsive and look polished on both Mobile and Tablet screens.
   - Use dynamic layout builders, media query constraints, or project responsive utilities.

6. Centralized Theming:
   - Do NOT use hardcoded colors (`Color(0xFF...)` or `Colors.red`) or raw `TextStyle`.
   - Access colors via theme/constants (e.g., `Theme.of(context).colorScheme` or `AppColors`).
   - Use `Theme.of(context).textTheme` for text styles.

7. Design Preservation:
   - Preserve 100% of the existing UI design, paddings, borders, shadows, and overall visually rendered layout without breakage.