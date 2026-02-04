import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../locale_provider.dart';
import 'create_account_screen.dart'; // Import the CreateAccountScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
        leading: null,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: currentLocale,
                icon: const Icon(Icons.language, color: Color(0xFF007BFF)),
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                items: [
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Row(
                      children: [
                        const Text('🇺🇸', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('English'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: const Locale('ar'),
                    child: Row(
                      children: [
                        const Text('🇸🇦', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('العربية'),
                      ],
                    ),
                  ),
                ],
                onChanged: (locale) {
                  if (locale != null) localeProvider.setLocale(locale);
                },
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Logo
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.bubble_chart, size: 56, color: Theme.of(context).primaryColor),
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                  shape: BoxShape.circle,
                ),
              ),
              // Login Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: currentLocale.languageCode == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      TextField(
                        textAlign: currentLocale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
                        decoration: InputDecoration(
                          labelText: loc.emailLabel, // Corrected: Localized email label
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        textAlign: currentLocale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
                        decoration: InputDecoration(
                          labelText: loc.passwordLabel, // Localized
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/home'); // Use named route for navigation
                          },
                          child: Text(loc.loginButton), // Use the correct key for Login
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(loc.orLabel), // Localized
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.g_mobiledata, color: Color(0xFF4285F4), size: 28),
                          label: Text(loc.loginWithGoogle), // Corrected key
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.white,
                            alignment: currentLocale.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Improved Create Account navigation
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.dontHaveAccount ,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CreateAccountScreen()),
                      );
                    },
                    child: Text(
                      loc.createAccount,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
