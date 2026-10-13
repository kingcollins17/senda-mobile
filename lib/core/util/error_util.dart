import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:senda/core/app_strings.dart';

/// Converts common Dart, network, and Dio errors into user-friendly messages.
extension ToFriendlyMessage on Object {
  /// Returns a readable message suitable for showing to a user.
  String toFriendlyMessage() {
    if (this is SocketException) {
      return AppStrings.noInternetConnection;
    }

    if (this is DioException) {
      return _dioFriendlyMessage(this as DioException);
    }

    if (this is TimeoutException) {
      return AppStrings.requestTimedOut;
    }

    if (this is FormatException) {
      return AppStrings.unexpectedResponse;
    }

    final message = _cleanMessage(toString());
    return message.isEmpty ? AppStrings.genericError : message;
  }
}

String _dioFriendlyMessage(DioException error) {
  if (error.error is SocketException) return AppStrings.noInternetConnection;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return AppStrings.requestTimedOutCheckConnection;
    case DioExceptionType.connectionError:
      return AppStrings.noInternetConnection;
    case DioExceptionType.badCertificate:
      return AppStrings.secureConnectionFailed;
    case DioExceptionType.cancel:
      return AppStrings.requestCancelled;
    case DioExceptionType.badResponse:
      final responseMessage = _messageFromResponse(error.response?.data);
      if (responseMessage != null) return responseMessage;

      return switch (error.response?.statusCode) {
        401 => AppStrings.signInAgain,
        403 => AppStrings.permissionDenied,
        404 => AppStrings.informationNotFound,
        429 => AppStrings.tooManyRequests,
        final int statusCode when statusCode >= 500 =>
          AppStrings.serviceUnavailable,
        _ => AppStrings.requestFailed,
      };
    case DioExceptionType.unknown:
      if (error.error is TimeoutException) {
        return AppStrings.requestTimedOut;
      }
      final message = _cleanMessage(error.message ?? '');
      return message.isEmpty ? AppStrings.genericError : message;
  }
}

String? _messageFromResponse(Object? data) {
  if (data is! Map) return null;

  for (final key in const ['message', 'detail', 'error']) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return _cleanMessage(value);
    }
    if (value is Map) {
      final nestedMessage = _messageFromResponse(value);
      if (nestedMessage != null) return nestedMessage;
    }
  }

  return null;
}

String _cleanMessage(String value) {
  final message = value.trim().replaceFirst(
    RegExp(
      r'^(?:[A-Za-z][A-Za-z0-9_]*Exception|Exception|[A-Za-z][A-Za-z0-9_]*Error|Error):\s*',
    ),
    '',
  );
  return message.trim();
}
