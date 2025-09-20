class DateOfBirth {
  // YYYY-MM-DD
  final String value;

  const DateOfBirth(this.value);

  bool get isValid {
    try {
      final date = DateTime.parse(value);
      return date.isBefore(DateTime.now().subtract(const Duration(days: 18 * 365)));
    } catch (_) {
      return false;
    }
  }

  String? get error {
    if (value.isEmpty) return 'Date of birth cannot be empty';
    if (!isValid) return 'Date of birth must be in YYYY-MM-DD format';
  }
}