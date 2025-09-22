part of 'kyc_list_cubit.dart';

@immutable
sealed class KycListState {}

final class KycListStateInitial extends KycListState {}
final class KycListStateLoading extends KycListState {}
final class KycListStateLoaded extends KycListState {
  final List<Customer> customers;

      KycListStateLoaded({required this.customers});

  KycListStateLoaded copyWith({
    List<Customer>? customers,
    bool? hasMore}) => KycListStateLoaded(
    customers: customers ?? this.customers,
  );
}

final class KycListStateError extends KycListState {
  final String message;
  KycListStateError(this.message);
}