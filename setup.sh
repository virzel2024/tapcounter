#!/bin/bash

# Relax Tap Counter Setup Script
# This script helps new users set up the project on their machine

echo "🚀 Setting up Relax Tap Counter..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found"

# Check Flutter version
echo "📱 Flutter version:"
flutter --version

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Check if Firebase CLI is available
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Check if FlutterFire CLI is available
if ! dart pub global list | grep -q flutterfire_cli; then
    echo "⚠️  FlutterFire CLI not found. Installing..."
    dart pub global activate flutterfire_cli
fi

echo "🔧 Setup options:"
echo "1. Use existing Firebase project (tapcounter-f0e7d) - Ready to run"
echo "2. Configure with your own Firebase project"

read -p "Choose option (1 or 2): " choice

case $choice in
    1)
        echo "✅ Using existing Firebase configuration"
        echo "🎯 You can run the app now with: flutter run"
        ;;
    2)
        echo "🔥 Setting up your own Firebase project..."
        echo "📝 Please make sure you have:"
        echo "   - Created a Firebase project"
        echo "   - Enabled Authentication (Google + Anonymous)"
        echo "   - Enabled Firestore Database"
        
        read -p "Press Enter when ready to configure Firebase..."
        
        # Login to Firebase
        firebase login
        
        # Configure FlutterFire
        flutterfire configure
        
        echo "✅ Firebase configuration complete!"
        ;;
    *)
        echo "❌ Invalid option. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 Setup complete! Here's what you can do:"
echo ""
echo "📱 Run on device/emulator:"
echo "   flutter run"
echo ""
echo "🌐 Run on web:"
echo "   flutter run -d web"
echo ""
echo "🔧 Build for release:"
echo "   flutter build apk        # Android"
echo "   flutter build ios        # iOS"
echo "   flutter build web        # Web"
echo ""
echo "🎵 Audio files:"
echo "   Replace placeholder files in assets/sounds/ with real audio"
echo ""
echo "📚 For more info, check README.md"
echo ""
echo "Happy tapping! 🧘‍♀️✨"