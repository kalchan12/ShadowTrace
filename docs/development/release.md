# Release & Distribution Guide

---

## 1. Dual APK Packaging

ShadowTrace requires building two distinct signed APKs for every release:
1. `shadowtrace-client-vX.Y.Z.apk`
2. `shadowtrace-service-vX.Y.Z.apk`

---

## 2. Signing Keys
* Both APKs should ideally be signed with the same developer signing certificate so that `PackageManager.checkSignatures()` can verify IPC caller authenticity without complex certificate whitelisting.
* Never commit production keystores to version control. Set up environment variables `SHADOWTRACE_KEYSTORE_PATH` and `SHADOWTRACE_KEYSTORE_PASSWORD` in CI/CD runners.

---

## 3. Pre-Flight Checklist
- [ ] `./scripts/validate.sh` passes with zero errors.
- [ ] No debug mock endpoints enabled in release builds.
- [ ] All RLS policies on Supabase are active and tested.
- [ ] Android permissions in `AndroidManifest.xml` match requirements.
