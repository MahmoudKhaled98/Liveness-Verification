/// Base class for all failure cases in the application.
///
/// Provides a common interface for handling errors and failures
/// throughout the application with meaningful messages.
abstract class Failure {
  /// The error message describing the failure.
  final String message;

  /// Creates a new [Failure] instance with the given [message].
  const Failure(this.message);
}

/// Represents failures that occur during server communication.
///
/// Used when API calls fail, network errors occur, or when
/// the server returns unexpected responses.
class ServerFailure extends Failure {
  /// Creates a new [ServerFailure] with the given error [message].
  const ServerFailure(super.message);
}

/// Represents unexpected failures that occur during application execution.
///
/// Used for handling unexpected errors that don't fit into other
/// more specific failure categories.
class UnexpectedFailure extends Failure {
  /// Creates a new [UnexpectedFailure] with the given error [message].
  const UnexpectedFailure(super.message);
}