// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';

// class LocalAuthApi {
//   static final _auth = LocalAuthentication();

//   static Future<bool> _canAuthenticate() async =>
//       await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

//   static Future<bool> authenticate() async {
//     try {
//       if (!await _canAuthenticate()) return false;

//       return await _auth.authenticate(
//           localizedReason: 'Use fingerprint to authenticate',
//           options: const AuthenticationOptions(
//               stickyAuth: true, useErrorDialogs: true));
//     } catch (e) {
//       debugPrint('error $e');
//       return false;
//     }
//   }
// }
