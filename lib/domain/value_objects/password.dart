class Password {
  final String value;

  const Password(this.value);

  bool get isValid => value.length >= 6;

  String? get error {
    if (value.isEmpty) return "Password is required";
    if (!isValid) return "Password is invalid";
    return null;
  }
}
