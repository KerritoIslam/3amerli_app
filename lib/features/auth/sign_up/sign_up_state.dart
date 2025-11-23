import 'package:equatable/equatable.dart';

enum VerificationStatus {
  noNumberEntered,
  pending,
  loading,
  enteringOtp,
  verifyingOtp,
  verified
}

enum AuthResult { none, existingUser, newUser, completingProfileForSignUp }

class SignUpState extends Equatable {
  final VerificationStatus status;
  final String phoneNumber;
  final String countryCode;
  final AuthResult result;
  final String? errorMessage;
  final bool isForbidden;
  final String? otp;

  const SignUpState({
    this.status = VerificationStatus.noNumberEntered,
    this.phoneNumber = '',
    this.countryCode = '+213',
    this.result = AuthResult.none,
    this.errorMessage,
    this.isForbidden = false,
    this.otp,
  });

  SignUpState copyWith({
    VerificationStatus? status,
    String? phoneNumber,
    String? countryCode,
    AuthResult? result,
    String? errorMessage,
    bool? isForbidden,
    String? otp,
  }) {
    return SignUpState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      result: result ?? this.result,
      errorMessage: errorMessage,
      isForbidden: isForbidden ?? this.isForbidden,
      otp: otp ?? this.otp,
    );
  }

  @override
  List<Object?> get props => [
        status,
        phoneNumber,
        countryCode,
        result,
        errorMessage,
        isForbidden,
        otp
      ];
}
