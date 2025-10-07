import 'package:bloc/bloc.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(const SignUpState());

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

  /// Simulate sending an OTP. In a real app this would call an API.
  Future<void> sendCode() async {
    if (state.phoneNumber.trim().isEmpty) {
      emit(state.copyWith(status: VerificationStatus.noNumberEntered));
      return;
    }
    emit(state.copyWith(status: VerificationStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(status: VerificationStatus.enteringOtp));
  }

  void verifyOtp(String otp) {
    // For demo accept any 4-6 digit code
    if (otp.trim().length >= 4) {
      emit(state.copyWith(status: VerificationStatus.verified));
    }
  }

  void reset() {
    emit(const SignUpState());
  }
}
