import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../utils/constants.dart';
import 'local_db_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse('${Constants.apiBaseUrl}${Constants.loginEndpoint}');
    final loginRequest = LoginRequest(email: email, password: password);

    // 🔥 AJOUT DES LOGS DE DEBUG CRITIQUES
    print('🔐 === TENTATIVE DE CONNEXION ===');
    print('🌐 URL: $url');
    print('📧 Email: $email');

    final jsonBody = json.encode(loginRequest.toJson());
    print('📦 JSON Body: $jsonBody');

    try {
      print('📡 Envoi de la requête HTTP...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      print('📊 Réponse reçue: ${response.statusCode}');
      print('📄 Body de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Connexion réussie!');

        try {
          final responseData = json.decode(response.body);
          print('📋 ResponseData: $responseData');

          // 🔥 CORRECTION: Vérifiez que tous les champs sont présents
          if (!responseData.containsKey('token') ||
              !responseData.containsKey('id') || // 🔥 'id' et non 'userId'
              !responseData.containsKey('email')) {
            throw FormatException(
              'Champs manquants dans la réponse. Clés disponibles: ${responseData.keys}',
            );
          }

          final authResponse = AuthResponse.fromJson(responseData);

          print('🎫 Token: ${authResponse.token}');
          print('👤 ID: ${authResponse.id}'); // 🔥 'id' et non 'userId'
          print('📧 Email: ${authResponse.email}');

          // Sauvegarde dans SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(Constants.authTokenKey, authResponse.token);
          await prefs.setInt(
            Constants.userIdKey,
            authResponse.id,
          ); // 🔥 Stocke la valeur 'id' sous la clé 'userIdKey'
          await prefs.setString(Constants.userEmailKey, authResponse.email);

          print('💾 Données sauvegardées dans SharedPreferences');

          // Sauvegarde supplémentaire dans Hive
          try {
            final localDb = LocalDbService();
            await localDb.saveAuthData(
              Constants.authTokenKey,
              authResponse.token,
            );
            await localDb.saveAuthData(
              Constants.userIdKey,
              authResponse.id,
            ); // 🔥 Même chose ici
            await localDb.saveAuthData(
              Constants.userEmailKey,
              authResponse.email,
            );
            print('💾 Données sauvegardées dans Hive');
          } catch (e) {
            print('⚠️ Erreur Hive (non critique): $e');
          }

          return authResponse;
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          throw Exception('Erreur de format de la réponse serveur: $e');
        }
      } else if (response.statusCode == 401) {
        print('❌ Erreur 401: Email ou mot de passe incorrect');
        throw Exception('Email ou mot de passe incorrect');
      } else {
        print('❌ Erreur HTTP ${response.statusCode}');
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  Future<AuthResponse> register(
    String email,
    String password, {
    String role = 'USER',
  }) async {
    final url = Uri.parse(
      '${Constants.apiBaseUrl}${Constants.registerEndpoint}',
    );

    // 🔥 Utilisation correcte de RegisterRequest
    final registerRequest = RegisterRequest(
      email: email,
      password: password,
      role: role,
    );

    print('📝 === TENTATIVE D\'INSCRIPTION ===');
    print('🌐 URL: $url');

    final jsonBody = json.encode(registerRequest.toJson());
    print('📦 JSON Body: $jsonBody');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      print('📊 Réponse reçue: ${response.statusCode}');
      print('📄 Body de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Inscription réussie!');

        try {
          final responseData = json.decode(response.body);
          final authResponse = AuthResponse.fromJson(responseData);

          // Sauvegarde dans SharedPreferences ET Hive
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(Constants.authTokenKey, authResponse.token);
          await prefs.setInt(Constants.userIdKey, authResponse.id);
          await prefs.setString(Constants.userEmailKey, authResponse.email);

          // Sauvegarde supplémentaire dans Hive
          final localDb = LocalDbService();
          await localDb.saveAuthData(
            Constants.authTokenKey,
            authResponse.token,
          );
          await localDb.saveAuthData(Constants.userIdKey, authResponse.id);
          await localDb.saveAuthData(
            Constants.userEmailKey,
            authResponse.email,
          );

          return authResponse;
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse d\'inscription: $e');
          throw Exception('Erreur de format de la réponse serveur');
        }
      } else if (response.statusCode == 400) {
        print('❌ Erreur 400: Utilisateur existe déjà');
        throw Exception('Un utilisateur avec cet email existe déjà');
      } else {
        print('❌ Erreur HTTP ${response.statusCode} lors de l\'inscription');
        throw Exception('Erreur d\'inscription: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.authTokenKey);
      await prefs.remove(Constants.userIdKey);
      await prefs.remove(Constants.userEmailKey);

      // Nettoyage supplémentaire dans Hive
      final localDb = LocalDbService();
      await localDb.removeAuthData(Constants.authTokenKey);
      await localDb.removeAuthData(Constants.userIdKey);
      await localDb.removeAuthData(Constants.userEmailKey);

      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      // Vérification dans SharedPreferences d'abord
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.authTokenKey);

      // Fallback sur Hive si nécessaire
      if (token == null) {
        final localDb = LocalDbService();
        final hiveToken = await localDb.getAuthData(Constants.authTokenKey);
        return hiveToken != null && hiveToken.toString().isNotEmpty;
      }

      return token.isNotEmpty;
    } catch (e) {
      print('❌ Erreur lors de la vérification de connexion: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      // SharedPreferences d'abord
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.authTokenKey);

      if (token == null) {
        // Fallback sur Hive
        final localDb = LocalDbService();
        return await localDb.getAuthData(Constants.authTokenKey) as String?;
      }

      return token;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<int?> getUserId() async {
    try {
      // SharedPreferences d'abord
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(Constants.userIdKey);

      if (userId == null) {
        // Fallback sur Hive
        final localDb = LocalDbService();
        final hiveUserId = await localDb.getAuthData(Constants.userIdKey);
        return hiveUserId is int
            ? hiveUserId
            : int.tryParse(hiveUserId.toString());
      }

      return userId;
    } catch (e) {
      print('❌ Erreur lors de la récupération de l\'ID utilisateur: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      // SharedPreferences d'abord
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString(Constants.userEmailKey);

      if (userEmail == null) {
        // Fallback sur Hive
        final localDb = LocalDbService();
        return await localDb.getAuthData(Constants.userEmailKey) as String?;
      }

      return userEmail;
    } catch (e) {
      print('❌ Erreur lors de la récupération de l\'email: $e');
      return null;
    }
  }
}
