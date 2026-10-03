# Repository Guidelines

## Project Structure & Module Organization

GothicLounge is a SwiftUI iOS app with one application target. The target uses Swift 5 and supports iOS 17.6 or later on iPhone and iPad.

- `GothicLounge/GothicLoungeApp.swift` defines the app entry point and window content.
- `GothicLounge/View/` contains screens: `AppView` manages tab navigation, `MenuView` provides the home screen, and `ContentView` contains a welcome form.
- `GothicLounge/Entity/TabBarItem.swift` implements the reusable tab button; this directory currently contains UI code.
- `GothicLounge/Assets.xcassets/` stores app icons, accent colors, and other asset catalogs.
- `GothicLounge.xcodeproj/` contains project and build settings. No test directory or test target exists yet.

## Build, Test, and Development Commands

Use macOS with Xcode and an installed iOS Simulator runtime.

- `open GothicLounge.xcodeproj` opens the project in Xcode. Select the `GothicLounge` scheme and a simulator, then press Command-R to run.
- `xcodebuild -list -project GothicLounge.xcodeproj` lists available targets, configurations, and schemes.
- `xcodebuild -project GothicLounge.xcodeproj -scheme GothicLounge -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build` builds for the simulator.

Use existing `#Preview` declarations for quick visual checks. There are no custom build scripts or package-manager commands.

## Coding Style & Naming Conventions

Follow existing Swift style: four-space indentation, same-line opening braces, and one primary view type per matching filename. Use UpperCamelCase for types and lowerCamelCase for properties and functions. Place chained SwiftUI modifiers on separate lines. Use `@State` for locally owned mutable state and `@Binding` for state shared with a parent. Keep tab selection values consistent with their tags. No SwiftLint or SwiftFormat configuration is present.

## Testing Guidelines

No automated testing framework or coverage threshold is configured. Build and manually check the welcome form, all four tabs, selected-tab appearance, and iPhone/iPad layouts. If adding automated tests, create an Xcode test target and use descriptive names such as `testSelectingMenuUpdatesSelection`.

## Commit & Pull Request Guidelines

History contains short subjects such as `first commit`; no formal convention is established. Write concise, imperative subjects describing the change. PRs should explain behavior changes, list validation performed, link relevant issues, and include screenshots for UI changes. Keep commits focused and exclude `.DS_Store`, personal `xcuserdata`, signing secrets, and build artifacts.
