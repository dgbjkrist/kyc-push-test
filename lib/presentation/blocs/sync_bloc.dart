import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../core/errors/result.dart';
import '../../domain/repositories/kyc_repository.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final KycRepository _kycRepository;

  SyncBloc(this._kycRepository) : super(SyncInitial()) {
    on<NewPendingKycEvent>((event, emit) async {
      await _processPendingKyc(emit);
    });

    on<NetworkOnlineEvent>((event, emit) async {
      await _processPendingKyc(emit);
    });
  }

  Future<void> _processPendingKyc(Emitter<SyncState> emit) async {
    emit(SyncLoading());
    print("SyncBloc _processPendingKyc");
    final result = await _kycRepository.retryPending();
    switch (result) {
      case Success(data: final kycs):
        emit(SyncSuccess());
      case Failure(failure: final f):
        emit(SyncFailure(Failure(f)));
    }
  }
}
