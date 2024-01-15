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
  group("Get Username - ", () {
    test("Ensure a non-manager cannot use this API", () {
      expect(() async {
        final TokenFactory tokenFactory = DebugTokenFactory(userUid: "KWDrzf0BNIaHJidKU7PsXGMtvXz2");
        final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
        await client.getUsername("KWDrzf0BNIaHJidKU7PsXGMtvXz2");
      }, throwsA(isA<Exception>()));
    });
  test("Ensure that this API cannot be used against a non-tech", () {
    expect(() async {
      final TokenFactory tokenFactory = DebugTokenFactory(userUid: "SJI1aJvXeWZYNvDyjPfP6LkhT3D3");
      final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
      await client.getUsername("MEswuQpkqZMKm5fUuvlPkzqlLex1");
    }, throwsA(isA<Exception>()));
  });
  test("Recieve the correct username when sending a valid request", () async {
    final TokenFactory tokenFactory = DebugTokenFactory(userUid: "SJI1aJvXeWZYNvDyjPfP6LkhT3D3");
    final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
    final username = await client.getUsername("KWDrzf0BNIaHJidKU7PsXGMtvXz2");
    if (username != "DemoUploader") {
      throw Exception("Invalid username recieved!");
    }
  });
  });
}

