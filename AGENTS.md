# Repository Guidelines

## Project Structure & Module Organization
- `DBMultiverse/` hosts the main SwiftUI app (app/startup flows, features, SwiftData storage, shared utilities) plus platform-specific views. Keep feature code modular by folder (Features, SwiftData, Networking, Resources).
- `DBMultiverseComicKit/` (Swift package) owns reusable comic UI, caching, and page view models; `DBMultiverseParseKit/` (Swift package) parses chapter metadata; `DBMultiverseWidgets/` contains the WidgetKit extension.
- `DBMultiverseUnitTests/` holds XCTest cases and `TestPlan/UnitTestPlan.xctestplan`. `docs/` stores architecture and module notes; `media/` holds marketing screenshots.

## Build, Test, and Development Commands
- Open in Xcode via `DBMultiverse.xcodeproj`, select the `DBMultiverse` scheme, and target an iOS 17+ simulator or device for local runs.
- CLI build: `xcodebuild -scheme DBMultiverse -destination 'platform=iOS Simulator,name=iPhone 15' build` (adjust device as needed).
- Tests: `xcodebuild test -scheme DBMultiverse -destination 'platform=iOS Simulator,name=iPhone 15' -testPlan UnitTestPlan`. For package-only checks, run `swift test` inside `DBMultiverseComicKit` or `DBMultiverseParseKit`.

## Coding Style & Naming Conventions
- Swift 6, SwiftUI-first. Prefer `struct` views and immutable models; keep adapters/protocols for side effects (file I/O, networking).
- Indent with 4 spaces; place parameters on a single line when practical. Keep types/file scopes private unless shared.
- File headers should credit `Nikolai Nobadi`; keep module imports minimal.
- Naming: `FeatureNameView`, `FeatureNameViewModel`, `...Manager/Adapter` for side-effectful coordinators, and `...Protocol` for abstractions. Extensions live in the feature’s `Utilities` or `Shared` folders.

## Testing Guidelines
- Framework: XCTest with async tests where appropriate. Name files `<TypeName>Tests.swift`; prefer GIVEN/WHEN/THEN comments in complex cases.
- Use the `UnitTestPlan.xctestplan` for repeatable runs. Mock adapters (file system, network, cache) to avoid hitting the network; keep tests deterministic and simulator-friendly.

## Commit & Pull Request Guidelines
- Commit style mirrors the history: present-tense, concise, optional scopes (e.g., `refactor(cache): tighten cache eviction`). Favor small, single-purpose commits.
- Pull requests should summarize intent, list touched modules/targets, and note user-facing changes. Add screenshots or screen recordings for UI updates and mention test coverage or plans.

## Security & Configuration Notes
- Do not commit secrets or API tokens; configuration lives in code defaults or secure local files. Use `URLFactory` for constructing endpoints instead of hardcoding strings.
- Respect cache and file-system boundaries: keep file operations behind adapters and avoid writing outside app sandbox paths.

## Project Guidelines
Project-specific guidelines are located in `.guidelines/codex/`

## iOS Architecture
- SwiftUI-based views
- No business logic inside SwiftUI views
- Modular feature-based architecture

## iOS Testing
- Prefer behavior-driven unit tests (Swift Testing, `@Test("…")`)
- Use `makeSUT` + `trackForMemoryLeaks` in tests
- No inline comments in test files; use `// MARK:` only for sectioning
- Default to type-safe assertions (`#expect`, `#require`)
- Use `waitUntil` for `@Published`/reactive assertions instead of sleeps
