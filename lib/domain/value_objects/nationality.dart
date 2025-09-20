class Nationality {
  final String value;

  const Nationality(this.value);

  bool get isValid {
    return value.trim().isNotEmpty;
  }

  String? get error => !isValid ? 'Nationality cannot be empty' : null;
}