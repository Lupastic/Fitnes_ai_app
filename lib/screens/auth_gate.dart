import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED
import 'pin_code_screen.dart'; // ✅ ADDED

import '../providers/google_sign_in_provider.dart';
import 'start_page.dart';
import 'navigation_wrapper.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _lastUser;

  Future<void> _logLogin(User user) async {
    // Avoid duplicate logging on rebuild
    if (_lastUser?.uid == user.uid) return;
    _lastUser = user;

    // Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'title': 'User logged in',
      'timestamp': Timestamp.now(),
    });

    // Hive
    final historyBox = await Hive.openBox('history');
    await historyBox.add({
      'title': 'User logged in',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> _checkPinRequired() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('pin_code'); // ✅ Check if pin_code is set
  }

  @override
  Widget build(BuildContext context) {
    final googleProvider = Provider.of<GoogleSignInProvider>(context);

    return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (googleProvider.isSigningIn || snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final user = snapshot.data;

      if (user != null) {
        _logLogin(user); // ✅ Log login history once
        return FutureBuilder(
          future: _checkPinRequired(), // ✅ Check if PIN is required
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final bool hasPin = snapshot.data as bool;
            return hasPin ? const PinCodeScreen() : const NavigationWrapper();
          },
        );
      }

      return const StartPage();
    },
    );
  }
}
