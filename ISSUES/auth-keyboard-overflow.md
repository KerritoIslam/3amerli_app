Title: auth key board over flow

Description:
When the keyboard opens on the sign up page the bottom panel overflows; I added a SingleChildScrollView/ConstrainedBox/IntrinsicHeight wrapper but introduced a syntax mismatch which I fixed in the latest commit. Need to verify on device and ensure no overflow remains; also make resend tappable and add cooldown.

Steps to reproduce:
1. Open the app and navigate to Sign Up.
2. Tap the phone input to open the keyboard.
3. Observe panel overflow or clipping.

Expected:
Panel scrolls or adjusts to keep inputs and buttons visible when the keyboard is open.

Actual:
Previously caused a compile error; fixed in commit 0a4bda9 -> 0a4bda9. Please verify on device/emulator and consider additional UX adjustments (resend cooldown, animated underline).

Commit: 0a4bda9 (branch: islam)
Labels: bug, needs-verification
Assignee: @KerritoIslam

Notes:
- I updated `lib/features/auth/app/pages/sign_up_page.dart` to wrap panel content in a scrollable container and replaced many hard-coded sizes with `AppDimensions`.
- There is an opportunity to improve the resend flow: make the 'Renvoyer le code' tappable and add a cooldown to prevent spam.
- Recommend testing on Android and iOS devices to validate keyboard behavior and safe-area handling.
