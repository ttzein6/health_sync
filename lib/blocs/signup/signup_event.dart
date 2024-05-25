part of 'signup_bloc.dart';

abstract class SignupEvent {}

class SignupButtonPressed extends SignupEvent {
  final String email;
  final String password;
  final String name;

  SignupButtonPressed(
      {required this.email, required this.password, required this.name});
}
