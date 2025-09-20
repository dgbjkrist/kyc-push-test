class FullName {
  final String value;
  const FullName(this.value);

  bool get isValid {
    return value.trim().split(' ').length >= 2;
  }

  String? get error {
    if (value.trim().isEmpty) return 'Full name cannot be empty';
    if (!isValid) return 'Full name must contain at least 2 parts';
  }

  @override
  String toString() => value;
}