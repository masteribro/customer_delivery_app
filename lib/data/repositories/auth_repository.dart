import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onCompleted,
    required void Function(FirebaseAuthException) onFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String) onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    _log('AUTH', 'verifyPhone → $phoneNumber');
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) {
        _log('AUTH', 'verificationCompleted (auto-resolved)');
        onCompleted(credential);
      },
      verificationFailed: (e) {
        _log('AUTH', 'verificationFailed → ${e.code}: ${e.message}');
        onFailed(e);
      },
      codeSent: (verificationId, resendToken) {
        _log('AUTH', 'codeSent → verificationId: ${verificationId.substring(0, 10)}...');
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (id) {
        _log('AUTH', 'codeAutoRetrievalTimeout');
        onCodeAutoRetrievalTimeout(id);
      },
      forceResendingToken: resendToken,
    );
  }

  Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    _log('AUTH', 'signInWithCredential...');
    final result = await _auth.signInWithCredential(credential);
    _log('AUTH', 'signIn SUCCESS → uid: ${result.user?.uid}');
    return result;
  }

  PhoneAuthCredential createCredential({
    required String verificationId,
    required String smsCode,
  }) {
    _log('AUTH', 'createCredential → code: $smsCode');
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  Future<UserModel?> getUserProfile(String uid) async {
    _log('FIRESTORE', 'GET users/$uid');
    final doc = await _firestore.collection('users').doc(uid).get();
    _log('FIRESTORE', 'GET users/$uid → exists: ${doc.exists}');
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> createUserProfile(UserModel user) async {
    _log('FIRESTORE', 'SET users/${user.uid} → ${user.toMap()}');
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    _log('FIRESTORE', 'SET users/${user.uid} → SUCCESS');
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    _log('FIRESTORE', 'UPDATE users/$uid → $data');
    await _firestore.collection('users').doc(uid).update(data);
    _log('FIRESTORE', 'UPDATE users/$uid → SUCCESS');
  }

  Future<void> signOut() async {
    _log('AUTH', 'signOut');
    await _auth.signOut();
    _log('AUTH', 'signOut → SUCCESS');
  }

  void _log(String tag, String message) {
    dev.log('[$tag] $message', name: 'Kali');
  }
}
