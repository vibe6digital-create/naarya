import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String error) onError,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        String message;
        switch (e.code) {
          case 'invalid-phone-number':
            message = 'Invalid phone number. Please check and try again.';
            break;
          case 'too-many-requests':
            message = 'Too many requests. Please try again later.';
            break;
          case 'quota-exceeded':
            message = 'SMS quota exceeded. Please try again later.';
            break;
          default:
            message = e.message ?? 'Verification failed. Please try again.';
        }
        onError(message);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  static Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  static Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    return await _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
