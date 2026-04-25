/// Sealed failure hierarchy for the Either<Failure, T> error pattern.
/// Never throw raw exceptions above the repository layer.
/// Use fpdart's Either: Left(DatabaseFailure()) or Right(data).
library;

sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'A database error occurred.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache read/write failed.']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network request failed.']);
}

final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({
    String message = 'Server returned an error.',
    this.statusCode,
  }) : super(message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
