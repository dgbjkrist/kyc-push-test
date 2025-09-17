class User {
  final String id;
  final String email;
  final String password;

  User({
    required this.id,
    required this.email,
    required this.password,
  });

  factory User.empty() {
    return User(
      id: '',
      email: '',
      password: '',
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}