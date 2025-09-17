class Email {
  final String value;

  const Email(this.value);

  bool get isValid {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return value.isNotEmpty && emailRegex.hasMatch(value);
  }

  String? get error {
    if (value.isEmpty) return "Email required";
    if (value.contains(' ')) {
      return 'Les espaces ne sont pas autorisés dans l\'email';
    }
    if (!value.contains('@')) return 'L\'email doit contenir un @';

    final parts = value.split('@');
    if (parts.length != 2) return 'Un seul @ est autorisé';

    final domainParts = parts.last.split('.');
    if (domainParts.length < 2) {
      return 'Format de domaine invalide (ex: example.com)';
    }

    if (domainParts.last.length < 2) {
      return 'L\'extension doit avoir au moins 2 caractères (ex: .com)';
    }

    if (!isValid) return 'Invalid email format!';
    return null;
  }
}
