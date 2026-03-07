import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/offline_storage_service.dart';
import '../models/user_model.dart';

/// Authentication state provider.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final OfflineStorageService _storage;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthService authService,
    required OfflineStorageService storage,
  })  : _authService = authService,
        _storage = storage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  /// Attempt to restore a previous session from local storage.
  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    // First try local cache.
    _currentUser = _storage.getCurrentUser();
    if (_currentUser != null) {
      _isLoading = false;
      notifyListeners();
    }

    // Then try Firebase.
    final uid = await _authService.restoreSession();
    if (uid == null && _currentUser == null) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = await _authService.signIn(email, password);
      if (uid != null) {
        // In production, fetch user profile from Firestore.
        _currentUser = UserModel(
          id: uid,
          username: email.split('@').first,
          createdAt: DateTime.now(),
          email: email,
        );
        await _storage.saveUser(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Invalid credentials';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Create a new account.
  Future<bool> signUp(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = await _authService.signUp(email, password);
      if (uid != null) {
        _currentUser = UserModel(
          id: uid,
          username: username,
          createdAt: DateTime.now(),
          email: email,
        );
        await _storage.saveUser(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Registration failed';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign in with Google.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = await _authService.signInWithGoogle();
      if (uid != null) {
        _currentUser = UserModel(
          id: uid,
          username: 'Google User', // Placeholder username
          createdAt: DateTime.now(),
          email: '', // Not always available immediately from fallback
        );
        await _storage.saveUser(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
