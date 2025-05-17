class AuthException implements Exception {
  static const Map<String, String> errors = {
    'email-already-in-use': 'Este e-mail já está em uso',
    'invalid-email': 'E-mail inválido',
    'weak-password': 'Senha muito fraca',
    'invalid-credential': 'Verifique seu e-mail e senha',
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? 'Erro inesperado: $key';
  }
}
