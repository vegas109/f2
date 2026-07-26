/// A tiny [Result] type for representing success/failure without throwing
/// across layers. Keeps services testable and UI code exhaustive.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Returns the value on success, or null on failure.
  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  R when<R>({
    required R Function(T value) success,
    required R Function(String message, Object? error) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.value);
    self as Failure<T>;
    return failure(self.message, self.error);
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.message, [this.error]);
  final String message;
  final Object? error;
}
