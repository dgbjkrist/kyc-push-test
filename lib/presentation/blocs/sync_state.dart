part of 'sync_bloc.dart';

@immutable
sealed class SyncState {}

final class SyncInitial extends SyncState {}

final class SyncLoading extends SyncState {}

final class SyncSuccess extends SyncState {}

final class SyncFailure extends SyncState {
  final Failure failure;

  SyncFailure(this.failure);
}