// lib/services/auth_service.dart
// ignore_for_file: unused_field, unnecessary_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  String? _verificationId;
  int? _resendToken;
  String? _lastPhoneNumber;
  DateTime? _lastAttemptTime;
  static const int _cooldownSeconds = 30;
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      // Add cooldown check
      if (_lastAttemptTime != null) {
        final timeDiff = DateTime.now().difference(_lastAttemptTime!);
        if (timeDiff.inSeconds < _cooldownSeconds) {
          onError(
              'Please wait ${_cooldownSeconds - timeDiff.inSeconds} seconds before trying again');
          return;
        }
      }

      if (kDebugMode) {
        print('Initiating phone verification for: $phoneNumber');
      }

      _lastPhoneNumber = phoneNumber;
      _lastAttemptTime = DateTime.now();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final result = await _auth.signInWithCredential(credential);
            if (result.user != null) {
              await _saveUserData(result.user!);
            }
            if (kDebugMode) {
              print('Auto verification completed');
            }
          } catch (e) {
            onError(_getReadableError(e));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Verification failed error code: ${e.code}');
            print('Verification failed error message: ${e.message}');
          }
          onError(_getReadableError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent('Verification code sent successfully');
          if (kDebugMode) {
            print('Verification code sent with id: $verificationId');
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          if (kDebugMode) {
            print('Auto retrieval timeout');
          }
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in verifyPhone: $e');
      }
      onError(_getReadableError(e));
    }
  }

  String _getReadableError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'The phone number format is invalid';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'operation-not-allowed':
          return 'Phone authentication is not enabled';
        case 'invalid-verification-code':
          return 'The verification code is invalid';
        case 'invalid-verification-id':
          return 'The verification session has expired';
        case 'network-request-failed':
          return 'Network error. Please check your connection';
        case 'web-context-canceled':
          return 'The verification was canceled. Please try again.';
        case 'missing-app-credential':
          return 'Please complete the reCAPTCHA verification';
        default:
          return error.message ?? 'An unexpected error occurred';
      }
    }
    return error.toString();
  }

  Future<bool> verifyOTP({
    required String otp,
    required Function(String) onError,
  }) async {
    try {
      if (_verificationId == null) {
        onError('Please request verification code first');
        return false;
      }

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      if (kDebugMode) {
        print(_verificationId);
      }
      if (kDebugMode) {
        print(otp);
      }
      // Sign in
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      // Save user data
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!);
        return true;
      } else {
        onError('Failed to sign in');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid verification code';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Invalid verification session. Please try again';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed';
      }
      onError(errorMessage);
      return false;
    } catch (e) {
      onError('Error verifying code: ${e.toString()}');
      return false;
    }
  }

  Future<void> _saveUserData(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'phoneNumber': _lastPhoneNumber,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw 'No authenticated user found';

      await _firestore.collection('users').doc(currentUser.uid).set(
            user.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw 'Failed to save user data: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _lastPhoneNumber = null;
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? get currentPhoneNumber => _lastPhoneNumber;
}
