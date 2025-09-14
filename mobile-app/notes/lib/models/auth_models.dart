class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String role;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }
}

class AuthResponse {
  final String token;
  final int id;
  final String email;

  AuthResponse({
    required this.token,
    required this.id,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] as String,
    );
  }
}