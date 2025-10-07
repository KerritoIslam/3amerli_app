import 'package:equatable/equatable.dart';

enum VerificationStatus { noNumberEntered, pending, loading, enteringOtp, verified }

class SignUpState extends Equatable {
  final VerificationStatus status;
  final String phoneNumber;
  final String countryCode;

  const SignUpState({
    this.status = VerificationStatus.noNumberEntered,
    this.phoneNumber = '',
    this.countryCode = '+213',
  });

  SignUpState copyWith({
    VerificationStatus? status,
    String? phoneNumber,
    String? countryCode,
  }) {
    return SignUpState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  @override
  List<Object?> get props => [status, phoneNumber, countryCode];
}
