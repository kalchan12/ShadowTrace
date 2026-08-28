# Testing Strategy

---

## 1. Client Testing
* **Unit Tests (`client/test/models/`, `client/test/repositories/`):** Test model serialization, mock data streams, and Riverpod providers.
* **Widget Tests (`client/test/widgets/`, `client/test/features/`):** Verify tactical UI rendering, button interactions, and navigation flows.
* **Integration Tests (`client/integration_test/`):** Verify full app flow from splash to live map and group creation.

Run tests via:
```bash
cd client
flutter test
```

---

## 2. Service Testing
* **Unit Tests (`service/app/src/test/`):** Verify Keystore device ID calculation, location jitter filters, and AIDL request serialization.
* **Instrumentation Tests (`service/app/src/androidTest/`):** Test Foreground Service lifecycle on Android emulators.

Run tests via:
```bash
cd service
./gradlew test
```

---

## 3. Backend & Security Testing
* **RLS Validation:** Verify that unauthorized queries to `current_locations` are blocked by PostgreSQL policies.
