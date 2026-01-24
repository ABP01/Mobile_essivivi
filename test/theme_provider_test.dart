import 'package:essivi_mobile/providers/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      await Future.delayed(Duration.zero); // Wait for init
    });

    test('initial theme is light', () {
      expect(themeProvider.isDarkMode, false);
    });

    test('toggleTheme changes mode', () {
      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, true);
    });

    test('setTheme sets correct mode', () {
      themeProvider.setTheme(true);
      expect(themeProvider.isDarkMode, true);
    });
  });
}
