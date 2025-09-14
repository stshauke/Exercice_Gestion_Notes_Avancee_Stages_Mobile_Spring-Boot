class AuthRequest {
  final String email;
  final String password;

  AuthRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
      };
}

class AuthResponse {
  final String token;
  final int id;
  final String email;

  AuthResponse({required this.token, required this.id, required this.email});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json["token"],
      id: json["id"],
      email: json["email"],
    );
  }
}
