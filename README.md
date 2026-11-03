# U & Me — Flutter Social Media Demo

U & Me is a student project demonstrating a social-media-style mobile UI built with Flutter, GetX routing, and Shared Preferences.

## Features

- Login/demo entry screen with locally persisted login state
- Home feed with sample posts, like controls, and create-post dialog
- Explore page with search across local posts
- Messages list and a demo chat screen
- User profile and edit-profile dialog
- Settings page with a persistent dark-mode preference
- Named routes using GetX `GetPage`
- Local persistence using `shared_preferences`
- Material 3 UI with responsive, scrollable layouts

## Important project scope

This is a **front-end/local demo**, not a production social network. It does not include a backend, real account authentication, cloud sync, real follower data, push notifications, image upload, or messages shared between devices. Demo sign-in only stores a display name and a local login flag. Do not use real passwords or sensitive personal information.

## Requirements

- Flutter SDK (stable channel)
- Dart SDK compatible with the Flutter version
- Android Studio or VS Code with Flutter extensions
- Android emulator or Android device for testing

## Run locally

1. Extract the project ZIP.
2. Open the `u_and_me_flutter` folder in VS Code or Android Studio.
3. Run:

   ```bash
   flutter pub get
   flutter run
   ```

## Build a release APK

Connect an Android device or install Android build tools, then run:

```bash
flutter build apk --release
```

The APK is generated at:

`build/app/outputs/flutter-apk/app-release.apk`

To build a smaller APK for each CPU architecture:

```bash
flutter build apk --split-per-abi
```

The generated APKs are also placed in `build/app/outputs/flutter-apk/`.

## Routes

| Route | Screen |
|---|---|
| `/login` | Login / demo entry |
| `/home` | Main shell: Home, Explore, Messages, Profile |
| `/explore` | Explore route |
| `/messages` | Messages route |
| `/profile` | Profile route |
| `/settings` | Settings |

The main shell uses a Material `NavigationBar` with an `IndexedStack` to preserve each tab's state. GetX `GetPage` provides named route management.

## Local persistence

Shared Preferences stores:
- `username`
- `bio`
- `loggedIn`
- `darkMode`
- `posts`

Shared Preferences is intended for small local preferences and demo data, not as a full database or secure credential vault.

## Suggested GitHub workflow

Create a public GitHub repository named `u-and-me-flutter`, then from the project folder run:

```bash
git init
git add .
git commit -m "Initial Flutter app structure"
git add lib/main.dart pubspec.yaml
git commit -m "Build U & Me screens and routing"
git add README.md
git commit -m "Document features and APK build steps"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/u-and-me-flutter.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username. Keep the repository public or grant the instruction team access.

## Submission checklist

- [ ] Test all screens on an emulator or Android device
- [ ] Confirm create-post, like, profile edit, dark mode, and login persistence
- [ ] Run `flutter analyze` and fix any reported issues
- [ ] Build and test the release APK
- [ ] Push the source code and commit history to GitHub
- [ ] Add team member names and roll numbers to this README
- [ ] Submit the repository URL and release APK before the deadline

## Team members

Update this section before submission.

| Name | Roll number | Role |
|---|---|---|
| Add team member | Add roll number | Flutter development |
