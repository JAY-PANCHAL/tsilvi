# tsilvi

A new Flutter project.

## Getting Started

### QA: Uninstall/Reinstall Login

On Android, uninstall → reinstall could previously keep the user “logged in” due to OS Auto Backup restoring `SharedPreferences`. This app now disables Android backup (`android:allowBackup=\"false\"`) and also requires a non-empty token for `isLoggedIn()`, so a fresh install will always take the user to the login screen.

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
