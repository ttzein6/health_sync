import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/models/user.dart';

import 'package:health_sync/repositories/auth_repository.dart';
import 'package:health_sync/services/auth_service.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  User? user;
  AuthBloc(this.authRepository) : super(AuthState()) {
    on<SetActiveUser>((event, emit) async {
      user = event.user;
      emit(AuthState(user: user));
    });

    on<AppStarted>((event, emit) async {
      var authUser = FirebaseAuth.instance.currentUser;
      user = await Auth.getUserById(authUser?.uid);

      emit(AuthState(user: user));
    });
  }
}
