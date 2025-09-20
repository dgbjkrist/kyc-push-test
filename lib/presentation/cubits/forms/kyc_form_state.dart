part of 'kyc_form_cubit.dart';

@immutable
sealed class KycFormState {}

final class KycFormStateInitial extends KycFormState {}

final class KycFormStateProcessing extends KycFormState {}

final class KycFormStateChanged extends KycFormState {
  final FullName fullName;
  final DateOfBirth dateOfBirth;
  final Nationality nationality;
  final String idType;
  final String faceImagePath;
  final String cardRectoPath;
  final String? cardVersoPath;

  KycFormStateChanged({
    required this.idType,
    required this.fullName,
    required this.dateOfBirth,
    required this.nationality,
    required this.faceImagePath,
    required this.cardRectoPath,
    this.cardVersoPath,
  });

  Kyc toEntity() => Kyc(
    id: const Uuid().v4(),
    idType: idType,
    fullName: fullName,
    dateOfBirth: dateOfBirth,
    nationality: nationality,
    faceImagePath: faceImagePath,
    cardRectoPath: cardRectoPath,
    cardVersoPath: cardVersoPath,
  );

  KycFormStateChanged copyWith({
    FullName? fullName,
    String? idType,
    DateOfBirth? dateOfBirth,
    Nationality? nationality,
    String? faceImagePath,
    String? cardRectoPath,
    String? cardVersoPath,
}) => KycFormStateChanged(
    idType: idType ?? this.idType,
    fullName: fullName ?? this.fullName,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    nationality: nationality ?? this.nationality,
    faceImagePath: faceImagePath ?? this.faceImagePath,
    cardRectoPath: cardRectoPath ?? this.cardRectoPath,
    cardVersoPath: cardVersoPath ?? this.cardVersoPath,
  );
}

final class KycFormStateError extends KycFormState {
  final String message;
  KycFormStateError(this.message);
}