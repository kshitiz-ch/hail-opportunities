import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

// Fired just after the app is launched
class AppLoadedup extends AuthenticationEvent {}

class CheckForUpdate extends AuthenticationEvent {}

class UserLogOut extends AuthenticationEvent {
  final bool showLogoutMessage;

  UserLogOut({this.showLogoutMessage = false});

  @override
  List<Object> get props => [showLogoutMessage];
}

class LoginHalfAgent extends AuthenticationEvent {
  final String apiKey;
  final int agentId;

  LoginHalfAgent({required this.apiKey, required this.agentId});

  @override
  List<Object> get props => [apiKey, agentId];
}

class UserSignIn extends AuthenticationEvent {
  final String email;
  final String? password;
  final String? fcmToken;
  UserSignIn({required this.email, this.password, this.fcmToken});

  @override
  List<Object?> get props => [email, password];
}

class UserSignInPhoneNumber extends AuthenticationEvent {
  final String phoneNumber;
  final String? otp;
  final String? fcmToken;
  UserSignInPhoneNumber({required this.phoneNumber, this.otp, this.fcmToken});

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class SendOtpEvent extends AuthenticationEvent {
  final String phoneNumber;
  SendOtpEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class ReSendOtpEvent extends AuthenticationEvent {
  final String phoneNumber;
  ReSendOtpEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class UserGoogleSignIn extends AuthenticationEvent {}

class UserForgotPassword extends AuthenticationEvent {
  final String email;
  UserForgotPassword({required this.email});

  @override
  List<Object> get props => [email];
}

class UserLocalAuth extends AuthenticationEvent {
  final String passcode;

  UserLocalAuth({required this.passcode});

  @override
  List<Object> get props => [passcode];
}

class ResetAuthentication extends AuthenticationEvent {}
