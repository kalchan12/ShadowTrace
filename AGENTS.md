# Instructions for AI Coding Agents

Welcome to the **ShadowTrace** codebase. You are expected to operate with senior technical discipline, architectural fidelity, and strict adherence to the project rules.

---

## 1. Mandatory Reading Before Doing Any Work

Before generating code or editing existing structures, you MUST read and understand:
1. `README.md` — Core vision, architecture overview, and project summary.
2. `architecture.md` — Detailed system boundaries, IPC contracts, and data ownership.
3. `project.md` — Functional (FR), Non-Functional (NFR), and Security/Privacy (SEC/PRIV) specifications.
4. `plan.md` — Phased roadmap from Phase 0 to Phase 10.
5. `security.md` — Cryptographic identity model, RLS matrix, and threat boundaries.
6. `protocol.md` — Data contracts and JSON schemas.
7. Relevant files under `docs/` (e.g. `docs/development/status.md`).

---

## 2. Core Behavioral Rules

1. **Inspect Existing Code First:** Always inspect the existing files, directory tree, and implementation state before making changes. Never assume what exists.
2. **Preserve Working Code:** Do not blindly overwrite, delete, or re-scaffold working code. Adapt existing components gracefully.
3. **Do Not Change Architecture for Personal Preference:** Do not rewrite the repository or replace established frameworks (e.g., Riverpod, MapLibre, Kotlin Foreground Service) simply because a different pattern is preferred. Work with the established architecture.
4. **Never Merge Client and Service:** The Client (Flutter) and Service (Native Kotlin) MUST remain two separate APKs communicating over Android IPC.
5. **No Traditional Account Systems:** Never add email, password, phone number, Google SSO, or central user account tables. Identity is hardware/keystore-backed.
6. **No Fake "Production-Ready" Implementations:** Do not write mock or placeholder code that pretends to be a production implementation. Mark planned functionality clearly and keep interfaces clean.
7. **No History Tracking in Backend:** Do not add historical location logs or breadcrumb database tables.
8. **Check Dependencies & APIs:** Do not invent non-existent APIs, packages, or compiler flags. Verify package versions in `pubspec.yaml` and `build.gradle.kts`.
9. **Never Commit Secrets:** Do not commit `.env` files, keystores, private keys, or API tokens.
10. **Synchronize Documentation & Status:** When completing work, update `docs/development/status.md` and any relevant documentation.
11. **Run Validation:** Run formatting (`dart format .`), analysis (`flutter analyze`), and tests (`flutter test`, `./gradlew test`) to verify changes before concluding.
12. **Do Not Claim Unfinished Work is Complete:** Be transparent about current status, mock implementations, and upcoming phases.
