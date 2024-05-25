part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SetActiveUser extends AuthEvent {
  final User user;
  SetActiveUser({required this.user});
}

class AppStarted extends AuthEvent {}
