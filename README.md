# Relax Tap Counter

A beautiful, relaxing tap counter app built with Flutter and Firebase. Features 15 animated themes, soothing sounds, haptic feedback, and cloud authentication.

## ✨ Features

- **Infinite Tap Counter**: Count to infinity with smooth animations
- **15 Relaxing Themes**: Ocean, Space, Nature, Fire, Rain, Desert, Aurora, Glacier, Sunset, Sakura, Night, Coral, Meadow, Volcano, Cyber
- **Theme-Specific Audio**: Each theme has unique tap sounds and background music
- **Haptic Feedback**: Relaxing, theme-based haptic patterns
- **Firebase Authentication**: Google Sign-In and Guest login
- **Profile & Leaderboard**: Track your progress and compete globally
- **Settings Panel**: Toggle sounds, haptics, themes, and background music
- **Cross-Platform**: Works on Android, iOS, Web, macOS, and Windows

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.6.1+)
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- [FlutterFire CLI](https://pub.dev/packages/flutterfire_cli)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/tapcounter.git
   cd tapcounter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   You have two options:

   **Option A: Use existing Firebase project (tapcounter-f0e7d)**
   - The project includes Firebase configuration
   - Authentication providers are already enabled
   
   **Option B: Create your own Firebase project**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase (follow prompts)
   flutterfire configure
   ```

4. **Enable Authentication in Firebase Console** (if using Option B)
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable **Google** provider
   - Enable **Anonymous** provider

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Firebase Setup for New Users

If you want to use your own Firebase project:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project
   - Enable Authentication and Firestore

2. **Configure FlutterFire**
   ```bash
   # Login to Firebase
   firebase login
   
   # Configure project
   flutterfire configure --project=YOUR_PROJECT_ID
   ```

3. **Update Package Name (Optional)**
   - Android: Update `applicationId` in `android/app/build.gradle`
   - iOS: Update bundle identifier in Xcode

## 📱 Platform-Specific Setup

### Android
- Minimum SDK: 21
- Target SDK: 34
- Requires Google Services for Firebase

### iOS
- iOS 12.0+
- Requires URL schemes configuration for Google Sign-In

### Web
- Firebase Auth web configuration included
- Works with all modern browsers

## 🎵 Audio Assets

The app includes placeholder audio files that should be replaced with actual relaxing sounds:

- `assets/sounds/tap.mp3` - Default tap sound
- `assets/sounds/tap_[theme].mp3` - Theme-specific tap sounds (15 files)
- `assets/sounds/music_[theme].mp3` - Background music for each theme (15 files)

Recommended sources for relaxing audio:
- [Freesound.org](https://freesound.org) - Creative Commons sounds
- [YouTube Audio Library](https://www.youtube.com/audiolibrary) - Royalty-free music
- [Zapsplat](https://zapsplat.com) - Professional sound effects

## 🏗️ Project Structure

```
lib/
├── main.dart              # Main app entry point (1400+ lines)
├── firebase_options.dart  # Firebase configuration
└── assets/
    └── sounds/           # Audio files (31 placeholder files)
```

## 🎨 Themes

1. **Ocean** 🌊 - Deep blue gradients with water sounds
2. **Space** 🌌 - Cosmic colors with ethereal audio
3. **Nature** 🌿 - Earth tones with forest ambience
4. **Fire** 🔥 - Warm oranges with crackling sounds
5. **Rain** 🌧️ - Cool blues with gentle precipitation
6. **Desert** 🏜️ - Sandy colors with wind textures
7. **Aurora** 🌈 - Magical lights with crystal sounds
8. **Glacier** ❄️ - Ice blues with pristine audio
9. **Sunset** 🌅 - Golden hues with evening warmth
10. **Sakura** 🌸 - Pink blossoms with Japanese-inspired music
11. **Night** 🌙 - Dark purples with nocturnal ambience
12. **Coral** 🐠 - Tropical colors with underwater sounds
13. **Meadow** 🌾 - Green fields with pastoral music
14. **Volcano** 🌋 - Lava reds with earth rumbles
15. **Cyber** 💻 - Neon colors with digital soundscapes

## 🔧 Configuration

The app uses several configuration files:

- `pubspec.yaml` - Dependencies and assets
- `firebase_options.dart` - Firebase project configuration
- `android/app/build.gradle` - Android-specific settings
- `android/settings.gradle` - FlutterFire plugin configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- Audio assets from various creative commons sources
- Inspiration from meditation and relaxation apps

## 🐛 Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `firebase_options.dart` is configured correctly
   - Check Firebase project settings

2. **Authentication fails**
   - Verify auth providers are enabled in Firebase Console
   - Check package names match Firebase configuration

3. **Audio not playing**
   - Ensure audio files exist in `assets/sounds/`
   - Check device volume and permissions

4. **Build failures**
   - Run `flutter clean && flutter pub get`
   - Update Flutter and dependencies

### Getting Help

- Check the Issues page on GitHub
- Create a new issue with detailed error logs
- Ensure Flutter and dependencies are up to date

---

**Enjoy your relaxing tap counting experience! 🧘‍♀️✨**
