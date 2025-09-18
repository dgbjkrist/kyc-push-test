class KycUser {
  final String id;
  final String fullName;
  final String faceUrl;
  final String cardRectoUrl;
  final String cardVersoUrl;
  final String dob;
  final String country;

  const KycUser({
    required this.id,
    required this.fullName,
    required this.faceUrl,
    required this.cardRectoUrl,
    required this.cardVersoUrl,
    required this.dob,
    required this.country,
  });
}