import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/local_repository.dart';
import '../services/settings_repository.dart';
import 'settings_provider.dart';
import 'summary_provider.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get user => _auth.currentUser;

  bool _isPinVerified = false;
  bool get isPinVerified => _isPinVerified;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void verifyPin() {
    _isPinVerified = true;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmail(String email, String password, String name) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(name);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(authProvider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;
        
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // МАКСИМАЛЬНО НАДЕЖНЫЙ ВЫХОД
  Future<void> signOut(BuildContext context) async {
    _setLoading(true);
    try {
      // 1. Сначала выходим из Firebase и Google, чтобы гарантировать разлогин
      await _auth.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      
      _isPinVerified = false;

      // 2. Пытаемся очистить локальные данные, но не прерываемся при ошибках
      try {
        final localRepo = Provider.of<LocalRepository>(context, listen: false);
        await localRepo.clearAll();
      } catch (e) {
        debugPrint('Non-critical: Local repo clear failed: $e');
      }

      try {
        final settingsRepo = Provider.of<SettingsRepository>(context, listen: false);
        await settingsRepo.clearAll();
      } catch (e) {
        debugPrint('Non-critical: Settings repo clear failed: $e');
      }

      // 3. Сбрасываем состояния провайдеров
      try {
        Provider.of<SettingsProvider>(context, listen: false).reset();
        Provider.of<SummaryProvider>(context, listen: false).reset();
      } catch (e) {
        debugPrint('Non-critical: Provider reset failed: $e');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('CRITICAL Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> shouldShowPin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('pin_code')) return true;

    try {
      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      final cloudPin = doc.data()?['pinCode'];
      
      if (cloudPin != null && cloudPin.toString().isNotEmpty) {
        await prefs.setString('pin_code', cloudPin.toString());
        return true;
      }
    } catch (e) {
      debugPrint('Error syncing PIN from Firestore: $e');
    }
    
    return false;
  }

  Future<void> deleteAccount(BuildContext context) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser.uid).delete();
    await signOut(context);
    await currentUser.delete();
  }

  String mapErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Неверный email или пароль.';
      case 'email-already-in-use':
        return 'Этот email уже используется.';
      case 'invalid-email':
        return 'Некорректный email.';
      case 'weak-password':
        return 'Слишком слабый пароль.';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение.';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже.';
      default:
        return 'Произошла ошибка входа ($code).';
    }
  }
}
