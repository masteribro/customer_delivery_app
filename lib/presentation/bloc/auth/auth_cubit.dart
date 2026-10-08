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

  Future<void> sendOtp(String phoneNumber) async {
    emit(AuthLoading());
    try {
      await _authRepo.verifyPhone(
        phoneNumber: phoneNumber,
        onCompleted: (credential) async {
          await _signInWithCredential(credential);
        },
        onFailed: (e) {
          final msg = e.message ?? 'Verification failed';
          // Provide clearer message for common iOS issues
          if (msg.contains('missing') || msg.contains('nil')) {
            emit(const AuthError(
              'Phone auth requires APNs configuration. '
              'Add a test phone number in Firebase Console → Authentication → Phone → Test phone numbers.',
            ));
          } else {
            emit(AuthError(msg));
          }
        },
        onCodeSent: (verificationId, resendToken) {
          emit(AuthCodeSent(verificationId: verificationId, phoneNumber: phoneNumber));
        },
        onCodeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Phone verification failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(AuthLoading());
    try {
      final credential = _authRepo.createCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Invalid code'));
    } catch (e) {
      emit(AuthError('Invalid verification code'));
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final result = await _authRepo.signInWithCredential(credential);
      final user = result.user!;
      final profile = await _authRepo.getUserProfile(user.uid);
      if (profile != null && profile.name.isNotEmpty) {
        _userProfile = profile;
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthNeedsProfile());
      }
    } catch (e) {
      emit(AuthError('Sign in failed'));
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
        phone: user.phoneNumber ?? '',
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
}
