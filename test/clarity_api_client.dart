import 'package:test/test.dart';

import 'package:clarity_api_client/clarity_api_client.dart';

void main() {
  group("Heartbeat", () {
    test('Send a heartbeat', () {
    final client = ClarityAPIClient();
    Future.microtask(() async {
      final result = await client.heartbeat();
      if (!result) {
        throw Exception("Heartbeat was not successful.");
      }
    });
  });
  test('Send a heartbeat to custom server', () {
    final client = ClarityAPIClient(endpoint: "https://clarity-api-clarity-screen.vercel.app/");
    Future.microtask(() async {
      final result = await client.heartbeat();
      if (!result) {
        throw Exception("Heartbeat was not successful.");
      }
    });
  });
  });
}
