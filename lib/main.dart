import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const RelaxTapApp());
}

// Global app settings
class SettingsState {
  final bool soundOn;
  final bool hapticsOn;
  final bool themeEnabled; // when false, show neutral white/black UI
  final bool meditationMusicOn; // loop ambient theme sound

  const SettingsState({
    required this.soundOn,
    required this.hapticsOn,
    required this.themeEnabled,
    required this.meditationMusicOn,
  });

  SettingsState copyWith({
    bool? soundOn,
    bool? hapticsOn,
    bool? themeEnabled,
    bool? meditationMusicOn,
  }) =>
      SettingsState(
        soundOn: soundOn ?? this.soundOn,
        hapticsOn: hapticsOn ?? this.hapticsOn,
        themeEnabled: themeEnabled ?? this.themeEnabled,
        meditationMusicOn: meditationMusicOn ?? this.meditationMusicOn,
      );
}

final ValueNotifier<SettingsState> settingsNotifier = ValueNotifier(
  const SettingsState(
    soundOn: true,
    hapticsOn: false,
    themeEnabled: true,
    meditationMusicOn: false,
  ),
);

class RelaxTapApp extends StatelessWidget {
  const RelaxTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relax Tap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const RelaxHomePage(),
    );
  }
}

enum RelaxThemeType {
  ocean,
  space,
  nature,
  fire,
  rain,
  desert,
  aurora,
  glacier,
  sunset,
  sakura,
  night,
  coral,
  meadow,
  volcano,
  cyber,
}

class RelaxThemeData {
  final String label;
  final String emoji;
  final List<List<Color>> gradients; // Each entry is a list of 3 colors.
  final Color glowColor;
  final Color rippleColor;
  final String soundAsset; // Theme ambient/relaxing sound (fallback)
  final String tapSoundAsset; // Theme-specific short tap sound
  final Color textColor;

  const RelaxThemeData({
    required this.label,
    required this.emoji,
    required this.gradients,
    required this.glowColor,
    required this.rippleColor,
    required this.soundAsset,
    required this.tapSoundAsset,
    required this.textColor,
  });
}

// Default gentle tap sound used for every tap (optional asset).
const String kDefaultTapSound = 'assets/sounds/tap.mp3';

const Map<RelaxThemeType, RelaxThemeData> kThemes = {
  RelaxThemeType.ocean: RelaxThemeData(
    label: 'Ocean',
    emoji: '🌊',
    gradients: [
      [Color(0xFF00111A), Color(0xFF00334D), Color(0xFF00A3C4)],
      [Color(0xFF021D2A), Color(0xFF014F86), Color(0xFF2A9FD6)],
      [Color(0xFF012A36), Color(0xFF026C7C), Color(0xFF61D4E2)],
      [Color(0xFF00111A), Color(0xFF015871), Color(0xFF0DB7C4)],
    ],
    glowColor: Color(0xFF61D4E2),
    rippleColor: Color(0xFF61D4E2),
    soundAsset: 'assets/sounds/ocean.mp3',
    tapSoundAsset: 'assets/sounds/tap_ocean.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.space: RelaxThemeData(
    label: 'Space',
    emoji: '🌌',
    gradients: [
      [Color(0xFF05010A), Color(0xFF1B0033), Color(0xFF3A0CA3)],
      [Color(0xFF00010D), Color(0xFF240046), Color(0xFF5A189A)],
      [Color(0xFF0A0014), Color(0xFF1F1147), Color(0xFF7209B7)],
      [Color(0xFF080010), Color(0xFF2C0E4B), Color(0xFF4CC9F0)],
    ],
    glowColor: Color(0xFFB5179E),
    rippleColor: Color(0xFF4CC9F0),
    soundAsset: 'assets/sounds/space.mp3',
    tapSoundAsset: 'assets/sounds/tap_space.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.nature: RelaxThemeData(
    label: 'Nature',
    emoji: '🌿',
    gradients: [
      [Color(0xFF06200C), Color(0xFF0A3D1A), Color(0xFF2E7D32)],
      [Color(0xFF0A2612), Color(0xFF14532D), Color(0xFF34D399)],
      [Color(0xFF06200C), Color(0xFF166534), Color(0xFF86EFAC)],
      [Color(0xFF0B2C17), Color(0xFF1B5E20), Color(0xFFA7F3D0)],
    ],
    glowColor: Color(0xFF34D399),
    rippleColor: Color(0xFF86EFAC),
    soundAsset: 'assets/sounds/nature.mp3',
    tapSoundAsset: 'assets/sounds/tap_nature.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.fire: RelaxThemeData(
    label: 'Fire',
    emoji: '🔥',
    gradients: [
      [Color(0xFF1C0000), Color(0xFF5A0000), Color(0xFFFF6D00)],
      [Color(0xFF2B0000), Color(0xFF7B1E00), Color(0xFFFF8C00)],
      [Color(0xFF300000), Color(0xFF8B2E00), Color(0xFFFFB703)],
      [Color(0xFF240000), Color(0xFF6A040F), Color(0xFFFF5200)],
    ],
    glowColor: Color(0xFFFF8C00),
    rippleColor: Color(0xFFFFB703),
    soundAsset: 'assets/sounds/fire.mp3',
    tapSoundAsset: 'assets/sounds/tap_fire.mp3',
    textColor: Colors.white,
  ),

  // Additional relaxing themes
  RelaxThemeType.rain: RelaxThemeData(
    label: 'Rain',
    emoji: '☔',
    gradients: [
      [Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFF3A506B)],
      [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
      [Color(0xFF0A192F), Color(0xFF112D4E), Color(0xFF3F72AF)],
      [Color(0xFF0B132B), Color(0xFF1F3B73), Color(0xFF3282B8)],
    ],
    glowColor: Color(0xFF90CAF9),
    rippleColor: Color(0xFF64B5F6),
    soundAsset: 'assets/sounds/rain.mp3',
    tapSoundAsset: 'assets/sounds/tap_rain.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.desert: RelaxThemeData(
    label: 'Desert',
    emoji: '🏜️',
    gradients: [
      [Color(0xFF3E2723), Color(0xFF6D4C41), Color(0xFFD7A86E)],
      [Color(0xFF4E342E), Color(0xFF8D6E63), Color(0xFFF2C14E)],
      [Color(0xFF5D4037), Color(0xFFA1887F), Color(0xFFFFD166)],
      [Color(0xFF3E2723), Color(0xFF7A5C3E), Color(0xFFE9C46A)],
    ],
    glowColor: Color(0xFFF2C14E),
    rippleColor: Color(0xFFFFD166),
    soundAsset: 'assets/sounds/desert.mp3',
    tapSoundAsset: 'assets/sounds/tap_desert.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.aurora: RelaxThemeData(
    label: 'Aurora',
    emoji: '🌈',
    gradients: [
      [Color(0xFF0A0F1B), Color(0xFF1B3A4B), Color(0xFF2EC4B6)],
      [Color(0xFF0B132B), Color(0xFF5BC0BE), Color(0xFF9BF6FF)],
      [Color(0xFF120E43), Color(0xFF3A0CA3), Color(0xFF4CC9F0)],
      [Color(0xFF0A0F1B), Color(0xFF2A9D8F), Color(0xFFA7FF83)],
    ],
    glowColor: Color(0xFF80FFDB),
    rippleColor: Color(0xFF4CC9F0),
    soundAsset: 'assets/sounds/aurora.mp3',
    tapSoundAsset: 'assets/sounds/tap_aurora.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.glacier: RelaxThemeData(
    label: 'Glacier',
    emoji: '🧊',
    gradients: [
      [Color(0xFF001219), Color(0xFF005F73), Color(0xFF94D2BD)],
      [Color(0xFF0C1A1A), Color(0xFF0A9396), Color(0xFFE9D8A6)],
      [Color(0xFF001219), Color(0xFF0A9396), Color(0xFF94D2BD)],
      [Color(0xFF003049), Color(0xFF669BBC), Color(0xFFE0FBFC)],
    ],
    glowColor: Color(0xFF94D2BD),
    rippleColor: Color(0xFFA8E0D0),
    soundAsset: 'assets/sounds/glacier.mp3',
    tapSoundAsset: 'assets/sounds/tap_glacier.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.sunset: RelaxThemeData(
    label: 'Sunset',
    emoji: '🌇',
    gradients: [
      [Color(0xFF2D0A31), Color(0xFF7B2CBF), Color(0xFFFFB4A2)],
      [Color(0xFF2A0A4A), Color(0xFFE5383B), Color(0xFFFFC857)],
      [Color(0xFF3A0CA3), Color(0xFFF72585), Color(0xFFFF8500)],
      [Color(0xFF5A189A), Color(0xFFFB5607), Color(0xFFFFC6A5)],
    ],
    glowColor: Color(0xFFFFC857),
    rippleColor: Color(0xFFFFB4A2),
    soundAsset: 'assets/sounds/sunset.mp3',
    tapSoundAsset: 'assets/sounds/tap_sunset.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.sakura: RelaxThemeData(
    label: 'Sakura',
    emoji: '🌸',
    gradients: [
      [Color(0xFF2A1A1F), Color(0xFF8E3B46), Color(0xFFFFC4D6)],
      [Color(0xFF2B193D), Color(0xFFD17AAB), Color(0xFFFFD6E0)],
      [Color(0xFF3D0C3C), Color(0xFFEE6C9A), Color(0xFFFFE3EE)],
      [Color(0xFF241023), Color(0xFFB65C8A), Color(0xFFFFCDE6)],
    ],
    glowColor: Color(0xFFFFB3C6),
    rippleColor: Color(0xFFFFCDE6),
    soundAsset: 'assets/sounds/sakura.mp3',
    tapSoundAsset: 'assets/sounds/tap_sakura.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.night: RelaxThemeData(
    label: 'Night Sky',
    emoji: '🌙',
    gradients: [
      [Color(0xFF000814), Color(0xFF001D3D), Color(0xFF003566)],
      [Color(0xFF0D1321), Color(0xFF1D2D44), Color(0xFF3E5C76)],
      [Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFF5BC0BE)],
      [Color(0xFF03045E), Color(0xFF023E8A), Color(0xFF48CAE4)],
    ],
    glowColor: Color(0xFF90E0EF),
    rippleColor: Color(0xFF48CAE4),
    soundAsset: 'assets/sounds/night.mp3',
    tapSoundAsset: 'assets/sounds/tap_night.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.coral: RelaxThemeData(
    label: 'Coral Reef',
    emoji: '🪸',
    gradients: [
      [Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFF5BC0BE)],
      [Color(0xFF003049), Color(0xFF669BBC), Color(0xFFFFA69E)],
      [Color(0xFF2A9D8F), Color(0xFFE9C46A), Color(0xFFF4A261)],
      [Color(0xFF006466), Color(0xFF4D194D), Color(0xFFFFADAD)],
    ],
    glowColor: Color(0xFFFFA69E),
    rippleColor: Color(0xFFFFADAD),
    soundAsset: 'assets/sounds/coral.mp3',
    tapSoundAsset: 'assets/sounds/tap_coral.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.meadow: RelaxThemeData(
    label: 'Meadow',
    emoji: '🌼',
    gradients: [
      [Color(0xFF0A3D1A), Color(0xFF34A853), Color(0xFFB7E4C7)],
      [Color(0xFF14532D), Color(0xFF22C55E), Color(0xFFA7F3D0)],
      [Color(0xFF1B5E20), Color(0xFF86EFAC), Color(0xFFD1FAE5)],
      [Color(0xFF064E3B), Color(0xFF10B981), Color(0xFFBBF7D0)],
    ],
    glowColor: Color(0xFF86EFAC),
    rippleColor: Color(0xFFA7F3D0),
    soundAsset: 'assets/sounds/meadow.mp3',
    tapSoundAsset: 'assets/sounds/tap_meadow.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.volcano: RelaxThemeData(
    label: 'Volcano',
    emoji: '🌋',
    gradients: [
      [Color(0xFF200000), Color(0xFF5A0000), Color(0xFFFF1B0A)],
      [Color(0xFF2B0000), Color(0xFF7A1C00), Color(0xFFFF6D00)],
      [Color(0xFF300000), Color(0xFF9D0208), Color(0xFFF48C06)],
      [Color(0xFF210000), Color(0xFF6A040F), Color(0xFFF77F00)],
    ],
    glowColor: Color(0xFFFF6D00),
    rippleColor: Color(0xFFF48C06),
    soundAsset: 'assets/sounds/volcano.mp3',
    tapSoundAsset: 'assets/sounds/tap_volcano.mp3',
    textColor: Colors.white,
  ),
  RelaxThemeType.cyber: RelaxThemeData(
    label: 'Cyber',
    emoji: '💡',
    gradients: [
      [Color(0xFF0D0221), Color(0xFF251351), Color(0xFF7C238C)],
      [Color(0xFF0B132B), Color(0xFF5BC0BE), Color(0xFFB5179E)],
      [Color(0xFF160040), Color(0xFF480CA8), Color(0xFF4CC9F0)],
      [Color(0xFF0F0A3C), Color(0xFF3A0CA3), Color(0xFF90E0EF)],
    ],
    glowColor: Color(0xFFB5179E),
    rippleColor: Color(0xFF4CC9F0),
    soundAsset: 'assets/sounds/cyber.mp3',
    tapSoundAsset: 'assets/sounds/tap_cyber.mp3',
    textColor: Colors.white,
  ),
};

const RelaxThemeData kNeutralTheme = RelaxThemeData(
  label: 'Neutral',
  emoji: '',
  gradients: [
    [Colors.white, Colors.white, Colors.white],
  ],
  glowColor: Colors.black,
  rippleColor: Colors.black,
  soundAsset: kDefaultTapSound,
  tapSoundAsset: kDefaultTapSound,
  textColor: Colors.black,
);

class RelaxHomePage extends StatefulWidget {
  const RelaxHomePage({super.key});

  @override
  State<RelaxHomePage> createState() => _RelaxHomePageState();
}

class _RelaxHomePageState extends State<RelaxHomePage>
    with TickerProviderStateMixin {
  // Counter as BigInt for practical infinity
  BigInt _count = BigInt.zero;

  // Theme
  RelaxThemeType _themeType = RelaxThemeType.ocean;

  // Audio
  late final AudioPlayer _player;
  late final AudioPlayer _ambientPlayer;
  late final VoidCallback _settingsListener;

  // Background gradient animation
  late final AnimationController _bgController;
  late List<Color> _fromColors;
  late List<Color> _toColors;
  int _gradientIndex = 0;

  // Glow pulse animation for the tap circle
  late final AnimationController _glowController;

  // Ripple instances
  final List<_Ripple> _ripples = [];
  int _rippleSeq = 0;

  RelaxThemeData get _theme => kThemes[_themeType]!;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _ambientPlayer = AudioPlayer();
    _setupAudioForTheme();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _cycleGradient();
          _bgController.forward(from: 0);
        }
      });

    _initGradients();
    _bgController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _settingsListener = () {
      _updateAmbient();
      setState(() {}); // reflect settings in UI (icon color, theme mode)
    };
    settingsNotifier.addListener(_settingsListener);
    _updateAmbient();
  }

  void _initGradients() {
    final grads = _theme.gradients;
    _gradientIndex = 0;
    _fromColors = grads[_gradientIndex % grads.length];
    _toColors = grads[(_gradientIndex + 1) % grads.length];
  }

  void _cycleGradient() {
    final grads = _theme.gradients;
    _gradientIndex = (_gradientIndex + 1) % grads.length;
    _fromColors = _toColors;
    _toColors = grads[(_gradientIndex + 1) % grads.length];
  }

  Future<void> _setupAudioForTheme() async {
    try {
      // Pre-bind the source; play() will switch to this quickly
      await _player.setReleaseMode(ReleaseMode.stop);
      // Some platforms benefit from setting the source ahead of time
      await _player.setSource(AssetSource(_theme.tapSoundAsset));
      await _player.setVolume(1.0);
    } catch (_) {
      // Silently ignore audio setup errors to keep experience relaxing
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _glowController.dispose();
    _player.dispose();
    _ambientPlayer.dispose();
    settingsNotifier.removeListener(_settingsListener);
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onTap() async {
    setState(() {
      _count += BigInt.one;
      _spawnRipple();
    });

    final settings = settingsNotifier.value;
    if (settings.hapticsOn) {
      await _playRelaxingHaptic();
    }

    if (settings.soundOn) {
      // Play the default tap sound if available, fallback to theme sound.
      await _playTapSound();
    }

    // Every 10 taps, auto-rotate to the next theme for variety.
    if (_count % BigInt.from(10) == BigInt.zero) {
      final next = _nextTheme(_themeType);
      _switchTheme(next);
      // Add gentle haptic for theme change
      if (settings.hapticsOn) {
        await _playThemeChangeHaptic();
      }
    }
  }

  Future<void> _playRelaxingHaptic() async {
    try {
      // Use different haptic patterns based on current theme for variety
      switch (_themeType) {
        case RelaxThemeType.ocean:
        case RelaxThemeType.coral:
        case RelaxThemeType.rain:
          // Gentle, flowing haptics for water themes
          HapticFeedback.selectionClick();
          break;
        case RelaxThemeType.space:
        case RelaxThemeType.aurora:
        case RelaxThemeType.cyber:
          // Subtle, ethereal haptics for cosmic themes
          HapticFeedback.lightImpact();
          break;
        case RelaxThemeType.nature:
        case RelaxThemeType.meadow:
        case RelaxThemeType.sakura:
          // Soft, organic haptics for nature themes
          HapticFeedback.selectionClick();
          break;
        case RelaxThemeType.fire:
        case RelaxThemeType.volcano:
        case RelaxThemeType.sunset:
          // Warm, gentle haptics for fire themes
          HapticFeedback.lightImpact();
          break;
        case RelaxThemeType.desert:
        case RelaxThemeType.glacier:
        case RelaxThemeType.night:
          // Minimal, zen haptics for serene themes
          HapticFeedback.selectionClick();
          break;
      }
    } catch (_) {
      // Fallback to basic haptic if platform doesn't support variations
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  Future<void> _playThemeChangeHaptic() async {
    try {
      // Special gentle pattern for theme transitions
      await Future.delayed(const Duration(milliseconds: 50));
      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  RelaxThemeType _nextTheme(RelaxThemeType current) {
    final values = RelaxThemeType.values;
    final idx = values.indexOf(current);
    return values[(idx + 1) % values.length];
  }

  Future<void> _playTapSound() async {
    // Priority: theme tap sound -> default tap sound -> theme ambient sound
    try {
      await _player.stop();
      await _player.play(AssetSource(_theme.tapSoundAsset));
      return;
    } catch (_) {
      // continue to fallback
    }
    try {
      await _player.stop();
      await _player.play(AssetSource(kDefaultTapSound));
      return;
    } catch (_) {
      // continue to fallback
    }
    try {
      await _player.stop();
      await _player.play(AssetSource(_theme.soundAsset));
    } catch (_) {
      // ignore all audio errors to keep the experience smooth
    }
  }

  void _spawnRipple() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final ripple = _Ripple(keyValue: _rippleSeq++, controller: controller);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        setState(
            () => _ripples.removeWhere((r) => r.keyValue == ripple.keyValue));
      }
    });
    controller.forward();
    _ripples.add(ripple);
  }

  void _switchTheme(RelaxThemeType newType) {
    if (newType == _themeType) return;
    setState(() {
      _themeType = newType;
      _initGradients();
    });
    _setupAudioForTheme();
    _updateAmbient();
  }

  Future<void> _updateAmbient() async {
    final s = settingsNotifier.value;
    if (!s.soundOn || !s.meditationMusicOn) {
      try {
        await _ambientPlayer.stop();
      } catch (_) {}
      return;
    }
    try {
      await _ambientPlayer.stop();
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(0.12); // Quiet background level

      // Choose background music based on theme
      String musicAsset;
      switch (_themeType) {
        case RelaxThemeType.ocean:
          musicAsset = 'assets/sounds/music_ocean.mp3';
          break;
        case RelaxThemeType.space:
          musicAsset = 'assets/sounds/music_space.mp3';
          break;
        case RelaxThemeType.nature:
          musicAsset = 'assets/sounds/music_nature.mp3';
          break;
        case RelaxThemeType.fire:
          musicAsset = 'assets/sounds/music_fire.mp3';
          break;
        case RelaxThemeType.rain:
          musicAsset = 'assets/sounds/music_rain.mp3';
          break;
        case RelaxThemeType.desert:
          musicAsset = 'assets/sounds/music_desert.mp3';
          break;
        case RelaxThemeType.aurora:
          musicAsset = 'assets/sounds/music_aurora.mp3';
          break;
        case RelaxThemeType.glacier:
          musicAsset = 'assets/sounds/music_glacier.mp3';
          break;
        case RelaxThemeType.sunset:
          musicAsset = 'assets/sounds/music_sunset.mp3';
          break;
        case RelaxThemeType.sakura:
          musicAsset = 'assets/sounds/music_sakura.mp3';
          break;
        case RelaxThemeType.night:
          musicAsset = 'assets/sounds/music_night.mp3';
          break;
        case RelaxThemeType.coral:
          musicAsset = 'assets/sounds/music_coral.mp3';
          break;
        case RelaxThemeType.meadow:
          musicAsset = 'assets/sounds/music_meadow.mp3';
          break;
        case RelaxThemeType.volcano:
          musicAsset = 'assets/sounds/music_volcano.mp3';
          break;
        case RelaxThemeType.cyber:
          musicAsset = 'assets/sounds/music_cyber.mp3';
          break;
      }

      // Try theme-specific music first, fallback to peaceful default
      try {
        await _ambientPlayer.play(AssetSource(musicAsset));
      } catch (_) {
        // Fallback to default peaceful music
        try {
          await _ambientPlayer
              .play(AssetSource('assets/sounds/music_peaceful.mp3'));
        } catch (_) {
          // If still failing, try the original theme sound
          await _ambientPlayer.play(AssetSource(_theme.soundAsset));
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final settings = settingsNotifier.value;
    final useTheme = settings.themeEnabled;
    final effTheme = useTheme ? _theme : kNeutralTheme;
    final appBarIconColor = useTheme
        ? Colors.white.withOpacity(0.6)
        : Colors.black.withOpacity(0.7);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle:
            useTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        toolbarHeight: 56,
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: Icon(
              Icons.person_outline,
              color: appBarIconColor,
              size: 20,
            ),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(theme: effTheme),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      theme: effTheme,
                      count: _count,
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          // Animated gradient background
          if (useTheme)
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                final t = Curves.easeInOutCubic.transform(_bgController.value);
                final colors = List<Color>.generate(3, (i) {
                  final from = _fromColors[i % _fromColors.length];
                  final to = _toColors[i % _toColors.length];
                  return Color.lerp(from, to, t)!;
                });
                final beginAlign = Alignment(
                  math.sin(t * math.pi * 2) * 0.6,
                  math.cos(t * math.pi * 2) * 0.6,
                );
                final endAlign = Alignment(
                  math.cos(t * math.pi * 2) * -0.6,
                  math.sin(t * math.pi * 2) * -0.6,
                );
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: beginAlign,
                      end: endAlign,
                      colors: colors,
                    ),
                  ),
                );
              },
            )
          else
            Container(color: Colors.white),

          // Center content
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onTap,
              child: _GlowingTapCircle(
                glowController: _glowController,
                theme: effTheme,
                count: _count,
              ),
            ),
          ),

          // Ripples overlay
          IgnorePointer(
            child: Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  children: [
                    for (final ripple in _ripples)
                      _RippleWidget(
                        controller: ripple.controller,
                        color: effTheme.rippleColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingTapCircle extends StatelessWidget {
  final AnimationController glowController;
  final RelaxThemeData theme;
  final BigInt count;

  const _GlowingTapCircle({
    required this.glowController,
    required this.theme,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final baseSize = 220.0;
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, _) {
        final pulse = 0.8 + glowController.value * 0.2; // 0.8..1.0
        final glowOpacity = 0.35 + glowController.value * 0.25; // 0.35..0.6
        return Container(
          width: baseSize * pulse,
          height: baseSize * pulse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.glowColor.withOpacity(glowOpacity),
                blurRadius: 40,
                spreadRadius: 12,
              ),
            ],
            gradient: RadialGradient(
              colors: [
                theme.glowColor.withOpacity(0.35),
                theme.glowColor.withOpacity(0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(
              color: theme.glowColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap',
                  style: TextStyle(
                    color: theme.textColor.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Ripple {
  final int keyValue;
  final AnimationController controller;
  _Ripple({required this.keyValue, required this.controller});
}

class _RippleWidget extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _RippleWidget({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(controller.value);
        final size = 220 + t * 180; // expands beyond the tap circle
        final opacity = (1 - t).clamp(0.0, 1.0);
        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: color.withOpacity(opacity * 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Removed AppBar and theme menu for a fully minimal UI.

class ProfileScreen extends StatefulWidget {
  final RelaxThemeData theme;
  final BigInt count;

  const ProfileScreen({super.key, required this.theme, required this.count});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late List<Color> _fromColors;
  late List<Color> _toColors;
  int _gradientIndex = 0;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _initGradients();
  }

  void _initGradients() {
    final grads = widget.theme.gradients;
    _gradientIndex = 0;
    _fromColors = grads[_gradientIndex % grads.length];
    _toColors = grads[(_gradientIndex + 1) % grads.length];
  }

  void _advanceGradient() {
    final grads = widget.theme.gradients;
    // Snapshot current blended colors to start a smooth transition
    final t = _bgController.value;
    final current = List<Color>.generate(3, (i) {
      final from = _fromColors[i % _fromColors.length];
      final to = _toColors[i % _toColors.length];
      return Color.lerp(from, to, t)!;
    });
    _gradientIndex = (_gradientIndex + 1) % grads.length;
    setState(() {
      _fromColors = current;
      _toColors = grads[(_gradientIndex + 1) % grads.length];
    });
    _bgController.forward(from: 0);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final text = theme.textColor;
    // Mock leaderboard data; include current user
    final entries = <_LeaderEntry>[
      _LeaderEntry(name: 'You', taps: widget.count),
      _LeaderEntry(name: 'Luna', taps: BigInt.from(5234)),
      _LeaderEntry(name: 'Aqua', taps: BigInt.from(4980)),
      _LeaderEntry(name: 'Nova', taps: BigInt.from(4622)),
      _LeaderEntry(name: 'Breeze', taps: BigInt.from(4310)),
      _LeaderEntry(name: 'Ember', taps: BigInt.from(3999)),
    ]..sort((a, b) => b.taps.compareTo(a.taps));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: text)),
        iconTheme: IconThemeData(color: text),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: Icon(Icons.settings_outlined, color: text.withOpacity(0.8)),
            onPressed: () => _openSettings(context, theme: theme),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated gradient background that advances on tap
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final t = Curves.easeInOutCubic.transform(_bgController.value);
              final colors = List<Color>.generate(3, (i) {
                final from = _fromColors[i % _fromColors.length];
                final to = _toColors[i % _toColors.length];
                return Color.lerp(from, to, t)!;
              });
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: theme.glowColor.withOpacity(0.18),
                    child: const Icon(Icons.person,
                        size: 44, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Relax Tapper',
                    style: TextStyle(
                      color: text,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Total Taps: ${widget.count.toString()}',
                    style: TextStyle(color: text.withOpacity(0.85)),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Worldwide Leaderboard',
                    style: TextStyle(
                        color: text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...[
                  for (int i = 0; i < entries.length; i++)
                    _LeaderTile(index: i + 1, entry: entries[i], theme: theme)
                ],
              ],
            ),
          ),

          // Tap-capture layer: change only when tapping open background areas
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _advanceGradient,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderEntry {
  final String name;
  final BigInt taps;
  _LeaderEntry({required this.name, required this.taps});
}

class _LeaderTile extends StatelessWidget {
  final int index;
  final _LeaderEntry entry;
  final RelaxThemeData theme;
  const _LeaderTile(
      {required this.index, required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = theme.textColor;
    final isTop = index == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.glowColor.withOpacity(0.18)),
              boxShadow: [
                if (isTop)
                  BoxShadow(
                    color: theme.glowColor.withOpacity(0.18),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('#$index',
                      style: TextStyle(color: color.withOpacity(0.9))),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.glowColor.withOpacity(0.18),
                  child: Icon(
                    index == 1 ? Icons.emoji_events : Icons.person,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(entry.name,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w600)),
                ),
                Text('${entry.taps}',
                    style: TextStyle(color: color.withOpacity(0.9))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openSettings(BuildContext context, {required RelaxThemeData theme}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black.withOpacity(0.3),
    barrierColor: Colors.black54,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return ValueListenableBuilder<SettingsState>(
        valueListenable: settingsNotifier,
        builder: (context, settings, _) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border.all(color: theme.glowColor.withOpacity(0.18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SettingsTile(
                  label: 'Sound',
                  value: settings.soundOn,
                  onChanged: (v) =>
                      settingsNotifier.value = settings.copyWith(soundOn: v),
                ),
                _SettingsTile(
                  label: 'Haptic',
                  value: settings.hapticsOn,
                  onChanged: (v) =>
                      settingsNotifier.value = settings.copyWith(hapticsOn: v),
                ),
                _SettingsTile(
                  label: 'Theme visuals',
                  value: settings.themeEnabled,
                  onChanged: (v) => settingsNotifier.value =
                      settings.copyWith(themeEnabled: v),
                ),
                _SettingsTile(
                  label: 'Meditation music',
                  value: settings.meditationMusicOn,
                  onChanged: (v) => settingsNotifier.value =
                      settings.copyWith(meditationMusicOn: v),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      try {
                        FirebaseAuth.instance.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign out failed: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout,
                        size: 18, color: Colors.white70),
                    label: const Text('Sign out'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingsTile(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
    );
  }
}

class LoginScreen extends StatefulWidget {
  final RelaxThemeData theme;
  const LoginScreen({super.key, required this.theme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _busy = true);
    try {
      print('Starting Google Sign In...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google Sign In cancelled by user');
        setState(() => _busy = false);
        return; // cancelled
      }
      print('Google user signed in: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Got Google authentication tokens');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Created Firebase credential, signing in...');
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('Firebase sign in successful: ${userCredential.user?.email}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Signed in as ${userCredential.user?.email ?? "Google User"}')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Google sign-in error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() => _busy = true);
    try {
      print('Starting Anonymous Sign In...');
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print('Anonymous sign in successful: ${userCredential.user?.uid}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in as Guest')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Guest sign-in error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Guest sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final text = theme.textColor;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Login', style: TextStyle(color: text)),
        iconTheme: IconThemeData(color: text),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.gradients.first,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign in to view your profile',
                      style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _busy ? null : _signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.12),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _busy ? null : _signInAsGuest,
                        child: const Text('Continue as Guest'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.4)),
                        ),
                      ),
                    ),
                    if (_busy) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
