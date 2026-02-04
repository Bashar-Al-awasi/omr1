import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  bool _isLoading = false;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: Implement real account creation logic (e.g., Firebase Auth)
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.createAccount)),
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007BFF)),
        title: Text(loc.createAccount, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add, size: 48, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 18),
                    Text(loc.createAccount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 28),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
                      onChanged: (v) => _email = v,
                      ),
                     const SizedBox(height: 18),
                     TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) => value != null && value.length >= 6 ? null : 'Password too short',
                      onChanged: (v) => _password = v,
                     ),
                     const SizedBox(height: 18),
                     TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.userName, // User Name
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) => value != null && value.trim().isNotEmpty ? null : loc.enterValidUserName ?? 'Enter a valid user name',
                      onChanged: (v) => _name = v,
                     ),
                     const SizedBox(height: 32),
                     SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(loc.createAccount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
