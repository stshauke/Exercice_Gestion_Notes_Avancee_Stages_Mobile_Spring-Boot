import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/local_db_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalDbService _localDbService = LocalDbService();
  
  bool _isLoading = false;
  String _error = '';
  bool _isLoggedIn = false;
  int? _userId;
  String? _userEmail;

  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;
  String? get userEmail => _userEmail;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _userId = await _authService.getUserId();
        _userEmail = await _authService.getUserEmail();
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la vérification du statut auth: $e');
      }
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, {BuildContext? context}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.login(email, password);
      await _checkAuthStatus(); // Re-vérifie le statut après login
      
      if (_isLoggedIn && context != null && context.mounted) {
        // 🔥 REDIRECTION APRÈS CONNEXION RÉUSSIE
        Navigator.of(context).pushReplacementNamed('/notes');
        return true;
      }
      return _isLoggedIn;
      
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      
      // 🔥 AFFICHAGE DE L'ERREUR SI CONTEXTE DISPONIBLE
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, {String role = 'USER', BuildContext? context}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.register(email, password, role: role);
      await _checkAuthStatus(); // Re-vérifie le statut après registration
      
      if (_isLoggedIn && context != null && context.mounted) {
        // 🔥 REDIRECTION APRÈS INSCRIPTION RÉUSSIE
        Navigator.of(context).pushReplacementNamed('/notes');
        return true;
      }
      return _isLoggedIn;
      
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      
      // 🔥 AFFICHAGE DE L'ERREUR SI CONTEXTE DISPONIBLE
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'inscription: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout({BuildContext? context}) async {
    try {
      await _authService.logout();
      _isLoggedIn = false;
      _userId = null;
      _userEmail = null;
      _error = '';
      
      // 🔥 REDIRECTION APRÈS DÉCONNEXION
      if (context != null && context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la déconnexion: $e';
      
      // 🔥 AFFICHAGE DE L'ERREUR SI CONTEXTE DISPONIBLE
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}