# Privacy Policy & Data Architecture

---

## 1. Zero Historical Tracking (Ephemeral Telemetry)

ShadowTrace guarantees that user movement is never converted into an archival history trail:
* The backend `current_locations` table maintains strictly **one row per device**.
* New location packets overwrite the previous coordinate atomically using `ON CONFLICT (device_id) DO UPDATE`.
* When a user turns off broadcasting, their location packet can be removed or marked dormant.

---

## 2. Client-Side Aliases & Zero PII

* **Local Nicknames Only:** Custom friend names ("Alice", "Bob") are saved strictly in the local app storage of the client device.
* **No Server Profile:** The backend has no concept of a user name, avatar photo, email address, or phone number.
* **No Telemetry Analytics:** ShadowTrace does not include third-party advertising SDKs, crashlytics tracking, or telemetry aggregators.

---

## 3. Explicit Foreground Consent

* **No Stealth Mode:** The background Service only broadcasts location when an active Android Foreground Service is running with a prominent, non-dismissible notification.
* **Instant Killswitch:** Users can tap "Stop Broadcasting" directly on the persistent notification to immediately halt location collection.
