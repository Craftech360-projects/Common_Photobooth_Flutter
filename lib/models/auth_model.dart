class AuthResponse {
  final bool success;
  final String? message;

  AuthResponse({
    required this.success,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}
