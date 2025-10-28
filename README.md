
# 🐻 Polar Bear Login Animation

A Flutter login app featuring an interactive polar bear animation using Rive. The bear reacts dynamically to user input, making the login experience fun and engaging.

## ✨ Features

- Email input observation 👀
- Password input: bear covers eyes 🙈
- Success login animation 🎉
- Failed login animation 😢
- Real-time interactive animations controlled via Rive State Machine

## 🖌️ About Rive & State Machines

[Rive](https://rive.app/) is a tool for creating interactive animations that can be used in apps and websites.
A State Machine in Rive allows animations to respond to triggers, boolean values, and numeric inputs, enabling dynamic control.

Inputs used in this project:

- `trigSuccess` → trigger bear’s happiness ✅
- `trigFail` → trigger bear’s sadness ❌
- `isHandsUp` → bear covers eyes 🙈
- `isChecking` → bear watches screen 👀
- `numLook` → controls the bear’s eye movement 👁️

## 💻 Technologies

- Flutter 🐦
- Dart 💻
- Rive 🖌️
- Git & GitHub 🛠️

## 📂 Project Structure

```text
login_with_animation_5sa/
├─ assets/
│ └─ rive/ # Rive animation file (.riv)
├─ lib/
│ ├─ main.dart
│ └─ screens/
│ └─ login_screen.dart # Login screen with bear animation
└─ pubspec.yaml # Dependencies and assets
```

## Course Info

- Course Name: Graphing
- Instructor: Rodrigo Fidel Gaxiola Sosa

## Credits

The original polar bear animation was created by [Khanh Nguyen on Rive](https://rive.app/marketplace/3645-7621-remix-of-login-machine/)