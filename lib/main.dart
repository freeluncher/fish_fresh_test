import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/detection_history.dart';

import 'pages/fish_detection_page.dart';
import 'pages/onboarding_page.dart';
import 'config/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DetectionHistoryAdapter());
  await Hive.openBox<DetectionHistory>('history');
  runApp(const FishDetectionApp());
}

class FishDetectionApp extends StatelessWidget {
  const FishDetectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishFresh',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (done) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnboardingPage(
            onFinish: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${info.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              'Deteksi Kesegaran Ikan Bandeng',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            if (_appVersion.isNotEmpty)
              Text(
                'Versi aplikasi: $_appVersion',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  bool _permissionsGranted = false;
  bool _checkingPermissions = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _checkingPermissions = true;
    });

    try {
      // Request camera permission
      PermissionStatus cameraStatus = await Permission.camera.request();

      // Request storage permissions (for gallery access)
      PermissionStatus storageStatus = await Permission.storage.request();

      // For Android 13+ (API level 33+), use photos permission
      PermissionStatus photosStatus = await Permission.photos.request();

      bool hasPermissions = cameraStatus.isGranted &&
          (storageStatus.isGranted || photosStatus.isGranted);

      setState(() {
        _permissionsGranted = hasPermissions;
        _checkingPermissions = false;
      });

      if (!hasPermissions) {
        _showPermissionDialog();
      }
    } catch (e) {
      print('Kesalahan saat memeriksa izin: $e');
      setState(() {
        _checkingPermissions = false;
        _permissionsGranted = false;
      });
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Diperlukan'),
          content: const Text(
            'Aplikasi ini memerlukan izin kamera dan penyimpanan agar dapat berfungsi dengan baik. '
            'Silakan berikan izin ini di pengaturan aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkPermissions();
              },
              child: const Text('Coba Lagi'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPermissions) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Memeriksa izin...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Izin Diperlukan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Izin kamera dan penyimpanan diperlukan agar deteksi ikan dapat berfungsi dengan baik.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Berikan Izin'),
              ),
            ],
          ),
        ),
      );
    }

    return const FishDetectionPage();
  }
}

// Extension untuk mengecek status permission
extension PermissionStatusExtension on PermissionStatus {
  bool get isAccepted =>
      this == PermissionStatus.granted || this == PermissionStatus.limited;
}
