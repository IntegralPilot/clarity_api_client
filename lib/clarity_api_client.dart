library clarity_api_client;

import 'package:dio/dio.dart';

/// The ClarityAPI Client Class, used to initialize requests. This class caches fetch results and uses a common endpoint.
/// 
/// # Initialization
/// ```dart
/// // init with the default endpoint
/// final client = ClarityAPIClient();
/// 
/// // init with a custom endpoint. Must support HTTPS protocol. Exclude https:// and terminating /.
/// final client = ClarityAPIClient(endpoint: "path.to.my.custom.endpoint");
/// ```
class ClarityAPIClient {
  /// The endpoint to send requests to, defaults to the official ClarityAPI instance.
  final String endpoint;

  /// The dio handle for the instance
  final dio = Dio();

  ClarityAPIClient({this.endpoint = "clarityapi.vercel.app"});

  /// Send a heartbeat to confirm that the server is working
  Future<bool> heartbeat() async {
    final formData = FormData.fromMap({
      "cgA": "Please don't spoof requests to ClarityAPI. Really, it's way uncool."
    });
    final response = await dio.post("https://$endpoint/api/heartbeatReciever", data: formData);
    if (response.statusCode != 200) {
      return false;
    }
    final data = response.data['glug'];
    if (data != "glug") {
      return false;
    }
    return true;
  }
}
