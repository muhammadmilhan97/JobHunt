import 'package:flutter/material.dart';
import '../../models/result.dart';
import 'loading_overlay.dart';
import 'error_view.dart';
import 'empty_state.dart';

/// A widget that builds different UI based on Result state
class ResultBuilder<T> extends StatelessWidget {
  final Result<T> result;
  final Widget Function(T data) onSuccess;
  final Widget Function(String message, Object? error)? onError;
  final Widget Function()? onLoading;
  final Widget Function()? onEmpty;
  final bool Function(T data)? isEmpty;

  const ResultBuilder({
    super.key,
    required this.result,
    required this.onSuccess,
    this.onError,
    this.onLoading,
    this.onEmpty,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return result.when(
      success: (data) {
        if (isEmpty?.call(data) ?? false) {
          return onEmpty?.call() ?? const SizedBox.shrink();
        }
        return onSuccess(data);
      },
      failure: (message, error) {
        return onError?.call(message, error) ??
            ErrorView(
              message: message,
              onRetry: () {
                // TODO: Add retry functionality
              },
            );
      },
      loading: () {
        return onLoading?.call() ?? const LoadingSpinner();
      },
    );
  }
}

/// A widget that builds a list based on Result<List<T>> state
class ResultListBuilder<T> extends StatelessWidget {
  final Result<List<T>> result;
  final Widget Function(List<T> items) onSuccess;
  final Widget Function(String message, Object? error)? onError;
  final Widget Function()? onLoading;
  final Widget Function()? onEmpty;
  final bool Function(List<T> items)? isEmpty;

  const ResultListBuilder({
    super.key,
    required this.result,
    required this.onSuccess,
    this.onError,
    this.onLoading,
    this.onEmpty,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return result.when(
      success: (items) {
        if (isEmpty?.call(items) ?? items.isEmpty) {
          return onEmpty?.call() ?? const SizedBox.shrink();
        }
        return onSuccess(items);
      },
      failure: (message, error) {
        return onError?.call(message, error) ??
            ErrorView(
              message: message,
              onRetry: () {
                // TODO: Add retry functionality
              },
            );
      },
      loading: () {
        return onLoading?.call() ?? const LoadingSpinner();
      },
    );
  }
}

/// A widget that builds a single item based on Result<T?> state
class ResultItemBuilder<T> extends StatelessWidget {
  final Result<T?> result;
  final Widget Function(T data) onSuccess;
  final Widget Function(String message, Object? error)? onError;
  final Widget Function()? onLoading;
  final Widget Function()? onEmpty;

  const ResultItemBuilder({
    super.key,
    required this.result,
    required this.onSuccess,
    this.onError,
    this.onLoading,
    this.onEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return result.when(
      success: (data) {
        if (data == null) {
          return onEmpty?.call() ?? const SizedBox.shrink();
        }
        return onSuccess(data);
      },
      failure: (message, error) {
        return onError?.call(message, error) ??
            ErrorView(
              message: message,
              onRetry: () {
                // TODO: Add retry functionality
              },
            );
      },
      loading: () {
        return onLoading?.call() ?? const LoadingSpinner();
      },
    );
  }
}
