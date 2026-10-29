class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server exception']);

  @override
  String toString() => message;
}
