@echo off
title Relax Tap Counter Setup

echo 🚀 Setting up Relax Tap Counter...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed. Please install Flutter first:
    echo    https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter found

REM Show Flutter version
echo 📱 Flutter version:
flutter --version

REM Install dependencies
echo 📦 Installing dependencies...
flutter pub get

REM Check if Firebase CLI is available
firebase --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Firebase CLI not found. Please install Node.js and Firebase CLI:
    echo    npm install -g firebase-tools
)

REM Check if FlutterFire CLI is available
dart pub global list | findstr flutterfire_cli >nul
if errorlevel 1 (
    echo ⚠️  FlutterFire CLI not found. Installing...
    dart pub global activate flutterfire_cli
)

echo.
echo 🔧 Setup options:
echo 1. Use existing Firebase project (tapcounter-f0e7d) - Ready to run
echo 2. Configure with your own Firebase project

set /p choice="Choose option (1 or 2): "

if "%choice%"=="1" (
    echo ✅ Using existing Firebase configuration
    echo 🎯 You can run the app now with: flutter run
) else if "%choice%"=="2" (
    echo 🔥 Setting up your own Firebase project...
    echo 📝 Please make sure you have:
    echo    - Created a Firebase project
    echo    - Enabled Authentication (Google + Anonymous)
    echo    - Enabled Firestore Database
    
    pause
    
    REM Login to Firebase
    firebase login
    
    REM Configure FlutterFire
    flutterfire configure
    
    echo ✅ Firebase configuration complete!
) else (
    echo ❌ Invalid option. Please run the script again.
    pause
    exit /b 1
)

echo.
echo 🎉 Setup complete! Here's what you can do:
echo.
echo 📱 Run on device/emulator:
echo    flutter run
echo.
echo 🌐 Run on web:
echo    flutter run -d web
echo.
echo 🔧 Build for release:
echo    flutter build apk        # Android
echo    flutter build appbundle  # Android App Bundle
echo    flutter build web        # Web
echo.
echo 🎵 Audio files:
echo    Replace placeholder files in assets/sounds/ with real audio
echo.
echo 📚 For more info, check README.md
echo.
echo Happy tapping! 🧘‍♀️✨
pause