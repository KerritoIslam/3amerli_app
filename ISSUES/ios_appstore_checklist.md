# iOS App Store Readiness Checklist

This checklist covers common items required before submitting an iOS app to the App Store.

- [ ] Unique bundle identifier set in Xcode (Runner target -> General -> Identity).
- [ ] App icons and launch images configured for all required sizes (Assets.xcassets).
- [ ] Code signing & provisioning configured for Release builds (Team selected, correct provisioning profile).
- [ ] Remove any debug-only code, test servers, or hardcoded API keys.
  - Replace `placeholderBaseUrl` if it points to dev servers.
- [ ] Privacy policy URL added to App Store Connect and linked in-app where required.
- [ ] Info.plist contains required privacy usage descriptions for features that request permissions:
  - Location: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription` (added)
  - Camera: `NSCameraUsageDescription` (add if camera used)
  - Photos: `NSPhotoLibraryUsageDescription` (add if photo library access used)
  - Microphone: `NSMicrophoneUsageDescription` (add if audio recording used)
- [ ] Push notification entitlements and APNs setup
  - Enable Push Notifications capability in Xcode
  - Upload APNs key/certificate in App Store Connect or configure Firebase (if using FCM)
  - Include user-visible explanations in the app for notification usage and respect user settings
- [ ] Background modes (only if needed)
  - If using background location, enable Background Modes -> Location updates and include rationale in the App Store submission notes
- [ ] App Transport Security (ATS)
  - Prefer HTTPS for all network calls. If exceptions are required, keep them domain-specific and document why.
  - Development-only ATS exceptions should be removed before App Store submission.
- [ ] Remove any sensitive or debug files from the build (e.g., debug config, development-only assets).
- [ ] Test on real devices (iPhone, iPad) and verify permission dialogs appear with the correct app-facing strings.
- [ ] Run App Store validation in Xcode (Archive -> Validate) and fix warnings/errors.

- Notes:
- The project previously had a development ATS exception for `10.223.60.91`. That entry has been removed from `Info.plist` to avoid accidental submission. If you need insecure HTTP access to local/dev servers during development, use one of these safer approaches:

- 1) Manual temporary edit (quick & simple)
  - Open `ios/Runner/Info.plist` in Xcode and add an `NSAppTransportSecurity` -> `NSExceptionDomains` entry for your dev host (e.g., `10.223.60.91`).
  - Remove the entry before making a release build for the App Store.

- 2) Per-configuration Info.plists (recommended)
  - Create `Info-Debug.plist` and `Info-Release.plist`. Add the ATS exception only in `Info-Debug.plist`.
  - In Xcode, set the `Info.plist File` build setting for Debug to `Info-Debug.plist` and for Release to `Info-Release.plist`.
  - This guarantees the exception is present only in debug builds.

- 3) Debug-only run script (automated)
  - Add a Run Script build phase in Xcode that runs only for Debug builds and patches `Info.plist` to add the ATS exception at build time. Example script (bash):

```bash
if [ "${CONFIGURATION}" = "Debug" ]; then
  /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity dict" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" || true
  /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains dict" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" || true
  /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains:10.223.60.91 dict" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" || true
  /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains:10.223.60.91:NSTemporaryExceptionAllowsInsecureHTTPLoads bool true" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" || true
fi
```

  - This keeps the repository clean and ensures exceptions appear only in debug builds.

- Firebase Cloud Messaging requires additional setup (GoogleService-Info.plist, APNs). Follow the Firebase iOS setup docs when enabling push.
- Firebase Cloud Messaging requires additional setup (GoogleService-Info.plist, APNs). Follow the Firebase iOS setup docs when enabling push.
