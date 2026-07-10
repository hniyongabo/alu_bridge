# Development Log — Challenges & Lessons Learned

Running notes on setup/tooling issues encountered during development, for the
"Challenges Faced" / "Lessons Learned" section of the final technical report.

## Firebase CLI network instability (ECONNRESET)
`flutterfire configure` intermittently failed with `ECONNRESET` when POSTing to
`firebase.googleapis.com` to register Android/iOS apps (GET requests like
`projects:list` worked fine). Worked around by registering the Android app
manually in the Firebase Console first, then re-running `flutterfire configure`
so the CLI only needed to *read* the existing app instead of creating one.

## Switching Google accounts created a second Firebase project
Logging the Firebase CLI into a different Google account and re-running
`flutterfire configure --project=alu-bridge` did not reuse the existing
`alu-bridge` project — Firebase project IDs are globally unique per account,
so it silently created a new project `alu-bridge-b4d94`. Required deleting the
original project and redoing Firestore (Standard edition, `africa-south1`)/
Auth/Storage setup on the new one. Lesson: decide on the Firebase-owning
Google account before creating the project, not after.

## First Android build was extremely slow (~27 minutes)
The first `flutter run` on the Android emulator triggered on-demand downloads
of Android SDK Platform 34 and 35 (required by Firebase's Android
dependencies) in addition to a cold Gradle build compiling all
Firebase/AndroidX native code. Subsequent builds were much faster
(under a minute) since Gradle caches persisted.

## Emulator adb install/launch race condition
After a successful `flutter run` build and `adb install`, launching the app
failed with `Error: Activity class {com.alubridge.app/com.alubridge.app.MainActivity}
does not exist`, even though `dumpsys package` and `aapt dump badging` both
confirmed the activity was correctly declared and installed. This appears to
be a package-manager indexing race condition specific to this emulator image,
not a code/config issue. Noted as a known flaky step to retry (uninstall +
reinstall, or restart the emulator) rather than a real bug.

## Desktop/web builds are not a viable fallback
Firebase's Flutter plugins (`firebase_auth`, `cloud_firestore`,
`firebase_storage`) have no Windows or Linux desktop implementation, and web
was never configured via FlutterFire. `DefaultFirebaseOptions.currentPlatform`
explicitly throws `UnsupportedError` for those platforms. This confirms
Android (emulator or physical device) is the only viable target for this app,
consistent with the assignment's requirement to run on mobile.
