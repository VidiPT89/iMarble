# 🔴 iMarble

> Três Covas — the traditional Portuguese marble game, natively reimagined for iOS with SwiftUI and SpriteKit.

[Report Bug](https://github.com/VidiPT89/iMarble/issues) · [Request Feature](https://github.com/VidiPT89/iMarble/issues)

## ✨ Features

- ✅ Traditional "Três Covas" rules — three holes in a row, drag-to-launch physics, the "palmo" mechanic and marble captures
- ✅ 2 to 4 players, human vs. AI opponents with three difficulty levels
- ✅ Realistic marble physics powered by SpriteKit — friction, collisions and hole detection
- ✅ Smooth, native animations, particle effects and haptic feedback on key moments
- ✅ Classic mode and points mode, both fully configurable before each match
- ✅ Runtime language switch — Português (PT-PT) and English, independent of system locale
- ✅ Dark mode, Light mode, and System mode
- ✅ Custom color identity inspired by [ividi.dev](https://ividi.dev/) — burnt orange, amber and black
- ✅ Short in-app tutorial, repeatable from Settings

## 🛠️ Tech Stack

| Category    | Technology            |
|-------------|------------------------|
| Language    | Swift 5.9+              |
| UI          | SwiftUI (iOS 16+)        |
| Physics     | SpriteKit                |
| Architecture| MVVM                     |
| Project     | XcodeGen                 |

## 🚀 Quick Start

**Prerequisites**
- Xcode 15+
- iOS 16+ simulator or device

**Steps**

```bash
git clone https://github.com/VidiPT89/iMarble.git
cd iMarble
open iMarble.xcodeproj
```

Select the `iMarble` scheme and run on a simulator or device.

## 📖 Usage

Launch the app, set up a match from the main menu (number of players, AI difficulty, classic or
points mode, palmo on/off), then drag your marble backwards like a slingshot and release to
launch it toward the next hole. Complete the full sequence of holes to unlock attacks on your
opponents' marbles. Switch language and appearance at any time from Settings.

## 🧪 Testing

Build and run the `iMarble` scheme in Xcode (`⌘R`), or verify the project compiles via:

```bash
xcodebuild -project iMarble.xcodeproj -scheme iMarble -destination 'generic/platform=iOS Simulator' build
```

Unit tests cover the core game rules, turn management and victory conditions.

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

## 👨‍💻 Author

**David Arsénio Martins**

🌐 Website: [ividi.dev](https://ividi.dev/)
🐙 GitHub: [@VidiPT89](https://github.com/VidiPT89/)

## 🤝 Contributing

Contributions, issues and feature requests are welcome. Feel free to check the [issues page](https://github.com/VidiPT89/iMarble/issues).

---

<p align="center">Developed by <a href="https://ividi.dev">David Arsénio Martins</a></p>
<p align="center">If you like this project, consider giving it a ⭐</p>
