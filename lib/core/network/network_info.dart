import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this.connectivity, this.dio);

  final Connectivity connectivity;
  final Dio dio;

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();

      // Check for standard connectivity types
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.vpn) ||
          result.contains(ConnectivityResult.ethernet)) {
        return true;
      }

      try {
        final response = await dio.get(
          'https://www.google.com',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            followRedirects: false,
          ),
        );
        return response.statusCode == 200;
      } catch (_) {
        return false;
      }
    } catch (_) {
      // If connectivity check fails, assume connected and let the actual request handle errors
      return true;
    }
  }
}
