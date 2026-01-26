import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/providers/agent_provider.dart';
import 'package:essivi_mobile/providers/appwrite_auth_provider.dart';
import 'package:essivi_mobile/providers/language_provider.dart';
import 'package:essivi_mobile/providers/notification_provider.dart';
import 'package:essivi_mobile/providers/shipment_provider.dart';
import 'package:essivi_mobile/providers/theme_provider.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/routes/route_generator.dart';
import 'package:essivi_mobile/services/appwrite_service.dart';
import 'package:essivi_mobile/services/firebase_messaging_service.dart';
import 'package:essivi_mobile/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

/// 🚀 Handler pour les messages Firebase en arrière-plan
/// DOIT être une fonction top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Message reçu en arrière-plan: ${message.notification?.title}');
}

void main() async {
  // S'assurer que les widgets sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialiser Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialisé avec succès');

    // Configurer le handler de messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('❌ Erreur initialisation Firebase: $e');
  }

  // Capture Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Capture platform errors (async gaps, etc.)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ShipmentProvider()),
        ChangeNotifierProvider(create: (_) => AgentProvider()),
        ChangeNotifierProvider(create: (_) => AppwriteAuthProvider()),
        Provider(create: (_) => AppwriteService()),
        Provider(create: (_) => FirebaseMessagingService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initialise tous les services au démarrage
  Future<void> _initializeServices() async {
    try {
      // Initialiser le service de notifications push
      await _messagingService.initialize();

      // Initialiser l'authentification Appwrite
      final authProvider = context.read<AppwriteAuthProvider>();
      await authProvider.initialize();

      // Si l'utilisateur est connecté, abonner aux notifications
      if (authProvider.isAuthenticated && _messagingService.fcmToken != null) {
        await authProvider.subscribeToPush(_messagingService.fcmToken!);

        // S'abonner aux topics selon le rôle
        final userPrefs = authProvider.currentUser?.prefs;
        final userRole = userPrefs?.data['role'];
        if (userRole == 'agent') {
          await _messagingService.subscribeToTopic('agents');
        } else if (userRole == 'client') {
          await _messagingService.subscribeToTopic('clients');
        }
      }

      debugPrint('✅ Services initialisés avec succès');
    } catch (e) {
      debugPrint('❌ Erreur initialisation services: $e');
    }
  }

  @override
  void dispose() {
    _messagingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'Essivi Eau',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: RouteGenerator.generateRoute,
        );
      },
    );
  }
}
