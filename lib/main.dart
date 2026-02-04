import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:omr1/screens/welcome_screen.dart';
import 'package:provider/provider.dart'; // 1. Import provider
import 'locale_provider.dart'; // 2. Import your provider
import 'screens/home_dashboard_screen.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const OmrApp(),
    ),
  );
}

class OmrApp extends StatelessWidget {
  const OmrApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Listen to the provider for locale changes
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'Smart OMR',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF007BFF),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF007BFF),
          secondary: const Color(0xFF28A745),
          error: const Color(0xFFDC3545),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007BFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const WelcomeScreen(), // Use WelcomeScreen from the new file
      routes: {
        '/home': (_) => const HomeDashboardScreen(),
        // Add other screens here as needed
      },
    );
  }
}
//test for git uplouad