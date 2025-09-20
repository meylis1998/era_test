import 'dart:math';

class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() function, {
    int maxAttempts = 3,
    Duration baseDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (true) {
      try {
        attempts++;
        return await function();
      } catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }

        final delay = Duration(
          milliseconds: (baseDelay.inMilliseconds * pow(2, attempts - 1)).round(),
        );

        await Future.delayed(delay);
      }
    }
  }
}