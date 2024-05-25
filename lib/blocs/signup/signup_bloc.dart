import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/repositories/auth_repository.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;
  SignupBloc(this.authRepository) : super(SignupInitial()) {
    on<SignupEvent>((event, emit) async {
      if (event is SignupButtonPressed) {
        emit(SignupLoading());

        try {
          await authRepository.signUp(event.email, event.password, event.name);
          emit(SignupSuccess());
        } catch (e) {
          emit(SignupFailure(error: e.toString()));
        }
      }
    });
  }
}
