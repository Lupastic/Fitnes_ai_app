import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/user_data_service.dart';
import 'onboarding_page.dart';
import 'package:finallapp/generated/l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();

  bool _obscurePassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AppAuthProvider>();
    final settings = context.read<SettingsProvider>();
    final userDataService = context.read<UserDataService>();

    try {
      await auth.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final pin = _pinController.text.trim();

        await settings.updateName(_nameController.text.trim());

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pin_code', pin);

        await userDataService.updateProfileData(
          name: _nameController.text.trim(),
          pinCode: pin,
        );

        await currentUser.sendEmailVerification();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (c) => const OnboardingPage()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.mapErrorMessage(e.code)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppAuthProvider>().isLoading;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.createAccount, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text(loc.enterDetails, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),
                
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.yourName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? loc.enterName : null,
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: loc.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || !v.contains('@')) return loc.validEmailRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: loc.createPin,
                    prefixIcon: const Icon(Icons.pin),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 4) ? loc.pinMin4Digits : null,
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: loc.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? loc.min6Chars : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: loc.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return loc.passwordsDontMatch;
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(loc.signUp, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
