# Contributing to ShadowTrace

Thank you for contributing to ShadowTrace. Please adhere to the following architecture rules, coding standards, and security conventions.

---

## 1. Core Architectural Separation

ShadowTrace is strictly architected as **two separate applications**:
1. **`client/` (Flutter):** Responsible for user interaction, the tactical live map, group pairing, and local nickname storage.
2. **`service/` (Native Kotlin Android):** Responsible for Android foreground location telemetry, Keystore cryptographic keys, and backend packet transmission.

> **RULE:** Never convert the Service into a Flutter application or merge the Service into the Client. The separation is intentional for OS lifecycle stability and security boundaries.

---

## 2. Security & Privacy Rules

* **No User Accounts:** Never introduce email, password, phone number, or social SSO flows.
* **No Server-Side Nicknames:** Nicknames and contact names must remain exclusively in the client's local storage.
* **No Historical Coordinate Trails:** The default backend data model only accepts upserts to `current_locations`. Do not add tracking tables or breadcrumbs without explicit architectural approval.
* **Never Commit Credentials:** Never commit `.env`, keystore files, API keys, or private keys.

---

## 3. Coding Conventions

### Flutter (Client)
* Use Riverpod for state management.
* Maintain the custom "Tactical Dark" Material 3 theme.
* Keep repository interfaces decoupled from implementations (`lib/data/repositories/`).
* Format all Dart code with `dart format .` before pushing.
* Ensure zero warnings in `flutter analyze`.

### Kotlin (Service)
* Follow official Android Kotlin style guides.
* Use Kotlin Coroutines and StateFlow/SharedFlow for asynchronous telemetry pipelines.
* Ensure all foreground service operations strictly adhere to Android 14+ foreground service location policies.
* Run `./gradlew lint` and `./gradlew test` before committing.

---

## 4. Commit Message Guidelines

Follow conventional commits format:
* `feat(client): add QR invite scanner`
* `fix(service): resolve battery drain in stationary geofence`
* `docs(arch): update IPC contract specification`
* `refactor(backend): optimize RLS policy for group memberships`

---

## 5. Pull Request Expectations

1. Ensure all existing tests pass (`flutter test`, `./gradlew test`).
2. Add unit or widget tests for new features or bug fixes.
3. Update `docs/development/status.md` if your PR advances a roadmap phase or resolves technical debt.
