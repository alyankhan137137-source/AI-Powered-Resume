import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmail(email: email, password: password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    _setLoading(true);
    try {
      _user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithGoogle();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateDisplayName(String newName) async {
    if (_user == null) return;
    _setLoading(true);
    try {
      await _authService.updateDisplayName(_user!.uid, newName);
      _user = _user!.copyWith(displayName: newName);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not update name. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('wrong-password') || msg.contains('user-not-found')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'An account already exists for this email.';
    }
    if (msg.contains('weak-password')) {
      return 'Password should be at least 6 characters.';
    }
    // Return the actual error for easier debugging if it's not a common user error
    return 'Error: $msg';
  }
}
