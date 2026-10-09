import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo;

  AuthCubit(this._authRepo) : super(AuthInitial());

  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  Future<void> checkAuthStatus() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final profile = await _authRepo.getUserProfile(user.uid);
      if (profile != null && profile.name.isNotEmpty) {
        _userProfile = profile;
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthNeedsProfile());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AuthLoading());
    try {
      final result = await _authRepo.signUpWithEmail(
        email: email,
        password: password,
      );
      final user = result.user!;
      final profile = UserModel(
        uid: user.uid,
        phone: '',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      await _authRepo.createUserProfile(profile);
      _userProfile = profile;
      emit(AuthAuthenticated(profile));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapAuthError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final result = await _authRepo.signInWithEmail(
        email: email,
        password: password,
      );
      final user = result.user!;
      final profile = await _authRepo.getUserProfile(user.uid);
      if (profile != null && profile.name.isNotEmpty) {
        _userProfile = profile;
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthNeedsProfile());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapAuthError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authRepo.sendPasswordReset(email);
      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapAuthError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> completeProfile({
    required String name,
    required String email,
  }) async {
    emit(AuthLoading());
    try {
      final user = _authRepo.currentUser!;
      final profile = UserModel(
        uid: user.uid,
        phone: '',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      await _authRepo.createUserProfile(profile);
      _userProfile = profile;
      emit(AuthAuthenticated(profile));
    } catch (e) {
      emit(AuthError('Failed to save profile'));
    }
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (_userProfile == null) return;
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      await _authRepo.updateUserProfile(_userProfile!.uid, updates);
      _userProfile = _userProfile!.copyWith(name: name, email: email);
      emit(AuthAuthenticated(_userProfile!));
    } catch (e) {
      emit(AuthError('Failed to update profile'));
    }
  }

  Future<void> refreshProfile() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final profile = await _authRepo.getUserProfile(user.uid);
      if (profile != null) {
        _userProfile = profile;
        emit(AuthAuthenticated(profile));
      }
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _userProfile = null;
    emit(AuthUnauthenticated());
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
