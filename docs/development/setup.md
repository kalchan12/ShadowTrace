# Development Setup Guide

---

## 1. Prerequisites

Ensure you have installed:
* **Flutter SDK:** Version >= 3.19.0 (Dart SDK >= 3.3.0)
* **Java JDK:** JDK 17 (OpenJava / Temurin)
* **Android SDK:** Platform API 34, Build Tools 34.0.0
* **Gradle:** 8.x (Included via Gradle Wrapper in `service/`)

---

## 2. Setting Up the Client (Flutter)

```bash
cd client
flutter pub get
flutter test
flutter run
```

---

## 3. Setting Up the Service (Android / Kotlin)

```bash
cd service
./gradlew test
./gradlew assembleDebug
```

---

## 4. Running Validation Script

From the repository root:
```bash
./scripts/validate.sh
```
This script formats Dart code, runs static analysis, executes unit tests, and verifies the Kotlin build.
