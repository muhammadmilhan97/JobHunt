import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// A sealed class representing the result of an asynchronous operation
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String message, [Object? error]) = Failure<T>;
  const factory Result.loading() = Loading<T>;

  const Result._();

  /// Check if the result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is Failure<T>;

  /// Check if the result is loading
  bool get isLoading => this is Loading<T>;

  /// Get the data if successful, null otherwise
  T? get data => when(
        success: (data) => data,
        failure: (_, __) => null,
        loading: () => null,
      );

  /// Get the error message if failed, null otherwise
  String? get errorMessage => when(
        success: (_) => null,
        failure: (message, _) => message,
        loading: () => null,
      );
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Get the data or throw an exception if not successful
  T get dataOrThrow => when(
        success: (data) => data,
        failure: (message, error) => throw Exception(message),
        loading: () => throw Exception('Result is still loading'),
      );

  /// Get the data or a default value if not successful
  T dataOr(T defaultValue) => when(
        success: (data) => data,
        failure: (_, __) => defaultValue,
        loading: () => defaultValue,
      );

  /// Execute a function if successful, return the original result otherwise
  Result<T> onSuccess(void Function(T) action) {
    if (isSuccess) {
      action(data!);
    }
    return this;
  }

  /// Execute a function if failed, return the original result otherwise
  Result<T> onFailure(void Function(String, Object?) action) {
    if (isFailure) {
      action(errorMessage!, (this as Failure<T>).error);
    }
    return this;
  }
}

/// Helper functions for creating Results
class ResultHelper {
  /// Create a success result
  static Result<T> success<T>(T data) => Result.success(data);

  /// Create a failure result
  static Result<T> failure<T>(String message, [Object? error]) =>
      Result.failure(message, error);

  /// Create a loading result
  static Result<T> loading<T>() => const Result.loading();

  /// Wrap an async operation in a Result
  static Future<Result<T>> wrap<T>(Future<T> Function() operation) async {
    try {
      final data = await operation();
      return Result.success(data);
    } catch (e) {
      return Result.failure(e.toString(), e);
    }
  }

  /// Wrap an async operation that might throw with custom error handling
  static Future<Result<T>> wrapWithHandler<T>(
    Future<T> Function() operation,
    String Function(Object) errorHandler,
  ) async {
    try {
      final data = await operation();
      return Result.success(data);
    } catch (e) {
      return Result.failure(errorHandler(e), e);
    }
  }
}
