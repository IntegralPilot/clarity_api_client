import 'package:test/test.dart';

import 'package:clarity_api_client/clarity_api_client.dart';

// Before running these tests, please start a local debug-mode server of ClarityAPI on localhost:3000

void main() {
  group("Heartbeat -", () {
    test('Send a heartbeat', () async {
    final client = ClarityAPIClient();
    final result = await client.heartbeat();
    if (!result) {
      throw Exception("Heartbeat was not successful.");
    }
  });
  test('Send a heartbeat to custom server', () async {
    final client = ClarityAPIClient(endpoint: "clarity-api-clarity-screen.vercel.app");
    final result = await client.heartbeat();
    if (!result) {
        throw Exception("Heartbeat was not successful.");
    }
  });
  });
  group("Get Lab Name -", () {
    test("Ensure debug bypass is not supported on the production server", () async {
      expect(() async {
        final TokenFactory tokenFactory = DebugTokenFactory(userUid: "KWDrzf0BNIaHJidKU7PsXGMtvXz2");
        final client = ClarityAPIClient(tokenFactory: tokenFactory);
        await client.getLabName();
      }, throwsA(isA<Exception>()));
    });
    test("Recieve the correct lab name when sending a valid request", () async {
      final TokenFactory tokenFactory = DebugTokenFactory(userUid: "KWDrzf0BNIaHJidKU7PsXGMtvXz2");
      final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
      final labName = await client.getLabName();
      if (labName != "Clarity Testing Lab") {
        throw Exception("Invalid lab name recieved!");
      }
    });
  });
}
