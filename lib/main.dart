import 'ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_manager.dart';
import 'services/storage_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.init();

  // Fullscreen orientation & immersive styling
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.init();
  final audioManager = AudioManager(storageService);

  runApp(
    FruitCutterApp(
      storageService: storageService,
      audioManager: audioManager,
    ),
  );
}

class FruitCutterApp extends StatelessWidget {
  final StorageService storageService;
  final AudioManager audioManager;

  const FruitCutterApp({
    super.key,
    required this.storageService,
    required this.audioManager,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Cutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: HomeScreen(
        storageService: storageService,
        audioManager: audioManager,
      ),
    );
  }
}

