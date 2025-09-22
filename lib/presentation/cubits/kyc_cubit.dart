import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../core/errors/result.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/usecases/create_kyc_usecase.dart';

part 'kyc_state.dart';

class KycCubit extends Cubit<KycState> {
  final CreateKycUsecase kycUsecase;
  KycCubit(this.kycUsecase) : super(KycStateInitial());

  Future<void> submit(Kyc kyc) async {
    emit(KycStateLoading());
      final resultSubmit = await kycUsecase.execute(kyc);

    switch (resultSubmit) {
      case Success(data: final auth):
        emit(KycStateSuccess());
      case Failure(failure: final f):
        emit(KycStateError(f.message));
    }
  }
}
