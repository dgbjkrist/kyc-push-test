part of 'sync_bloc.dart';

@immutable
sealed class SyncEvent {}

final class NewPendingKycEvent extends SyncEvent {}
final class NetworkOnlineEvent extends SyncEvent {}
