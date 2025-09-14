class Constants {
  // Pour Android Emulator, 10.0.2.2 pointe vers ton PC hôte
  static const String apiBaseUrl = 'http://10.0.2.2:8080/api/v1/auth';
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';

  // 🔹 Ajoute l'URL des notes
  static const String notesUrl = 'http://10.0.2.2:8080/api/v1/notes';

  // 🔥 Clés pour stockage local
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
}
