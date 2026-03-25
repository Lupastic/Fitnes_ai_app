import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get user => _auth.currentUser;

  // Флаг того, что ПИН-код был успешно введен в текущей сессии
  bool _isPinVerified = false;
  bool get isPinVerified => _isPinVerified;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Метод для подтверждения ПИН-кода
  void verifyPin() {
    _isPinVerified = true;
    notifyListeners();
  }

  // --- Вход через Email ---
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

  // --- Регистрация ---
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

  // --- Google Sign-In ---
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

  // --- Выход ---
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      // Также выходим из Google, чтобы при следующем входе можно было выбрать аккаунт
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      _isPinVerified = false; // Сбрасываем флаг ПИН-кода
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // --- Сброс пароля ---
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // --- Проверка необходимости ПИН-кода (Синхронизация) ---
  Future<bool> shouldShowPin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final prefs = await SharedPreferences.getInstance();
    
    // 1. Проверяем локально
    if (prefs.containsKey('pin_code')) return true;

    // 2. Если локально нет, проверяем в Firestore (синхронизация для нового устройства)
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

  // --- Удаление аккаунта ---
  Future<void> deleteAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser.uid).delete();
    await currentUser.delete();
    _isPinVerified = false;
    notifyListeners();
  }

  // Маппинг ошибок на русский язык
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
