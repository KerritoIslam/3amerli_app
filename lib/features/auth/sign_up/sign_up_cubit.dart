import 'package:bloc/bloc.dart';
import 'package:amerli_app/features/auth/repository/auth_repository_impl.dart';
import 'sign_up_state.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_event.dart';
import 'package:amerli_app/core/config/injection.dart' show sl;
import 'package:amerli_app/features/auth/domain/entities/supermarket.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepositoryImpl repository;

  SignUpCubit({required this.repository}) : super(const SignUpState());

  void setPhoneNumber(String phone) {
    if (phone.trim().isEmpty) {
      emit(state.copyWith(status: VerificationStatus.noNumberEntered, phoneNumber: ''));
      return;
    }
    emit(state.copyWith(phoneNumber: phone, status: VerificationStatus.pending));
  }

  void setCountryCode(String code) {
    emit(state.copyWith(countryCode: code));
  }

  Future<void> sendCode() async {
    
    if (state.phoneNumber.trim().isEmpty) {
      emit(state.copyWith(status: VerificationStatus.noNumberEntered));
      return;
    }
    emit(state.copyWith(status: VerificationStatus.loading, errorMessage: null));
    try {
      
      await repository.sendOtp(state.phoneNumber);
      
      emit(state.copyWith(status: VerificationStatus.enteringOtp));
      print("111");
      print(state.status);
    } catch (e) {
      emit(state.copyWith(status: VerificationStatus.pending, errorMessage: 'Failed to send code'));
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.trim().length < 4) {
      emit(state.copyWith(errorMessage: 'Code invalide'));
      return;
    }
    emit(state.copyWith(status: VerificationStatus.loading, errorMessage: null));
    try {
      final isRegistered = await repository.validateOtp(state.phoneNumber, otp);
      print("Is Registered : $isRegistered");
      
      // If registered, read cached user and dispatch login event
      if (isRegistered) {
        final userModel = await repository.readCachedUser();
        print("User Model ${userModel}");
        if (userModel != null) {
          
          final userEntity = userModel.toEntity();
          final authBloc = sl<AuthBloc>();
          if (userEntity.role == 'SUPERMARKET') {
            authBloc.add(LogInEvent(Supermarket.fromUser(userEntity)));
          } else {
            authBloc.add(LogInEvent(userEntity));
          }
        }
        emit(state.copyWith(status: VerificationStatus.verified, result: AuthResult.existingUser));
      } else {
        emit(state.copyWith(status: VerificationStatus.verified, result: AuthResult.newUser));
      }
      print("Verification result: ${state.result}");
    } catch (e) {
      emit(state.copyWith(status: VerificationStatus.enteringOtp, errorMessage: 'Vérification échouée'));
    }
  }

  Future<void> registerProfile(Map<String, dynamic> profile) async {
    emit(state.copyWith(status: VerificationStatus.loading, errorMessage: null));
    try {
      await repository.register(profile);
      // After registration complete, read cached user and dispatch login
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
      emit(state.copyWith(status: VerificationStatus.verified, result: AuthResult.existingUser));
    } catch (e) {
      emit(state.copyWith(status: VerificationStatus.pending, errorMessage: 'Échec de l\'enregistrement'));
    }
  }

  void reset() {
    emit(const SignUpState());
  }
}
