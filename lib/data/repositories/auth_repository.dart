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

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _log('AUTH', 'signUpWithEmail → $email');
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _log('AUTH', 'signUp SUCCESS → uid: ${result.user?.uid}');
    return result;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _log('AUTH', 'signInWithEmail → $email');
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _log('AUTH', 'signIn SUCCESS → uid: ${result.user?.uid}');
    return result;
  }

  Future<void> sendPasswordReset(String email) async {
    _log('AUTH', 'sendPasswordReset → $email');
    await _auth.sendPasswordResetEmail(email: email);
    _log('AUTH', 'sendPasswordReset → SUCCESS');
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
