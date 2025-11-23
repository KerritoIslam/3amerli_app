import 'package:bloc/bloc.dart';
import 'package:amerli_app/features/auth/repository/auth_repository_impl.dart';
import 'sign_up_state.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_event.dart';
import 'package:amerli_app/core/config/injection.dart' show sl;
import 'package:amerli_app/features/auth/domain/entities/supermarket.dart';
import 'package:amerli_app/core/network/api_exception.dart' show ApiException;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepositoryImpl repository;

  SignUpCubit({required this.repository}) : super(const SignUpState());

  void _safeEmit(SignUpState s) {
    if (!isClosed) emit(s);
  }

  void setPhoneNumber(String phone) {
    if (phone.trim().isEmpty) {
      _safeEmit(state.copyWith(
          status: VerificationStatus.noNumberEntered, phoneNumber: ''));
      return;
    }
    _safeEmit(
        state.copyWith(phoneNumber: phone, status: VerificationStatus.pending));
  }

  void setCountryCode(String code) {
    _safeEmit(state.copyWith(countryCode: code));
  }

  Future<void> sendCode() async {
    if (state.phoneNumber.trim().isEmpty) {
      _safeEmit(state.copyWith(status: VerificationStatus.noNumberEntered));
      return;
    }
    _safeEmit(
        state.copyWith(status: VerificationStatus.loading, errorMessage: null));
    try {
      final response = await repository.sendOtp(state.phoneNumber);

      String? otp;
      final mod = dotenv.env['MOD'];
      if (mod == 'dev' || mod == 'test') {
        // Try to find OTP in response
        if (response.containsKey('otp')) {
          otp = response['otp'].toString();
        } else if (response.containsKey('code')) {
          otp = response['code'].toString();
        }
      }

      _safeEmit(
          state.copyWith(status: VerificationStatus.enteringOtp, otp: otp));
    } catch (e) {
      String message = e.toString();
      bool isForbidden = false;
      if (e is ApiException) {
        message = e.message;
        if (e.statusCode == 403) {
          isForbidden = true;
        }
      } else if (message.contains('Exception:')) {
        message = message.replaceAll('Exception:', '').trim();
      }
      _safeEmit(state.copyWith(
          status: VerificationStatus.pending,
          errorMessage: message,
          isForbidden: isForbidden));
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.trim().length < 4) {
      _safeEmit(state.copyWith(errorMessage: 'Code invalide'));
      return;
    }
    _safeEmit(state.copyWith(
        status: VerificationStatus.verifyingOtp, errorMessage: null));
    try {
      final isRegistered = await repository.validateOtp(state.phoneNumber, otp);

      // If registered, read cached user and dispatch login event
      if (isRegistered) {
        final userModel = await repository.readCachedUser();
        if (userModel != null) {
          final userEntity = userModel.toEntity();
          final authBloc = sl<AuthBloc>();
          if (userEntity.role == 'SUPERMARKET') {
            authBloc.add(LogInEvent(Supermarket.fromUser(userEntity)));
          } else {
            authBloc.add(LogInEvent(userEntity));
          }
        }
        _safeEmit(state.copyWith(
            status: VerificationStatus.verified,
            result: AuthResult.existingUser));
      } else {
        _safeEmit(state.copyWith(
            status: VerificationStatus.verified, result: AuthResult.newUser));
      }
    } catch (e) {
      String message = e.toString();
      bool isForbidden = false;
      if (e is ApiException) {
        message = e.message;
        if (e.statusCode == 403) {
          isForbidden = true;
        }
      } else if (message.contains('Exception:')) {
        message = message.replaceAll('Exception:', '').trim();
      }
      _safeEmit(state.copyWith(
          status: VerificationStatus.enteringOtp,
          errorMessage: message,
          isForbidden: isForbidden));
    }
  }

  Future<void> registerProfile(Map<String, dynamic> profile) async {
    _safeEmit(
        state.copyWith(status: VerificationStatus.loading, errorMessage: null));
    try {
      await repository.register(profile);
      // After registration complete, read cached user and dispatch login only if we actually have a user
      final userModel = await repository.readCachedUser();
      if (userModel != null) {
        final userEntity = userModel.toEntity();
        final authBloc = sl<AuthBloc>();
        if (userEntity.role == 'SUPERMARKET') {
          authBloc.add(LogInEvent(Supermarket.fromUser(userEntity)));
        } else {
          authBloc.add(LogInEvent(userEntity));
        }
        _safeEmit(state.copyWith(
            status: VerificationStatus.verified,
            result: AuthResult.existingUser));
      } else {
        // No user saved -> treat as failure
        _safeEmit(state.copyWith(
            status: VerificationStatus.pending,
            errorMessage: 'Échec de l\'enregistrement'));
        throw Exception('Registration did not produce a user');
      }
    } catch (e) {
      // Prefer ApiException message when available
      String err = 'Échec de l\'enregistrement';
      if (e is ApiException) err = e.message;
      _safeEmit(state.copyWith(
          status: VerificationStatus.pending, errorMessage: err));
      rethrow; // rethrow so UI callers (that used .then/.catchError) receive the error
    }
  }

  void reset() {
    _safeEmit(const SignUpState());
  }

  /// Mark that we've started navigating to the profile completion page so
  /// the UI doesn't repeat the navigation on subsequent builds.
  void markCompletingProfile() {
    _safeEmit(state.copyWith(result: AuthResult.completingProfileForSignUp));
  }
}
