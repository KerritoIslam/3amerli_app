import 'package:equatable/equatable.dart';

enum VerificationStatus { noNumberEntered, pending, loading, enteringOtp, verified }

enum AuthResult { none, existingUser, newUser }

class SignUpState extends Equatable {
  final VerificationStatus status;
  final String phoneNumber;
  final String countryCode;
  final AuthResult result;
  final String? errorMessage;

  const SignUpState({
    this.status = VerificationStatus.noNumberEntered,
    this.phoneNumber = '',
    this.countryCode = '+213',
    this.result = AuthResult.none,
    this.errorMessage,
  });

  SignUpState copyWith({
    VerificationStatus? status,
    String? phoneNumber,
    String? countryCode,
    AuthResult? result,
    String? errorMessage,
  }) {
    return SignUpState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, phoneNumber, countryCode, result, errorMessage];
}
