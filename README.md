# Smart Catalog — Laboratory Work 8

Flutter/Dart app for Narxoz University, Cross-Platform Mobile Application Development, Week 8. A shared in-memory catalog supports list/grid views, simulated refresh, swipe deletion, undo, and empty-state recovery. Data resets when the app restarts; refresh adds generated products locally.

## Setup and launch

Use Flutter 3.47.2 / Dart 3.13.2 (the SDK used during implementation), or a compatible Flutter SDK with Dart `^3.13.2`. For iOS, use macOS with Xcode, its command-line tools, and an installed iOS Simulator runtime. Run commands from the repository root.

```sh
flutter doctor
flutter pub get
flutter analyze
flutter test
```

Launch in iOS Simulator:

```sh
open -a Simulator
xcrun simctl list devices available
```

If no simulator is booted, boot an available device using its UUID from the preceding list:

```sh
xcrun simctl boot <simulator-uuid>
xcrun simctl bootstatus <simulator-uuid> -b
flutter devices
flutter run -d <simulator-uuid>
```

Replace the placeholders with the chosen device UUID; skip `boot` if that device is already booted. Keep `flutter run` attached to use hot reload (`r`) or quit (`q`). To target another supported device, select its ID from `flutter devices`.

## Automated checks

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test/catalog_simulator_test.dart -d <simulator-uuid>
```

The 17 widget tests cover small-phone layouts, toggling with pending refresh and catalog mutations, the exact 1500 ms delay, refresh gestures in both views, partial and directional swipes, undo positioning, and empty/reset recovery. The integration test runs scrolling, refresh in both layouts, dismissal, undo, and empty/reset gestures on the selected Simulator, with checks for Flutter layout exceptions.

After integration testing, relaunch the regular app and leave it running:

```sh
flutter run -d <simulator-uuid> --no-resident
```

## Architecture

| Location | Responsibility |
| --- | --- |
| `lib/main.dart` | App entry point, Material theme, and catalog screen. |
| `lib/models/product.dart` | Immutable product fields, including stable ID, title, category, rating, price, and avatar icon. |
| `lib/data/seed_catalog.dart` | Six initial products with distinct seed IDs. |
| `lib/screens/catalog_screen.dart` | Shared product list, view toggle, refresh, dismissal, undo, and reset state using `setState`. |
| `lib/widgets/product_row.dart` | List row with avatar, title, category chip, star rating, and price. |
| `lib/widgets/product_card.dart` | Grid card with bounded text and a flexible avatar area. |
| `lib/widgets/empty_catalog.dart` | Scrollable empty placeholder and Reset Catalog callback. |
| `test/` | Widget tests for catalog rendering and interactions. |

## Rubric coverage

| Criterion | Points | Implementation |
| --- | --- | --- |
| Lazy list and grid | 3 | `ListView.separated` with thin dividers; `GridView.builder` with two columns and `childAspectRatio: 0.72`; AppBar toggle. |
| Pull-to-refresh | 2 | `RefreshIndicator` awaits a 1500 ms `Future.delayed`, then inserts a uniquely identified New Arrival at index 0 inside `setState`. Both views and the empty placeholder remain pullable. |
| Swipe and undo | 3 | List rows use `Dismissible`, `ValueKey(product.id)`, and `endToStart` swipes with a red delete background. A floating SnackBar restores the removed item at its saved index. |
| Architecture and defense | 2 | Separate models, data, screens, and widgets; explanation and demonstration below. The live instructor question remains part of the assessment. |

The empty state displays an inventory icon, **Catalog is Empty**, and **Reset Catalog**, which restores the six seed products in either view.

## Reproducible demonstration

1. Start the app fresh. In list mode, show the avatar, title, category, rating, price, and thin dividers. Scroll to **Dart Handbook**.
2. Tap **Show grid** in the AppBar. Show the same catalog in two columns and scroll through the cards. Check that titles and prices fit without overflow; **Show list** returns to the feed.
3. At the top of the list, pull down and release until the refresh indicator appears. After about 1.5 seconds, **New Arrival 1** appears first. Switch to grid and repeat to see **New Arrival 2** at the top. The catalog is shared across modes.
4. Return to list mode. Swipe a row from right to left to expose the red delete icon and remove it. Immediately tap **UNDO** in the floating SnackBar; verify the row returns to the position it occupied before deletion. Only the latest deletion has an available undo action.
5. Swipe away every item in list mode without undoing. Show the empty icon, message, and button. Toggle to grid to show that the empty state applies there too. Tap **Reset Catalog**; the six original products return in the selected view.
6. Optional edge checks: pull to refresh while empty to add a product, or reset while an empty-state refresh is pending. Reset invalidates pending refresh results and old undo actions, so they cannot change the restored seed catalog.

## Brief defense walkthrough

- **Why lazy builders?** `ListView.separated` and `GridView.builder` build children on demand around the viewport. A `Column` containing every product creates all those children eagerly, increasing startup work and memory use for large collections, even inside a scroll view. The small `Column` inside each card only lays out that card's fields.
- **Why stable dismissal keys?** `ValueKey(product.id)` ties a row's identity to its product. Index keys would shift after insertion or removal and could associate dismissal state with the wrong row. Seed IDs and monotonically increasing refresh IDs remain distinct, including after reset.
- **How does refresh stay responsive?** Awaiting `Future.delayed(const Duration(milliseconds: 1500))` yields while the indicator animates. Afterward, `setState` prepends the generated item. A mounted check prevents updates after disposal; a catalog-version check ignores work begun before reset.
- **How does undo preserve position?** Before removal, the screen saves the product and its current index. UNDO inserts at that saved numeric index, clamped to the current list length so intervening changes cannot cause an out-of-range insertion. If other items have changed, this is the saved index rather than a position relative to neighboring products. Guards prevent duplicate restoration and stale undo after reset.
- **How does the grid fit?** Two columns and a width-to-height ratio of `0.72` give cards room for their content. Limited text lines with ellipsis and a flexible avatar area help keep the layout within each card; widget tests also exercise a 320 × 568 logical-pixel viewport.

## Task branches and commits

The implementation is split across exactly two task branches: `feature/catalog-views` (commits 1–4: product foundations, screen shell, list, grid/toggle) and `feature/catalog-interactions` (commits 5–10: refresh, deletion, undo, empty recovery, documentation, and validation). Commit 10 adds widget regression checks and the iOS Simulator integration walkthrough. The second branch contains all ten task commits; `main` preserves the starter baseline.
