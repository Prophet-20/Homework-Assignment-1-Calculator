# Release APK verification

Date: October 11, 2026 (America/New_York)
Device: Pixel 10 Pro XL API 37.1 Android emulator, launched in Android Studio.
Installation: adb install of the release APK completed with Success.

Manual checks on the installed release build:
- 2 + 3 × displayed 5; 4 = then displayed 20.
- Light-to-dark theme switch preserved 20 and updated calculator surfaces.
- AC followed by 8 ÷ 0 = displayed Error with AC/digit recovery guidance.
- Entering 4 + 2 = after that error displayed 6.
- AC followed by 7 + = displayed 7, retained pending +, and requested an operand.
- Entering 2 = then displayed 9.

Automated model and widget coverage is recorded in automated-tests.txt.
TalkBack listening was not performed; semantics labels were tested in Flutter.
