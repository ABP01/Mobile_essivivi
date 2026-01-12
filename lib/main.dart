import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/theme/app_theme.dart';
import 'package:essivi_mobile/providers/theme_provider.dart';
import 'package:essivi_mobile/providers/language_provider.dart';
import 'package:essivi_mobile/providers/notification_provider.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/routes/route_generator.dart';

void main() {
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

  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
          provider.ChangeNotifierProvider(create: (_) => LanguageProvider()),
          provider.ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'Essivi Water',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
