import 'package:test/test.dart';

import 'package:clarity_api_client/clarity_api_client.dart';

// Before running these tests, please start a local debug-mode server of ClarityAPI on localhost:3000
// Ensure your local clone is up to date with origin/main

bool areMapsEqual(Map map1, Map map2) {
  if (map1.length != map2.length) {
    return false;
  }

  for (var key in map1.keys) {
    if (map2[key] != map1[key]) {
      return false;
    }
  }

  return true;
}

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
  group("Get User Status - ", () {
    test("Recieve the correct user status when sending a valid request", () async {
      final TokenFactory tokenFactory = DebugTokenFactory(userUid: "KWDrzf0BNIaHJidKU7PsXGMtvXz2");
      final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
      final status = await client.getUserStatus();
      if (status != "L.UPLOADER") {
        throw Exception("Invalid user status recieved!");
      }
    });
    });
  group("Confirm Test Existence -", () {
    test("Recieve the correct test existence when sending a valid request", () async {
      final TokenFactory tokenFactory = DebugTokenFactory(userUid: "KWDrzf0BNIaHJidKU7PsXGMtvXz2");
      final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
      final exists = await client.testExists("3451");
      if (!exists) {
        throw Exception("Invalid test existence recieved!");
      }
    });
  });
  group("Get Test -", () {
    test("Recieve an error when attempting with the wrong DOB", () {
    expect(() async {
      final TokenFactory tokenFactory = DebugTokenFactory(userUid: "KWDrzf0BNIaHJidKU7PsXGMtvXz2");
      final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
      await client.fetchTest("3451", "1702270800001");
    }, throwsA(isA<Exception>()));
  });
    test("Recieve the correct test when sending a valid request", () async {
      final TokenFactory tokenFactory = DebugTokenFactory(userUid: "KWDrzf0BNIaHJidKU7PsXGMtvXz2");
      final client = ClarityAPIClient(tokenFactory: tokenFactory, endpoint: "localhost:3000");
      final test = await client.fetchTest("3451", "1702270800000");
      if (!areMapsEqual(test, {
          "checkedIn": true,
          "dataUploaded": true,
          "proteins": "Apolipoprotein E,APOE,0.75;Apolipoprotein D,APOD,0.25;Random Protein,RANDP,0.5;",
          "riskScore": 150,
          "dob": 1702270800000,
          "patientName": "IntegralPilot",
          "prescriberName": "Dr Integral",
          "processingLabName": "ClarityScreen Demo Lab"
      })) {
        throw Exception(test);
      }
    });
});
}

