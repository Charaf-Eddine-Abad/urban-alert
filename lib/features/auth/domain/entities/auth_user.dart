import 'package:equatable/equatable.dart';

/// The authenticated user as seen by the domain/presentation layer.
/// Derived from the JWT once it is stored — not fetched from a /me endpoint.
class AuthUser extends Equatable {
  const AuthUser({
    required this.phone,
    required this.role,
    required this.userId,
  });

  final String phone;
  final String role;
  final int userId;

  @override
  List<Object> get props => [phone, role, userId];
}
