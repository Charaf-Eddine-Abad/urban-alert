import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Default state — no action in progress.
final class AuthIdle extends AuthState {
  const AuthIdle();
}

/// An async operation (login / register / verify) is in flight.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Login or verifyPhone succeeded — token is already persisted in storage.
/// The router reacts to [isAuthenticatedProvider] changing and navigates.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

/// Register succeeded — OTP sent; we move to the verify-phone screen.
final class AuthRegistered extends AuthState {
  const AuthRegistered(this.normalizedPhone);

  /// The +212... phone the OTP was sent to. Passed to verify-phone screen.
  final String normalizedPhone;

  @override
  List<Object?> get props => [normalizedPhone];
}

/// An error that should be shown to the user.
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
