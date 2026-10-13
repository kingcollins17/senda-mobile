import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senda/core/util/error_util.dart';

void main() {
  group('ToFriendlyMessage', () {
    test('explains socket failures as an internet connection issue', () {
      final message = SocketException('Network is unreachable').toFriendlyMessage();

      expect(message, contains('internet connection'));
      expect(message, isNot(contains('Network is unreachable')));
    });

    test('handles Dio connection errors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      expect(error.toFriendlyMessage(), contains('internet connection'));
    });

    test('uses a readable server message from a Dio response', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {'message': 'Invalid verification code'},
        ),
      );

      expect(error.toFriendlyMessage(), 'Invalid verification code');
    });

    test('removes exception type prefixes from ordinary exceptions', () {
      expect(Exception('Please try again').toFriendlyMessage(), 'Please try again');
    });
  });
}