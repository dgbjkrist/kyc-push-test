part of 'kyc_cubit.dart';

@immutable
sealed class KycState {}

final class KycStateInitial extends KycState {}

final class KycStateLoading extends KycState {}

final class KycStateSuccess extends KycState {}

final class KycStateError extends KycState {
  final String message;
  KycStateError(this.message);
}