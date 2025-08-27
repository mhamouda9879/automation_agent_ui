import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/failure.dart';
import '../../domain/usecases/auth_usecases.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInWithGooglePressed extends AuthEvent {}

class SignInWithEmailPressed extends AuthEvent {
  final String email;
  final String password;

  SignInWithEmailPressed({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailPressed extends AuthEvent {
  final String email;
  final String password;
  final String name;

  SignUpWithEmailPressed({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class SignOutPressed extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final IsAuthenticated isAuthenticated;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signOut,
    required this.getCurrentUser,
    required this.isAuthenticated,
  }) : super(AuthInitial()) {
    on<SignInWithGooglePressed>(_onSignInWithGooglePressed);
    on<SignInWithEmailPressed>(_onSignInWithEmailPressed);
    on<SignUpWithEmailPressed>(_onSignUpWithEmailPressed);
    on<SignOutPressed>(_onSignOutPressed);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithGooglePressed(
    SignInWithGooglePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await signInWithGoogle(NoParams());
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignInWithEmailPressed(
    SignInWithEmailPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await signInWithEmail(SignInParams(
      email: event.email,
      password: event.password,
    ));
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpWithEmailPressed(
    SignUpWithEmailPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await signUpWithEmail(SignUpParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOutPressed(
    SignOutPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await signOut(NoParams());
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await getCurrentUser(NoParams());
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }
}
