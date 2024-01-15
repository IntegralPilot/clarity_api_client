library clarity_api_client;

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

abstract class TokenFactory {
  Future<String> generateUniqueUsid() async {
    return "";
  }

  String getUid() {
    return "";
  }
}

/// A token factory that works on ClarityAPI instances running in deubg mode.
/// Will **not** work on any publically avaliable/production ClarityAPI instance.
/// Supports initalization with an *optional* userUid. Not providing a UID will not work for some APIs that access a user's own data.
class DebugTokenFactory implements TokenFactory {
  String? userUid;

  Future<String> generateUniqueUsid() async {
    return "DEVELOPMENT_VERIFICATION_BYPASS_TOKEN___";
  }

  String getUid() {
    if (userUid == null) {
      return "DEVELOPMENT_VERIFICATION_BYPASS_UID___";
    } else {
      return userUid!;
    }
  }

  DebugTokenFactory({this.userUid});
}

/// A factory (producer) for Clarity USID tokens. Completely de-coupled from the Firebase API, initalization simply requires implementation of setDocFieldArrayUnion and getCurUserUid
/// 
/// # Initalization
/// ```dart
/// final factory = FirebaseTokenFactory(setDocFieldArrayUnion: myImplOfThisFunction, getCurUserUid: myImplOfThisFunction2);
/// ```
class FirebaseTokenFactory implements TokenFactory {
  /// A function that sets a field of a given document in a given colletion by unionising the existing values and the provided List<String>
  final Future<void> Function(String collection, String document, String field, List<String> itemsToUnionise) setDocFieldArrayUnion;

  /// A function that returns the current userId of the signed-in user.
  /// Can throw an exception if user is not signed in.
  final String Function() getCurUserUid;

  /// A [Uuid] instance used by this factor
  final uuidIstance = Uuid();

  /// A function to produce a single-use usid for the currently signed-in user.
  Future<String> generateUniqueUsid() async {
    final usid = uuidIstance.v4();
    final uid = getCurUserUid();
    await setDocFieldArrayUnion("uploadSessions", uid, "uploadSessionTokens", [usid]);
    return usid;
  }

  /// A function to get the current uid of the signed in user. Calls the function provided to the getCurUserUid at initalization-time.
  String getUid() {
    return getCurUserUid();
  }

  FirebaseTokenFactory({required this.setDocFieldArrayUnion, required this.getCurUserUid});
}

/// The ClarityAPI Client Class, used to initialize requests. This class caches fetch results and uses a common endpoint.
/// 
/// # Initialization
/// ```dart
/// // init with the default endpoint
/// final client = ClarityAPIClient();
/// 
/// // init with a custom endpoint. Must support HTTPS protocol (HTTP is allowed, but only on localhost:3000). Exclude https:// and terminating /
/// final client = ClarityAPIClient(endpoint: "path.to.my.custom.endpoint");
/// 
/// // init with a FirebaseTokenFactory
/// final client = ClarityAPIClient(tokenFactory: myFirebaseTokenFactory);
/// ```
class ClarityAPIClient {
  /// The endpoint to send requests to, defaults to the official ClarityAPI instance.
  final String endpoint;

  /// The dio handle for the instance
  final dio = Dio();

  /// A [TokenFactory] used for generating usid tokens in order to authorise requests to the API.
  /// Optional - however - if you use an API besides the `heartbeat` API you *must* provide this otherwise requests will fail.
  final TokenFactory? tokenFactory;

  /// Returns the address of the endpoint, including protocol & port if applicable.
  String getEndpointBaseAddress() {
    if (endpoint == "localhost:3000") {
      return "http://$endpoint";
    } else {
      return "https://$endpoint";
    }
  }

  ClarityAPIClient({this.tokenFactory, this.endpoint = "clarityapi.vercel.app"});

  /// Send a heartbeat to confirm that the server is working
  Future<bool> heartbeat() async {
    final formData = FormData.fromMap({
      "cgA": "Please don't spoof requests to ClarityAPI. Really, it's way uncool."
    });
    final endpointAddress = getEndpointBaseAddress();
    final response = await dio.post("$endpointAddress/api/heartbeatReciever", data: formData);
    if (response.statusCode != 200) {
      return false;
    }
    final data = response.data['glug'];
    if (data != "glug") {
      return false;
    }
    return true;
  } 

  /// Get the name of the lab that the currently signed-in user belongs to.
  /// Will throw errors if requirements are not met or if the server is down.
  /// Throws non-specific errors if using the production instance of ClarityAPI.
  /// 
  /// # Requirements
  /// The user *must* be a LabManager, LabUploader or LabPending.
  /// A [TokenFactory] *must* be be provided to this class.
  Future<String> getLabName() async {
    final userId = tokenFactory!.getUid();
    final usid = await tokenFactory!.generateUniqueUsid();
    final formData = FormData.fromMap({
      "cgA": "Please don't spoof requests to ClarityAPI. Really, it's way uncool.",
      "uid": userId,
      "usid": usid
    });
    final endpointAddress = getEndpointBaseAddress();
    final response = await dio.post("$endpointAddress/api/enrolledLabNameResolver", data: formData);
    final data = response.data;
    if (response.statusCode != 200) {
      throw new Exception(data["error"]);
    }
    return data["labName"];
  }

  /// Get the username of a given user.
  /// Will throw errors if requirements are not met or if the server is down.
  /// Throws non-specific errors if using the production instance of ClarityAPI.
  /// 
  /// # Requirements
  /// The user *must* be a LabManager.
  /// A [TokenFactory] *must* be provided to this class.
  Future<String> getUsername(String usernameOf) async {
    final userId = tokenFactory!.getUid();
    final usid = await tokenFactory!.generateUniqueUsid();
    final formData = FormData.fromMap({
      "cgA": "Please don't spoof requests to ClarityAPI. Really, it's way uncool.",
      "uid": userId,
      "usid": usid,
      "ruid": usernameOf
    });
    final endpointAddress = getEndpointBaseAddress();
    final response = await dio.post("$endpointAddress/api/userNameResolver", data: formData);
    final data = response.data;
    if (response.statusCode != 200) {
      throw new Exception(data["error"]);
    }
    return data["username"];
  }
}
